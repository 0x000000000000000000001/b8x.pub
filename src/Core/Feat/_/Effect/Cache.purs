module Core.Feat.Effect.Cache
  ( CACHE
  , Cache(..)
  , CacheKey
  , cache'
  , cacheKey
  , unCacheKey
  , get
  , innerSalt
  , set
  , getOrSet
  ) where

import Proem
import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON as JSON

import Foreign (Foreign)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Either (hush)
import Data.Maybe (Maybe(..))
import Run (Run, lift)
import Type.Row (type (+))

type CacheKey_ =
  { prefix :: String
  , payload :: Foreign
  , invalidationVersion :: String
  , subject :: Maybe Foreign
  }

newtype CacheKey = CacheKey CacheKey_

unCacheKey :: CacheKey -> CacheKey_
unCacheKey (CacheKey k) = k

data Cache a
  = Get CacheKey (Maybe Foreign -> a)
  | Set CacheKey Int Foreign (Ɩ -> a)

derive instance Functor Cache

type CACHE fx = (cache :: Cache | fx)

cache' = π :: Π "cache"

-- | Change it to reset all caches.
innerSalt :: String
innerSalt = "1"

cacheKey
  :: ∀ v p
   . WriteForeign p
  => WriteForeign v
  => String
  -> p
  -> v
  -> Maybe Foreign
  -> CacheKey
cacheKey prefix payload invalidationVersion subject = CacheKey
  { prefix
  , payload: writeImpl payload
  , invalidationVersion: invalidationVersion # JSON.writeJSON
  , subject: subject
  }

get :: ∀ a fx. ReadForeign a => CacheKey -> Run (CACHE + fx) (Maybe a)
get key = do
  mJson <- lift cache' (Get key identity)
  η $ mJson >>= hush ◁ Control.Monad.Except.runExcept ◁ readImpl

set :: ∀ a fx. WriteForeign a => CacheKey -> Int -> a -> Run (CACHE + fx) Ɩ
set key ttlSec value = lift cache' (Set key ttlSec (writeImpl value) identity)

getOrSet :: ∀ a fx. ReadForeign a => WriteForeign a => CacheKey -> Int -> Run (CACHE + fx) a -> Run (CACHE + fx) a
getOrSet key ttlSec calculate = do
  mCached <- get key
  case mCached of
    Just cached -> η cached
    Nothing -> do
      result <- calculate
      set key ttlSec result
      η result
