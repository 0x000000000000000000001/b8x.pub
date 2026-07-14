module Util.Storage.Local
  (getInLocalStorage
  , removeInLocalStorage
  , setInLocalStorage
  ) where

import Proem

import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe)
import Data.Time.Duration (Seconds)
import Effect.Class (class MonadEffect)
import Util.Storage.Storage (getInStorage, setInStorage)
import Web.HTML (window)
import Web.HTML.Window (localStorage)
import Web.Storage.Storage (removeItem)

setInLocalStorage :: ∀ m a. MonadEffect m => WriteForeign a => String -> a -> Maybe Seconds -> m Ɩ
setInLocalStorage k v maybeTtl = ʌ do
  storage <- localStorage =<< window
  setInStorage storage k v maybeTtl

getInLocalStorage :: ∀ @a m. MonadEffect m => ReadForeign a => String -> m (Maybe a)
getInLocalStorage k = ʌ do
  storage <- localStorage =<< window
  getInStorage storage k

removeInLocalStorage :: ∀ m. MonadEffect m => String -> m Ɩ
removeInLocalStorage k = ʌ do
  storage <- localStorage =<< window
  removeItem k storage
