module Util.Http.Http
  (delete
  , delete_
  , get
  , getCheckStatus
  , patch
  , patch_
  , post
  , post_
  , put
  , put_
  , request
  ) where

import Proem

import Affjax (AffjaxDriver, Error, Request, Response, URL, printError)
import Affjax (delete, delete_, get, patch, patch_, post, post_, put, put_, request) as Affjax
import Affjax.RequestBody (RequestBody)
import Affjax.ResponseFormat (ResponseFormat)
import Affjax.StatusCode (StatusCode(..))
import Data.Either (Either(..))
import Data.Maybe (Maybe)
import Effect.Aff (Aff)

foreign import _driver :: AffjaxDriver

get :: ∀ a. ResponseFormat a -> URL -> Aff (Either Error (Response a))
get = Affjax.get _driver

post :: ∀ a. ResponseFormat a -> URL -> Maybe RequestBody -> Aff (Either Error (Response a))
post = Affjax.post _driver

post_ :: URL -> Maybe RequestBody -> Aff (Either Error Ɩ)
post_ = Affjax.post_ _driver

put :: ∀ a. ResponseFormat a -> URL -> Maybe RequestBody -> Aff (Either Error (Response a))
put = Affjax.put _driver

put_ :: URL -> Maybe RequestBody -> Aff (Either Error Ɩ)
put_ = Affjax.put_ _driver

delete :: ∀ a. ResponseFormat a -> URL -> Aff (Either Error (Response a))
delete = Affjax.delete _driver

delete_ :: URL -> Aff (Either Error Ɩ)
delete_ = Affjax.delete_ _driver

patch :: ∀ a. ResponseFormat a -> URL -> RequestBody -> Aff (Either Error (Response a))
patch = Affjax.patch _driver

patch_ :: URL -> RequestBody -> Aff (Either Error Ɩ)
patch_ = Affjax.patch_ _driver

request :: ∀ a. Request a -> Aff (Either Error (Response a))
request = Affjax.request _driver

-- | Does a GET request and checks for HTTP status codes.
-- | Returns an error message if the status code indicates a failure.
-- | Returns Left for:
-- |   - Network errors (timeout, DNS issues, etc.)
-- |   - HTTP status codes >= 400 (client/server errors)
-- | Returns Right only for 2xx and 3xx status codes
getCheckStatus :: ∀ a. ResponseFormat a -> String -> Aff (Either String (Response a))
getCheckStatus format url = do
  response <- get format url
  response
    ?!
      (\res -> do
          let (StatusCode code) = res.status
          code >= 200 && code < 400
            ? (η $ Right res)
            ↔ (η $ Left $ "HTTP " <> show code <> ": " <> res.statusText)
      )
    ⇿ (η ◁ Left ◁ printError)
