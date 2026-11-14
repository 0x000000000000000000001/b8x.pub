package router

var Empty = make(map[string]interface{})

func _On(tag string, handler func(interface{}) interface{}, dict map[string]interface{}) map[string]interface{} {
	newDict := make(map[string]interface{})
	for k, v := range dict {
		newDict[k] = v
	}
	newDict[tag] = handler
	return newDict
}

func _Build(dict map[string]interface{}, fallback func(interface{}) interface{}, tag string, value interface{}, original interface{}) interface{} {
	if handler, ok := dict[tag]; ok {
		if handlerFunc, ok := handler.(func(interface{}) interface{}); ok {
			return handlerFunc(value)
		}
	}

	return fallback(original)
}
