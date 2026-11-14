import "reflect"

func FixTaggedSumRepMissingValue(f interface{}) interface{} {
	v := reflect.ValueOf(f)
	if v.Kind() == reflect.Ptr {
		v = v.Elem()
	}

	if v.Kind() == reflect.Map {
		if t := v.MapIndex(reflect.ValueOf("type")); t.IsValid() {
			val := v.MapIndex(reflect.ValueOf("value"))
			if !val.IsValid() {
				if m, ok := f.(map[string]interface{}); ok {
					m["value"] = nil
				}
			}
		}
	}
	// Note: We cannot dynamically add fields to a Go struct.
	// If gopurs generated it as a struct, it would already be typed with "value".
	return f
}
