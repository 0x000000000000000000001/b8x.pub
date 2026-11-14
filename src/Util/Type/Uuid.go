package Util_Type_Uuid

import "github.com/google/uuid"

func _GenerateV7Uuid() string {
	id, _ := uuid.NewV7()
	return id.String()
}
