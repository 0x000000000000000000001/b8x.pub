module Util.Storage.Local
  (getInLocalStorage
  , removeInLocalStorage
  , setInLocalStorage
  ) where

import Proem

import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe)
import Data.Time.Duration (Seconds)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Util.Storage.Storage (getInStorage, setInStorage)
import Web.Storage.Storage (Storage, removeItem)

foreign import getLocalStorageOrFallback :: Effect Storage

setInLocalStorage :: ∀ m a. MonadEffect m => WriteForeign a => String -> a -> Maybe Seconds -> m Ɩ
setInLocalStorage k v maybeTtl = ʌ do
  storage <- getLocalStorageOrFallback
  setInStorage storage k v maybeTtl

getInLocalStorage :: ∀ @a m. MonadEffect m => ReadForeign a => String -> m (Maybe a)
getInLocalStorage k = ʌ do
  storage <- getLocalStorageOrFallback
  getInStorage storage k

removeInLocalStorage :: ∀ m. MonadEffect m => String -> m Ɩ
removeInLocalStorage k = ʌ do
  storage <- getLocalStorageOrFallback
  removeItem k storage


