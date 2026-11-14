import (
	"fmt"
	"html"
	"strings"
	"unicode/utf8"
)

func _DecodeHtmlEntities(str string) string {
	return html.UnescapeString(str)
}

func _EncodeHtmlEntities(str string) string {
	var sb strings.Builder
	for len(str) > 0 {
		r, size := utf8.DecodeRuneInString(str)
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == ' ' || r == '\n' || r == '\r' || r == '\t' {
			sb.WriteRune(r)
		} else {
			sb.WriteString(fmt.Sprintf("&#x%X;", r))
		}
		str = str[size:]
	}
	return sb.String()
}
