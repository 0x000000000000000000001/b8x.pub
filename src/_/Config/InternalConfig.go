package Config_InternalConfig

import (
	"os"
	"strconv"
)

func parseInt(s string, def int) int {
	if s == "" {
		return def
	}
	i, err := strconv.Atoi(s)
	if err != nil {
		return def
	}
	return i
}

var _Config = map[string]any{
	"name": os.Getenv("APP_NAME"),
	"db": map[string]any{
		"store": map[string]any{
			"host":          os.Getenv("POSTGRES_HOST_STORE"),
			"directHost":    os.Getenv("POSTGRES_HOST"),
			"port":          parseInt(os.Getenv("POSTGRES_PORT"), 0),
			"database":      os.Getenv("POSTGRES_DB_STORE"),
			"user":          os.Getenv("POSTGRES_USER"),
			"password":      os.Getenv("POSTGRES_PASSWORD"),
			"idleTimeoutMs": parseInt(os.Getenv("POSTGRES_IDLE_TIMEOUT_MS"), 10000),
		},
		"storeLock": map[string]any{
			"host":          os.Getenv("POSTGRES_HOST_STORE_LOCK"),
			"directHost":    os.Getenv("POSTGRES_HOST"),
			"port":          parseInt(os.Getenv("POSTGRES_PORT"), 0),
			"database":      os.Getenv("POSTGRES_DB_STORE"),
			"user":          os.Getenv("POSTGRES_USER"),
			"password":      os.Getenv("POSTGRES_PASSWORD"),
			"idleTimeoutMs": parseInt(os.Getenv("POSTGRES_IDLE_TIMEOUT_MS"), 2000),
		},
		"edge": map[string]any{
			"host":          os.Getenv("POSTGRES_HOST_EDGE"),
			"directHost":    os.Getenv("POSTGRES_HOST"),
			"port":          parseInt(os.Getenv("POSTGRES_PORT"), 0),
			"database":      os.Getenv("POSTGRES_DB_EDGE"),
			"user":          os.Getenv("POSTGRES_USER"),
			"password":      os.Getenv("POSTGRES_PASSWORD"),
			"idleTimeoutMs": parseInt(os.Getenv("POSTGRES_IDLE_TIMEOUT_MS"), 10000),
		},
	},
	"mq": map[string]any{
		"host":     os.Getenv("RABBITMQ_HOST"),
		"port":     parseInt(os.Getenv("RABBITMQ_PORT"), 0),
		"user":     os.Getenv("RABBITMQ_USER"),
		"password": os.Getenv("RABBITMQ_PASS"),
	},
	"mail": map[string]any{
		"from": map[string]any{
			"name": os.Getenv("MAIL_FROM_NAME"),
			"email": map[string]any{
				"transaction": os.Getenv("MAIL_FROM_TRANSACTION_EMAIL"),
				"bug":         os.Getenv("MAIL_FROM_BUG_EMAIL"),
				"newsletter":  os.Getenv("MAIL_FROM_NEWSLETTER_EMAIL"),
			},
		},
		"to": map[string]any{
			"bug": os.Getenv("MAIL_TO_BUG_EMAIL"),
		},
	},
	"helloAsso": map[string]any{
		"clientId":      os.Getenv("HELLOASSO_CLIENT_ID"),
		"clientSecret":  os.Getenv("HELLOASSO_CLIENT_SECRET"),
		"webhookSecret": os.Getenv("HELLOASSO_WEBHOOK_SECRET"),
	},
	"aws": map[string]any{
		"region": os.Getenv("AWS_REGION"),
		"ses": map[string]any{
			"region":          os.Getenv("AWS_REGION"),
			"accessKeyId":     os.Getenv("SES_ACCESS_KEY"),
			"secretAccessKey": os.Getenv("SES_SECRET_ACCESS_KEY"),
		},
		"s3": map[string]any{
			"region":          os.Getenv("AWS_REGION"),
			"bucket":          os.Getenv("S3_BUCKET"),
			"accessKeyId":     os.Getenv("S3_ACCESS_KEY"),
			"secretAccessKey": os.Getenv("S3_SECRET_ACCESS_KEY"),
			"urlBase":         os.Getenv("S3_URL_BASE"),
		},
	},
	"sendy": map[string]any{
		"licenseKey": os.Getenv("SENDY_LICENSE_KEY"),
		"awsIam": map[string]any{
			"accessKeyId":     os.Getenv("SENDY_AWS_IAM_KEY"),
			"secretAccessKey": os.Getenv("SENDY_AWS_IAM_SECRET"),
		},
		"user":     os.Getenv("SENDY_USER"),
		"password": os.Getenv("SENDY_PASSWORD"),
		"apiKey":   os.Getenv("SENDY_API_KEY"),
		"brandId":  os.Getenv("SENDY_BRAND_ID"),
		"listId":   os.Getenv("SENDY_LIST_ID"),
		"host":     os.Getenv("NEWS_DNS_LEVEL_3_GTE"),
	},
	"auth": map[string]any{
		"pasetoLocalKey": os.Getenv("AUTH_PASETO_LOCAL_KEY"),
	},
	"mailchimp": map[string]any{
		"apiKey":        os.Getenv("MAILCHIMP_API_KEY"),
		"masterDraftId": os.Getenv("MAILCHIMP_MASTER_DRAFT_ID"),
		"serverPrefix":  os.Getenv("MAILCHIMP_SERVER_PREFIX"),
	},
}
