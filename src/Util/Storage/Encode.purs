module Util.Storage.Encode
  ( StoredValue
  , decodeStoredValue
  ) where

import Proem
import Control.Monad.Except as Control.Monad.Except
import Data.Maybe (Maybe(..))
import Yoga.JSON as JSON
import Foreign.Index as Foreign.Index
import Foreign (Foreign, MultipleErrors)
import Foreign as Foreign
import Yoga.JSON (class ReadForeign, readImpl)
import Data.Either (Either)
import Util.Lexicon.ExpiresAtTs (expiresAtTs_)
import Util.Lexicon.Value (value_)

type StoredValue a =
  { value :: a
  , expiresAtTs :: Maybe Number
  }

decodeStoredValue :: ∀ a. ReadForeign a => Foreign -> Either MultipleErrors (StoredValue a)
decodeStoredValue json = Control.Monad.Except.runExcept $ do
  obj <- readImpl json
  value <- Foreign.Index.readProp value_ obj >>= JSON.readImpl
  expiresAtTs <- Foreign.Index.readProp expiresAtTs_ obj >>= \v -> if Foreign.isUndefined v then pure Nothing else Just <$> JSON.readImpl v
  η { value, expiresAtTs }
