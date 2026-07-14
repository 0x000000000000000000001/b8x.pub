export const _publicConfig = {
  env: "$ENV",
  version: "$GIT_COMMIT",
  api: {
    host: "$API_DNS_LEVEL_3_GTE",
  },
  ui: {
    host: "$DNS_LEVEL_2_GTE",
    dns: {
      level1: "$DNS_LEVEL_1",
      level2: {
        a: "$DNS_LEVEL_2_a",
        b: "$DNS_LEVEL_2_b"
      }
    },
    legacyHost: "$LEGACY_DNS_LEVEL_2_GTE",
    appId: "$UI_APP_ID"
  },
  objectStorage: {
    urlBase: "$S3_URL_BASE",
  }
};
