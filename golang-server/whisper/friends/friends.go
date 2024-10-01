package friends

import (
	"errors"
	"fmt"
	"time"

	"github.com/go-pg/pg/v10"
	"github.com/ksw2000/whisper/users"
)

type Friend struct {
	ID        int
	Inviter   int
	Invitee   int
	Accepted  bool
	CreatedAt time.Time
	UpdatedAt time.Time
}

type ViewFriendList struct {
	FriendID  int    `json:"-"`
	Me        int    `json:"-"`
	UID       int    `json:"uid"`
	UserID    string `json:"user"`
	Name      string `json:"name"`
	Profile   string `json:"profile"`
	PublicKey string `json:"public_key"`
	ChannelID int    `json:"channel_id"`
}

var (
	ErrorAlreadyFriends                    = errors.New("already friends")
	ErrorUserCannotBeFriendsWithThemSelves = errors.New("user cannot be friends with themselves")
)

func MakeFriend(db *pg.DB, inviter, invitee int) error {
	if inviter == invitee {
		return ErrorUserCannotBeFriendsWithThemSelves
	}
	var err error
	var n int

	tx, err := db.Begin()
	if err != nil {
		return fmt.Errorf("db.Begin failed: %w", err)
	}
	defer tx.Rollback()

	// 檢查 id 是否皆存在
	n, err = tx.Model((*users.User)(nil)).Where("id = ?", inviter).Count()
	if err != nil {
		return fmt.Errorf("tx.Model.Where(id = inviter).Count failed: %w", err)
	} else if n == 0 {
		return users.ErrorUserNotFound
	}

	n, err = tx.Model((*users.User)(nil)).Where("id = ?", invitee).Count()
	if err != nil {
		return fmt.Errorf("tx.Model.Where(id = invitee).Count failed: %w", err)
	} else if n == 0 {
		return users.ErrorUserNotFound
	}

	// 檢查是否已是朋友
	n, err = tx.Model((*Friend)(nil)).Where(
		`(inviter = ? and invitee = ?) or
		 (inviter = ? and invitee = ?)`, inviter, invitee, invitee, inviter).Count()
	if err != nil {
		return fmt.Errorf("tx.Model.Where(inviter=inviter and invitee=invitee) failed: %w", err)
	} else if n > 0 {
		return ErrorAlreadyFriends
	}

	friend := Friend{
		Inviter:  inviter,
		Invitee:  invitee,
		Accepted: true,
	}

	if _, err = tx.Model(&friend).Insert(); err != nil {
		return fmt.Errorf("tx.Model.Insert failed: %w", err)
	}
	if err = tx.Commit(); err != nil {
		return fmt.Errorf("tx.Commit failed: %w", err)
	}
	return nil
}

func DeleteFriend(db *pg.DB, uid1, uid2 int) error {
	_, err := db.Model((*Friend)(nil)).Where(
		`(inviter = ? and invitee = ?) or
		(inviter = ? and invitee = ?)`, uid1, uid2, uid2, uid1).Delete()
	if err != nil {
		return fmt.Errorf("db.Model.Where.Delete failed: %w", err)
	}
	return nil
}

const limit = 3 // for debug

func ListFriends(db *pg.DB, uid, cursor int) (friends []ViewFriendList, err error) {
	query := db.Model(&friends).Where("me = ?", uid)
	if cursor > 0 {
		query = query.Where("friend_id < ?", cursor)
	}
	err = query.Order("friend_id DESC").Limit(limit).Select()
	if err != nil && err != pg.ErrNoRows {
		return friends, fmt.Errorf("db.Query failed: %w", err)
	}
	return friends, nil
}
