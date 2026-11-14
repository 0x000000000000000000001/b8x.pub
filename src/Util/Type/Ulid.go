package Util_Type_Ulid

import (
	"strings"

	"github.com/oklog/ulid/v2"
)

func _GenerateUlid() string {
	// oklog/ulid/v2 MustNew with crypto/rand for entropy is safer
	u := ulid.Make()
	return strings.ToLower(u.String())
}

func _IsValid(u string) bool {
	_, err := ulid.Parse(strings.ToUpper(u))
	return err == nil
}
