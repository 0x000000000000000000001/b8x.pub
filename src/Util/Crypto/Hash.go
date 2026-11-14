package hash

import (
	"crypto/hmac"
	"crypto/md5"
	"crypto/sha256"
	"encoding/hex"
	"fmt"

	"github.com/cespare/xxhash/v2"
)

func _Md5(str string) string {
	hash := md5.Sum([]byte(str))
	return hex.EncodeToString(hash[:])
}

func _Sha256(str string) string {
	hash := sha256.Sum256([]byte(str))
	return hex.EncodeToString(hash[:])
}

func HmacSha256(secret string, message string) string {
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(message))
	return hex.EncodeToString(mac.Sum(nil))
}

func _Xxhash64(input string) string {
	return fmt.Sprintf("%016x", xxhash.Sum64String(input))
}
