package channels

import (
	"errors"
	"fmt"
	"time"

	"github.com/go-pg/pg/v10"
	"github.com/ksw2000/whisper/friends"
)

type ChannelReq struct {
	Attendee                        int    `json:"attendee" binding:"required"`
	KeyEncryptedByAttendeePublicKey string `json:"key_encrypted_by_attendee_public_key" binding:"required"`
	KeyEncryptedByHostPublicKey     string `json:"key_encrypted_by_host_public_key" binding:"required"`
}

type Channel struct {
	ID                       int
	FriendID                 int
	KeyEncryptedByInviterKey string
	KeyEncryptedByInviteeKey string
	CreatedAt                time.Time
}

type ViewFriendChannels struct {
	ChannelID                int
	Inviter                  int
	Invitee                  int
	KeyEncryptedByInviterKey string
	KeyEncryptedByInviteeKey string
}

var (
	ErrorAttendeeIsNotYourFriend = errors.New("attendee is not your friend")
	ErrorChannelAlreadyExisted   = errors.New("channel already existed")
	ErrorForbidden               = errors.New("forbidden")
)

func (c *ChannelReq) Create(db *pg.DB, hostUID int) (int, error) {
	tx, err := db.Begin()
	if err != nil {
		return -1, fmt.Errorf("db.Begin failed: %w", err)
	}
	defer tx.Rollback()

	f := friends.Friend{}
	err = db.Model(&f).Where("accepted = true").Where(`
		(invitee = ? and inviter = ?)
		or
		(invitee = ? and inviter = ?)
	`, hostUID, c.Attendee, c.Attendee, hostUID).Select()

	if err != nil {
		if err == pg.ErrNoRows {
			return -1, ErrorAttendeeIsNotYourFriend
		}
		return -1, fmt.Errorf("db.Model.Where.Where.Select failed: %w", err)
	}

	channel := Channel{
		FriendID: f.ID,
	}

	n, err := db.Model(&channel).Where("friend_id = ?", f.ID).Count()
	if err != nil {
		return -1, fmt.Errorf("db.Model.Where.Count failed: %w", err)
	}
	if n > 0 {
		return -1, ErrorChannelAlreadyExisted
	}

	if f.Invitee == hostUID {
		channel.KeyEncryptedByInviteeKey = c.KeyEncryptedByHostPublicKey
		channel.KeyEncryptedByInviterKey = c.KeyEncryptedByAttendeePublicKey
	} else {
		channel.KeyEncryptedByInviteeKey = c.KeyEncryptedByAttendeePublicKey
		channel.KeyEncryptedByInviterKey = c.KeyEncryptedByHostPublicKey
	}

	_, err = db.Model(&channel).Insert()
	if err != nil {
		return -1, fmt.Errorf("db.Model.Where.Select failed: %w", err)
	}

	err = tx.Commit()
	if err != nil {
		return -1, fmt.Errorf("tx.Commit failed: %w", err)
	}

	return channel.ID, nil
}

func GetEncryptedKey(db *pg.DB, channelID, uid int) (string, error) {
	view := ViewFriendChannels{}
	err := db.Model(&view).Where("channel_id = ?", channelID).Select()
	if err != nil {
		if err == pg.ErrNoRows {
			return "", ErrorForbidden
		}
		return "", fmt.Errorf("db.Model(channel).Where.Select failed: %w", err)
	}

	if view.Invitee == uid {
		return view.KeyEncryptedByInviteeKey, nil
	} else if view.Inviter == uid {
		return view.KeyEncryptedByInviterKey, nil
	}
	return "", ErrorForbidden
}
