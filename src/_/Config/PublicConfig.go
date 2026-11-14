package Config_PublicConfig

import "os"

var _PublicConfig = map[string]any{
	"env":     os.Getenv("ENV"),
	"version": os.Getenv("GIT_COMMIT"),
	"api": map[string]any{
		"host": os.Getenv("API_DNS_LEVEL_3_GTE"),
	},
	"ui": map[string]any{
		"host": os.Getenv("DNS_LEVEL_2_GTE"),
		"dns": map[string]any{
			"level1": os.Getenv("DNS_LEVEL_1"),
			"level2": map[string]any{
				"a": os.Getenv("DNS_LEVEL_2_a"),
				"b": os.Getenv("DNS_LEVEL_2_b"),
			},
		},
		"legacyHost": os.Getenv("LEGACY_DNS_LEVEL_2_GTE"),
		"appId":      os.Getenv("UI_APP_ID"),
	},
	"objectStorage": map[string]any{
		"urlBase": os.Getenv("S3_URL_BASE"),
	},
}
