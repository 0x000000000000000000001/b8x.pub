package paseto

import (
	"encoding/hex"
	"regexp"
	"strconv"
	"time"

	"github.com/vk-rv/pvx"
)

type CustomClaims map[string]any

func (c CustomClaims) Valid() error { return nil }

func EncryptV3LocalImpl(keyStr string, payload any, expiresInStr string) (string, error) {
	key, err := hex.DecodeString(keyStr)
	if err != nil {
		return "", err
	}
	claims := make(CustomClaims)
	if values, ok := payload.(map[string]any); ok {
		for name, value := range values {
			claims[name] = value
		}
	}
	setExpiration(claims, expiresInStr)
	return pvx.NewPV3Local().Encrypt(pvx.NewSymmetricKey(key, pvx.Version3), claims)
}

func setExpiration(claims CustomClaims, expiresIn string) {
	matches := regexp.MustCompile(`^(\d+)([hdm])$`).FindStringSubmatch(expiresIn)
	if len(matches) != 3 {
		return
	}
	value, _ := strconv.Atoi(matches[1])
	duration := time.Duration(value)
	switch matches[2] {
	case "h":
		duration *= time.Hour
	case "d":
		duration *= 24 * time.Hour
	case "m":
		duration *= time.Minute
	}
	claims["exp"] = time.Now().Add(duration).Format(time.RFC3339)
}

func DecryptV3LocalImpl(keyStr string, token string) (map[string]any, error) {
	key, err := hex.DecodeString(keyStr)
	if err != nil {
		return nil, err
	}
	claims := make(CustomClaims)
	err = pvx.NewPV3Local().Decrypt(token, pvx.NewSymmetricKey(key, pvx.Version3)).ScanClaims(&claims)
	return map[string]any(claims), err
}
