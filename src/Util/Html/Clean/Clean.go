import (
	"regexp"
	"strings"
)

func _Untag(isWAll bool, wTags []string, isBAll bool, bTags []string, replaceWithSpace bool, str string) string {
	re := regexp.MustCompile(`</?([a-zA-Z0-9:-]+)[^>]*>`)

	wMap := make(map[string]bool)
	for _, t := range wTags {
		wMap[strings.ToLower(t)] = true
	}
	bMap := make(map[string]bool)
	for _, t := range bTags {
		bMap[strings.ToLower(t)] = true
	}

	return re.ReplaceAllStringFunc(str, func(match string) string {
		submatches := re.FindStringSubmatch(match)
		if len(submatches) < 2 {
			return ""
		}
		tagName := strings.ToLower(submatches[1])

		isWhitelisted := isWAll || wMap[tagName]
		isBlacklistedInWhitelist := isBAll || bMap[tagName]

		if isWhitelisted && !isBlacklistedInWhitelist {
			return match
		}
		if replaceWithSpace {
			return " "
		}
		return ""
	})
}
