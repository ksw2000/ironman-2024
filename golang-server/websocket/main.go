package main

import (
	"fmt"
	"net/http"

	"golang.org/x/net/websocket"
)

const port = 8080

func main() {
	// 設定 WebSocket 路由
	http.Handle("/ws", websocket.Handler(handleWebSocket))

	// 啟動伺服器
	fmt.Printf("WebSocket 伺服器運行於: %d\n", port)
	err := http.ListenAndServe(fmt.Sprintf(":%d", port), nil)
	if err != nil {
		fmt.Println("伺服器啟動失敗:", err)
	}
}

func handleWebSocket(ws *websocket.Conn) {
	var message string

	for {
		// 讀取客戶端發送的消息
		err := websocket.Message.Receive(ws, &message)
		if err != nil {
			fmt.Println("讀取消息錯誤:", err)
			break
		}

		fmt.Println("收到消息:", message)

		m := []rune(message)
		for i := 0; i < len(m)/2; i++ {
			m[i], m[len(m)-1-i] = m[len(m)-1-i], m[i]
		}

		// 回傳消息給客戶端
		err = websocket.Message.Send(ws, string(m))
		if err != nil {
			fmt.Println("發送消息錯誤:", err)
			break
		}
	}
}
