package channels

import (
	"fmt"
	"time"

	"github.com/go-pg/pg/v10"
)

type Message struct {
	ID               int       `json:"-"`
	ChannelID        int       `json:"-"`
	Sender           int       `json:"sender"`
	EncryptedMessage string    `json:"encrypted_msg"`
	CreatedAt        time.Time `json:"time"`
}

func SendMessage(db *pg.DB, sender, channelID int, encryptedMessage string) (int, error) {
	tx, err := db.Begin()
	if err != nil {
		return -1, fmt.Errorf("db.Begin failed: %w", err)
	}
	defer tx.Rollback()

	view := ViewFriendChannels{}
	err = tx.Model(&view).
		Where("channel_id = ?", channelID).
		Where("inviter = ? or invitee = ?", sender, sender).
		Select()
	if err != nil {
		if err == pg.ErrNoRows {
			return -1, ErrorForbidden
		}
		return -1, fmt.Errorf("tx.Model.Where.Where.Select failed: %w", err)
	}

	message := Message{
		ChannelID:        channelID,
		Sender:           sender,
		EncryptedMessage: encryptedMessage,
	}

	_, err = tx.Model(&message).Insert()
	if err != nil {
		return -1, fmt.Errorf("tx.Model.Insert failed: %w", err)
	}

	err = tx.Commit()
	if err != nil {
		return -1, fmt.Errorf("tx.Commit failed: %w", err)
	}
	return message.ID, nil
}

const maxMessage = 10

func GetMessages(db *pg.DB, uid, channelID int, cursor int) (messages []Message, err error) {
	view := ViewFriendChannels{}
	err = db.Model(&view).
		Where("channel_id = ?", channelID).
		Where("inviter = ? or invitee = ?", uid, uid).
		Select()
	if err != nil {
		if err == pg.ErrNoRows {
			return messages, ErrorForbidden
		}
		return messages, fmt.Errorf("db.Model.Where.Where.Select failed: %w", err)
	}

	query := db.Model(&messages)
	if cursor != 0 {
		query = query.Where("id < ?", cursor)
	}
	err = query.
		Order("id DESC").
		Limit(maxMessage).
		Select()
	if err != nil && err != pg.ErrNoRows {
		return messages, fmt.Errorf("db.Model.Order.Limit.Select failed: %w", err)
	}
	return messages, nil
}
