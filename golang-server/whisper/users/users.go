package users

import (
	"encoding/base64"
	"errors"
	"fmt"
	"log"
	"regexp"
	"time"
	"unicode"

	"github.com/go-pg/pg/v10"
	"github.com/ksw2000/whisper/utils"
)

type UserRequest struct {
	Name                string `json:"name" binding:"required"`
	UserID              string `json:"user" binding:"required"`
	Password            string `json:"password" binding:"required"`
	Email               string `json:"email" binding:"required"`
	Pin                 string `json:"pin" binding:"required"`
	PublicKey           string `json:"public_key" binding:"required"`
	EncryptedPrivateKey string `json:"encrypted_private_key" binding:"required"`
}

type User struct {
	ID                  int
	Name                string
	UserID              string
	Email               string
	Profile             string
	PublicKey           string
	EncryptedPrivateKey string
	HashPassword        string
	HashPin             string
	Salt                string
	CreatedAt           time.Time
	UpdatedAt           time.Time
}

var (
	ErrorInvalidEmail    = errors.New("invalid email format")
	ErrorInvalidUserID   = errors.New("invalid userID format")
	ErrorInvalidPassword = errors.New("invalid password format")
	ErrorInvalidPin      = errors.New("invalid pin format")
	ErrorRepeatedUserID  = errors.New("id is already in use")
	ErrorRepeatedEmail   = errors.New("email is already in use")
)

func checkEmail(email string) error {
	r := regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`)
	if !r.MatchString(email) {
		return ErrorInvalidEmail
	}
	return nil
}

func checkUserID(userID string) error {
	r := regexp.MustCompile(`^[a-zA-Z0-9_.]{5,30}$`)
	if !r.MatchString(userID) {
		return ErrorInvalidUserID
	}
	return nil
}

func checkPassword(password string) error {
	if len(password) < 12 && len(password) > 50 {
		return ErrorInvalidPassword
	}

	var hasUpper, hasLower, hasNumber bool
	for _, char := range password {
		switch {
		case unicode.IsUpper(char):
			hasUpper = true
		case unicode.IsLower(char):
			hasLower = true
		case unicode.IsNumber(char):
			hasNumber = true
		}
	}

	if !(hasUpper && hasLower && hasNumber) {
		return ErrorInvalidPassword
	}
	return nil
}

func checkPin(pin string) error {
	r := regexp.MustCompile(`^[0-9]{6,20}$`)
	if !r.MatchString(pin) {
		return ErrorInvalidPin
	}
	return nil
}

func (u *UserRequest) Register(db *pg.DB) (err error) {
	// 檢查 email 格式
	if err = checkEmail(u.Email); err != nil {
		return err
	}

	// 檢查 UserID 格式
	if err = checkUserID(u.UserID); err != nil {
		return err
	}

	// 檢查 Password 格式
	if err = checkPassword(u.Password); err != nil {
		return err
	}

	// 檢查 Pin 格式
	if err = checkPin(u.Pin); err != nil {
		return err
	}

	// 產生鹽值
	salt := utils.GenerateSalt(32)
	hashPassword := utils.HashPasswordWithSalt([]byte(u.Password), salt)
	hashPin := utils.HashPasswordWithSalt([]byte(u.Pin), salt)

	// 加入資料庫
	// 檢查 user id 不重複
	tx, err := db.Begin()
	if err != nil {
		return fmt.Errorf("db.Begin failed: %w", err)
	}
	defer tx.Rollback()

	if num, err := tx.Model((*User)(nil)).Where("user_id = ?", u.UserID).Count(); err != nil {
		log.Print(err)
		return fmt.Errorf("tx.Model.Where.Count(user_id) failed: %w", err)
	} else if num > 0 {
		return ErrorRepeatedUserID
	}

	if num, err := tx.Model((*User)(nil)).Where("email = ?", u.Email).Count(); err != nil {
		log.Print(err)
		return fmt.Errorf("tx.Model.Where.Count(email) failed: %w", err)
	} else if num > 0 {
		return ErrorRepeatedEmail
	}

	v := User{
		Name:                u.Name,
		UserID:              u.UserID,
		Email:               u.Email,
		PublicKey:           u.PublicKey,
		EncryptedPrivateKey: u.EncryptedPrivateKey,
		HashPassword:        base64.StdEncoding.EncodeToString(hashPassword[:]),
		HashPin:             base64.StdEncoding.EncodeToString(hashPin[:]),
		Salt:                base64.StdEncoding.EncodeToString(salt),
	}

	_, err = tx.Model(&v).Insert()
	if err != nil {
		return fmt.Errorf("tx.Model.Insert failed: %w", err)
	}

	err = tx.Commit()
	if err != nil {
		return fmt.Errorf("tx.Commit failed: %w", err)
	}
	return nil
}

var (
	ErrorUserNotFound = errors.New("can not found the user")
)

func GetUserByID(db *pg.DB, id int) (user User, err error) {
	err = db.Model(&user).Where("id = ?", id).Select()
	if err != nil {
		if err == pg.ErrNoRows {
			return user, ErrorUserNotFound
		}
		return user, fmt.Errorf("db.Model.Where.Select failed: %w", err)
	}
	return user, nil
}