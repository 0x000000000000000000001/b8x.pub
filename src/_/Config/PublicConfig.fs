// Configuration FFI for Config.PublicConfig (Sharpurs).
// Mirrors the JS template by reading the same environment variables at
// runtime. Records are Map<string, obj>.

let private publicConfigEnv (name: string) : obj =
    match System.Environment.GetEnvironmentVariable(name) with
    | null -> box ""
    | value -> box value

let private publicConfigRecord (fields: (string * obj) list) : obj =
    box (Map.ofList fields)

let _publicConfig : obj =
    publicConfigRecord
        [ "env", publicConfigEnv "ENV"
          "version", publicConfigEnv "GIT_COMMIT"
          "api", publicConfigRecord [ "host", publicConfigEnv "API_DNS_LEVEL_3_GTE" ]
          "ui",
          publicConfigRecord
              [ "host", publicConfigEnv "DNS_LEVEL_2_GTE"
                "dns",
                publicConfigRecord
                    [ "level1", publicConfigEnv "DNS_LEVEL_1"
                      "level2",
                      publicConfigRecord
                          [ "a", publicConfigEnv "DNS_LEVEL_2_a"
                            "b", publicConfigEnv "DNS_LEVEL_2_b" ] ]
                "legacyHost", publicConfigEnv "LEGACY_DNS_LEVEL_2_GTE"
                "appId", publicConfigEnv "UI_APP_ID" ]
          "objectStorage", publicConfigRecord [ "urlBase", publicConfigEnv "S3_URL_BASE" ] ]
