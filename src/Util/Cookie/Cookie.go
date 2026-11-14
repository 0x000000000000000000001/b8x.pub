import (
	"net/url"
	"strconv"
	"strings"
)

func Parse(str string) interface{} {
	cookies := make(map[string]interface{})
	parts := strings.Split(str, ";")
	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		kv := strings.SplitN(part, "=", 2)
		if len(kv) == 2 {
			val, err := url.QueryUnescape(kv[1])
			if err == nil {
				cookies[kv[0]] = val
			} else {
				cookies[kv[0]] = kv[1]
			}
		}
	}
	return cookies
}

func SerializeImpl(name string, val string, maxAge int64, httpOnly bool, path string, secure bool, sameSite string, domain string) string {
	cookie := strings.ReplaceAll(url.QueryEscape(name)+"="+url.QueryEscape(val), "+", "%20")
	cookie += "; Max-Age=" + strconv.FormatInt(maxAge, 10)
	if domain != "" {
		cookie += "; Domain=" + domain
	}
	if path != "" {
		cookie += "; Path=" + path
	}
	if httpOnly {
		cookie += "; HttpOnly"
	}
	if secure {
		cookie += "; Secure"
	}
	if sameSite != "" {
		cookie += "; SameSite=" + strings.ToUpper(sameSite[:1]) + strings.ToLower(sameSite[1:])
	}
	return cookie
}
