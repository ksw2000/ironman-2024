package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/go-pg/pg/v10"
	"github.com/ksw2000/whisper/auth"
	"github.com/ksw2000/whisper/channels"
	"github.com/ksw2000/whisper/friends"
	"github.com/ksw2000/whisper/users"
)

func main() {
	f, err := os.Open("config/config.json")
	if err != nil {
		panic("can not open config file config/config.json")
	}
	defer f.Close()

	config := struct {
		Database pg.Options
		Port     string
		Release  bool
	}{}
	decoder := json.NewDecoder(f)
	decoder.Decode(&config)

	db := pg.Connect(&config.Database)
	defer db.Close()

	router := gin.Default()

	if config.Release {
		gin.SetMode(gin.ReleaseMode)
	}

	router.Use(CORSMiddleware())

	router.POST("/api/v1/users", func(c *gin.Context) {
		req := users.UserRequest{}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}

		if err := req.Register(db); err != nil {
			switch err {
			case users.ErrorRepeatedUserID:
				c.JSON(http.StatusUnprocessableEntity, gin.H{
					"error": "ID 已被使用",
				})
			case users.ErrorRepeatedEmail:
				c.JSON(http.StatusUnprocessableEntity, gin.H{
					"error": "Email 已被使用",
				})
			case users.ErrorInvalidEmail:
				c.JSON(http.StatusBadRequest, gin.H{
					"error": "Email 格式不正確",
				})
			case users.ErrorInvalidUserID:
				c.JSON(http.StatusBadRequest, gin.H{
					"error": "ID 僅包含英文字母、下劃線及點 5~30 字元",
				})
			case users.ErrorInvalidPassword:
				c.JSON(http.StatusBadRequest, gin.H{
					"error": "密碼需包含大小寫英文字母及數字 12~50 字元",
				})
			case users.ErrorInvalidPin:
				c.JSON(http.StatusBadRequest, gin.H{
					"error": "Pin 碼為 6~20 位數字",
				})
			default:
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}

		c.JSON(http.StatusOK, gin.H{"error": ""})
	})

	router.POST("/api/v1/auth/login", func(c *gin.Context) {
		req := auth.LoginRequest{}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}
		token, err := req.Login(db)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"token": "",
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"token": "",
					"error": "內部伺服器錯誤",
				})
			}
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"token": token,
			"error": "",
		})
	})

	router.POST("/api/v1/auth/logout", func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		if token == "" {
			c.JSON(http.StatusNoContent, nil)
			return
		}
		err := auth.Logout(db, token)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "內部伺服器錯誤",
			})
			return
		}
		c.JSON(http.StatusNoContent, nil)
	})

	router.POST("/api/v1/auth/restore_private_key", func(c *gin.Context) {
		req := struct {
			Pin string `json:"string" binding:"required"`
		}{}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}

		token := c.GetHeader("Authorization")
		if token == "" {
			c.JSON(http.StatusNoContent, nil)
			return
		}
	})

	router.GET("/api/v1/me/key", func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		pin := c.GetHeader("Pin")
		publicKey, encryptedPrivateKey, err := auth.CheckPin(db, token, pin)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"error":                 "",
			"public_key":            publicKey,
			"encrypted_private_key": encryptedPrivateKey,
		})
	})

	router.GET("/api/v1/me", func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		user, err := auth.CheckLogin(db, token)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"error":      "",
			"uid":        user.ID,
			"user":       user.UserID,
			"name":       user.Name,
			"profile":    user.Profile,
			"email":      user.Email,
			"public_key": user.PublicKey,
		})
	})

	router.GET("/api/v1/users/:uid", func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("uid"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "bad request",
			})
		}
		user, err := users.GetUserByID(db, id)
		if err != nil {
			if err == users.ErrorUserNotFound {
				c.JSON(http.StatusNotFound, gin.H{
					"error": "user not found",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"error":      "",
			"uid":        user.ID,
			"user":       user.UserID,
			"name":       user.Name,
			"profile":    user.Profile,
			"public_key": user.PublicKey,
		})
	})

	router.POST("/api/v1/friends", func(c *gin.Context) {
		req := struct {
			Invitee int `json:"uid" binding:"required"`
		}{}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}
		token := c.GetHeader("Authorization")
		me, err := auth.CheckLogin(db, token)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		err = friends.MakeFriend(db, me.ID, req.Invitee)
		if err != nil {
			if err == friends.ErrorAlreadyFriends {
				c.JSON(http.StatusConflict, gin.H{
					"error": "已經是好友了",
				})
			} else if err == friends.ErrorUserCannotBeFriendsWithThemSelves {
				c.JSON(http.StatusConflict, gin.H{
					"error": "不可以和自己成為好友",
				})
			} else if err == users.ErrorUserNotFound {
				c.JSON(http.StatusNotFound, gin.H{
					"error": "用戶不存在",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"error": "",
		})
	})

	router.DELETE("/api/v1/friends/:uid", func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("uid"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "bad request",
			})
		}
		token := c.GetHeader("Authorization")
		me, err := auth.CheckLogin(db, token)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		err = friends.DeleteFriend(db, me.ID, id)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "內部伺服器錯誤",
			})
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"error": "",
		})
	})

	router.GET("/api/v1/friends/:next", func(c *gin.Context) {
		next, err := strconv.Atoi(c.Param("next"))
		if err != nil || next < 0 {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "bad request",
			})
			return
		}
		token := c.GetHeader("Authorization")
		me, err := auth.CheckLogin(db, token)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		list, err := friends.ListFriends(db, me.ID, next)
		if err != nil {
			log.Println(err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "內部伺服器錯誤",
			})
			return
		}
		n := -1
		if len(list) > 0 {
			n = list[len(list)-1].FriendID
		}
		c.JSON(http.StatusOK, struct {
			Error string                   `json:"error"`
			Next  int                      `json:"next"`
			List  []friends.ViewFriendList `json:"list"`
		}{
			Error: "",
			Next:  n,
			List:  list,
		})
	})

	router.POST("/api/v1/channels", func(c *gin.Context) {
		req := channels.ChannelReq{}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}

		token := c.GetHeader("Authorization")
		me, err := auth.CheckLogin(db, token)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		channelID, err := req.Create(db, me.ID)
		if err != nil {
			if err == channels.ErrorAttendeeIsNotYourFriend {
				c.JSON(http.StatusForbidden, gin.H{
					"error": "不是朋友無法建立聊天室",
				})
			} else if err == channels.ErrorChannelAlreadyExisted {
				c.JSON(http.StatusConflict, gin.H{
					"error": "聊天室已存在",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		c.JSON(http.StatusCreated, gin.H{
			"error":      "",
			"channel_id": channelID,
		})
	})

	router.GET("/api/v1/channel/key/:channel_id", func(c *gin.Context) {
		channelID, err := strconv.Atoi(c.Param("channel_id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}
		token := c.GetHeader("Authorization")
		me, err := auth.CheckLogin(db, token)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		encryptedKey, err := channels.GetEncryptedKey(db, channelID, me.ID)
		if err != nil {
			if err == channels.ErrorForbidden {
				c.JSON(http.StatusForbidden, gin.H{"error": "無法存取該聊天室"})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		c.JSON(http.StatusOK, gin.H{
			"error":         "",
			"encrypted_key": encryptedKey,
		})
	})

	router.POST("/api/v1/messages/:channel_id", func(c *gin.Context) {
		channelID, err := strconv.Atoi(c.Param("channel_id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}
		req := struct {
			EncryptedMessage string `json:"encrypted_msg" binding:"required"`
		}{}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}

		token := c.GetHeader("Authorization")
		me, err := auth.CheckLogin(db, token)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}

		messageID, err := channels.SendMessage(db, me.ID, channelID, req.EncryptedMessage)
		if err != nil {
			if err == channels.ErrorForbidden {
				c.JSON(http.StatusForbidden, gin.H{"error": "無法存取該聊天室"})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"error":      "",
			"message_id": messageID,
		})
	})

	router.GET("/api/v1/messages/:channel_id/:next", func(c *gin.Context) {
		channelID, err := strconv.Atoi(c.Param("channel_id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}
		next, err := strconv.Atoi(c.Param("next"))
		if err != nil || next < 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "bad request"})
			return
		}

		token := c.GetHeader("Authorization")
		me, err := auth.CheckLogin(db, token)
		if err != nil {
			if err == auth.ErrorAuthenticationFailed {
				c.JSON(http.StatusUnauthorized, gin.H{
					"error": "驗證失敗",
				})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		list, err := channels.GetMessages(db, me.ID, channelID, next)
		if err != nil {
			if err == channels.ErrorForbidden {
				c.JSON(http.StatusForbidden, gin.H{"error": "無法存取該聊天室"})
			} else {
				log.Println(err)
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "內部伺服器錯誤",
				})
			}
			return
		}
		n := -1
		if len(list) > 0 {
			n = list[len(list)-1].ID
		}
		ret := struct {
			Error string             `json:"error"`
			Next  int                `json:"next"`
			List  []channels.Message `json:"list"`
		}{
			Error: "",
			Next:  n,
			List:  list,
		}
		c.JSON(http.StatusOK, &ret)
	})

	router.Run(config.Port)
}

// https://stackoverflow.com/questions/29418478/go-gin-framework-cors
func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}
