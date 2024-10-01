package auth

import (
	"encoding/base64"
	"errors"
	"fmt"
	"log"
	"time"

	"github.com/go-pg/pg/v10"
	"github.com/ksw2000/whisper/users"
	"github.com/ksw2000/whisper/utils"
)

type LoginRequest struct {
	UserID   string `json:"user" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type Auth struct {
	ID        int
	UID       int
	Token     string
	CreatedAt time.Time
	ExpiredAt time.Time
}

var (
	ErrorAuthenticationFailed = errors.New("authentication failed")
)

func (l *LoginRequest) Login(db *pg.DB) (token string, err error) {
	tx, err := db.Begin()
	if err != nil {
		return token, fmt.Errorf("db.Begin failed: %w", err)
	}
	defer tx.Rollback()
	res := users.User{}
	err = tx.Model(&res).Where("user_id = ?", l.UserID).Select()
	if err != nil {
		if err == pg.ErrNoRows {
			return token, ErrorAuthenticationFailed
		}
		return token, fmt.Errorf("tx.Model.Where.QueryOne failed: %w", err)
	}

	// 取得鹽值
	salt, err := base64.StdEncoding.DecodeString(res.Salt)
	if err != nil {
		return token, fmt.Errorf("base64.StdEncoding.DecodingString(res.Salt) failed: %w", err)
	}
	hashPassword := utils.HashPasswordWithSalt([]byte(l.Password), salt)

	// 取得資料庫中已雜湊的密碼
	hashPasswordInDB, err := base64.StdEncoding.DecodeString(res.HashPassword)
	if err != nil {
		return token, fmt.Errorf("base64.StdEncoding.DecodingString(res.HashPassword) failed: %w", err)
	}

	if string(hashPassword[:]) != string(hashPasswordInDB) {
		return token, ErrorAuthenticationFailed
	}

	// 產生長度為 64 字元的 token
	token = base64.StdEncoding.EncodeToString(utils.GenerateSalt(48))
	auth := Auth{
		UID:       res.ID,
		Token:     token,
		ExpiredAt: time.Now().Add(time.Hour * 24 * 7),
	}

	if _, err = tx.Model(&auth).Insert(); err != nil {
		return "", fmt.Errorf("tx.Model.Insert failed: %w", err)
	}
	if err = tx.Commit(); err != nil {
		return "", fmt.Errorf("tx.Commit failed: %w", err)
	}

	return token, nil
}

func Logout(db *pg.DB, token string) (err error) {
	_, err = db.Model((*Auth)(nil)).Where("token = ?", token).Delete()
	return err
}

func CheckLogin(db *pg.DB, token string) (*users.User, error) {
	user := users.User{}
	_, err := db.QueryOne(&user, `SELECT users.* FROM users, auths 
		WHERE users.id = auths.uid 
		and auths.token = ? 
		and auths.expired_at > ?`, token, time.Now())

	if err != nil {
		if err == pg.ErrNoRows {
			return nil, ErrorAuthenticationFailed
		}
		return nil, fmt.Errorf("db.QueryOne failed: %w", err)
	}

	return &user, nil
}

func CheckPin(db *pg.DB, token, pin string) (publicKey, encryptedPrivateKey string, err error) {
	var u *users.User
	u, err = CheckLogin(db, token)
	if err != nil {
		return publicKey, encryptedPrivateKey, err
	}
	if u == nil {
		panic("user should not be nil after checkLogin")
	}
	salt, err := base64.StdEncoding.DecodeString(u.Salt)
	if err != nil {
		return publicKey, encryptedPrivateKey, fmt.Errorf("base64.StdEncoding.DecodeString failed: %w", err)
	}
	log.Println(pin)
	hashPin := utils.HashPasswordWithSalt([]byte(pin), salt)
	encodedHashPin := base64.StdEncoding.EncodeToString(hashPin[:])
	if u.HashPin != encodedHashPin {
		return publicKey, encryptedPrivateKey, ErrorAuthenticationFailed
	}
	return u.PublicKey, u.EncryptedPrivateKey, nil
}
