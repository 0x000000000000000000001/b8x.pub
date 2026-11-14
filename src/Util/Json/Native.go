import (
	"encoding/json"
)

func ParseJSONImpl(left func(interface{}) interface{}, right func(interface{}) interface{}, str string) interface{} {
	var decoded interface{}
	err := json.Unmarshal([]byte(str), &decoded)
	if err != nil {
		return left(err.Error())
	}
	return right(decoded)
}
