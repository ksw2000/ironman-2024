package utils

import (
	"crypto/rand"
	"crypto/sha256"
	"io"
)

func GenerateSalt(size int) []byte {
	salt := make([]byte, size)
	_, err := io.ReadFull(rand.Reader, salt)
	if err != nil {
		panic(err)
	}
	return salt
}

func HashPasswordWithSalt(password, salt []byte) [32]byte {
	password = append(password, salt...)
	return sha256.Sum256(password)
}
