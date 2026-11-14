module Test.Ffi.Native where

import Proem

import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), attempt, delay, launchAff_, throwError)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (error)
import Effect.Ref as Ref
import Foreign (readString, unsafeToForeign)
import Foreign.Index (readProp)
import Util.Cookie.Cookie as Cookie
import Util.Crypto.Hash as Hash
import Util.Crypto.Paseto.Paseto as Paseto
import Util.Timer as Timer

check :: String -> Boolean -> Aff Unit
check label condition = unless condition (throwError (error label))

main :: Effect Unit
main = launchAff_ do
  let session = { maxAge: 900, httpOnly: true, path: "/", secure: true, sameSite: "lax", domain: "example.com" }
  check "session cookie attributes"
    (Cookie.serialize "session" "a b+c%" session == "session=a%20b%2Bc%25; Max-Age=900; Domain=example.com; Path=/; HttpOnly; Secure; SameSite=Lax")
  check "logout cookie expires immediately at the refresh path"
    (Cookie.serialize "refresh_token" "" (session { maxAge = 0, path = "/api/auth/refresh" }) == "refresh_token=; Max-Age=0; Domain=example.com; Path=/api/auth/refresh; HttpOnly; Secure; SameSite=Lax")

  let hashAction = Hash.xxhash64 "hello"
  first <- hashAction
  second <- hashAction
  check "hash callback result" (first == "26c7827d889f6da3")
  check "Aff replay" (first == second)

  let key = "0000000000000000000000000000000000000000000000000000000000000000"
  token <- Paseto.encryptV3Local key (unsafeToForeign { message: "native FFI" }) "1h"
  claims <- Paseto.decryptV3Local key token
  check "PASETO callback payload"
    (runExcept (readProp "message" claims >>= readString) == Right "native FFI")
  rejected <- attempt (Paseto.decryptV3Local key "invalid-token")
  check "PASETO callback rejection" case rejected of
    Left _ -> true
    Right _ -> false

  ticks <- liftEffect (Ref.new 0)
  let startTimer = Timer._setInterval 1 (Ref.modify_ (_ + 1) ticks)
  before <- liftEffect (Ref.read ticks)
  check "timer construction is deferred" (before == 0)
  timer <- liftEffect startTimer
  delay (Milliseconds 20.0)
  liftEffect (Timer._clearInterval timer)
  after <- liftEffect (Ref.read ticks)
  check "native timer callback" (after > 0)
  delay (Milliseconds 10.0)
  stopped <- liftEffect (Ref.read ticks)
  check "native timer cancellation" (stopped == after)

  liftEffect (log "NATIVE FFI INTEGRATION PASSED")
