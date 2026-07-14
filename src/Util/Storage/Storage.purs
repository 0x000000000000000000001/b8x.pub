module Util.Storage.Storage
  (getInStorage
  , setInStorage
  ) where

import Data.Maybe (Maybe(..))
import Proem
import Yoga.JSON as JSON
import Util.Storage.Encode as Util.Storage.Encode

import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.DateTime.Instant (unInstant)
import Data.Newtype (unwrap)
import Data.Time.Duration (Seconds(..))
import Effect.Class (class MonadEffect)
import Effect.Now (now)
import Util.Storage.Encode (StoredValue)
import Web.Storage.Storage (Storage, getItem, removeItem, setItem)

setInStorage :: ∀ m a. MonadEffect m => WriteForeign a => Storage -> String -> a -> Maybe Seconds -> m Ɩ
setInStorage storage k v maybeTtl = ʌ do
  currentTime <- now

  let
    maybeExpiresAtTs = maybeTtl <#> \(Seconds ttl) -> ttl + (unwrap $ unInstant currentTime) / 1000.0
    stored = { value: v, expiresAtTs: maybeExpiresAtTs }

  setItem k (JSON.writeJSON stored) storage

getInStorage :: ∀ @a m. MonadEffect m => ReadForeign a => Storage -> String -> m (Maybe a)
getInStorage storage k = ʌ do
  maybeItem <- getItem k storage
  maybeItem
    ??
      (\jsonStr -> do
          currentTime <- now

          let currentTs = (unwrap $ unInstant currentTime) / 1000.0

          case (JSON.readJSON_ jsonStr :: Maybe (Util.Storage.Encode.StoredValue a)) of
            Nothing -> η Nothing
            Just (stored :: StoredValue a) ->
              case stored.expiresAtTs of
                Nothing -> η (Just stored.value)
                Just expiresAtTs ->
                  expiresAtTs < currentTs
                    ? do
                        removeItem k storage
                        η Nothing
                    ↔ η (Just stored.value)
      )
    ⇔ η Nothing
