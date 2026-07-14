module Core.Message.Query.Query where

import Proem

import Core.Event.Event (LoadedEvent)
import Core.Event.EventStore (EVENT_STORE, loadEvents)
import Core.Event.Filter (Filter)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Mod.Projection.Index (PROJECTION_READ)
import Foreign (Foreign)
import Yoga.JSON (class ReadForeign, class WriteForeign, writeImpl)
import Data.Array (foldl)
import Data.Newtype (class Newtype, unwrap)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectName)
import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Cache as Cache
import Core.Mod.Trace.Trace (READER_TRACE)
import Core.Feat.Effect.Generate (GENERATE)
import Data.Maybe (Maybe(..))

data CacheStrategy
  = NotCached
  | Cached
      { ttlSec :: Int
      , invalidationVersion :: Foreign
      , subject :: Maybe Foreign
      }

cached
  :: ∀ a
   . WriteForeign a
  => Int
  -> a
  -> Maybe Foreign
  -> CacheStrategy
cached ttlSec invalidationVersion subject =
  Cached
    { ttlSec
    , invalidationVersion: writeImpl invalidationVersion
    , subject: subject
    }

defaultCached :: ∀ a. WriteForeign a => a -> CacheStrategy
defaultCached invalidationVersion = cached (30 * 24 * 3600) invalidationVersion Nothing

defaultCachedWithSubject :: ∀ a s. WriteForeign a => WriteForeign s => a -> Maybe s -> CacheStrategy
defaultCachedWithSubject invalidationVersion subject = cached (30 * 24 * 3600) invalidationVersion (writeImpl <$> subject)

class (Newtype query payload, ReadForeign query, WriteForeign query, Reflect query, Random query) <= IsQuery query (state :: Type) (fields :: Row Type) payload a | query -> state, query -> fields, query -> payload, query -> a where
  description :: String

  handle :: ∀ fx. query -> Run (EVENT_STORE + EXCEPT_LOGIC + PROJECTION_READ + READER_PUBLIC_CONFIG + CACHE + GENERATE + READER_TRACE + fx) a

  cacheStrategy :: ∀ fx. query -> Run (EVENT_STORE + EXCEPT_LOGIC + PROJECTION_READ + READER_PUBLIC_CONFIG + CACHE + GENERATE + READER_TRACE + fx) CacheStrategy

handleWithCache
  :: ∀ query state fields payload a fx
   . IsQuery query state fields payload a
  => ReadForeign a
  => WriteForeign a
  => query
  -> Run (EVENT_STORE + EXCEPT_LOGIC + PROJECTION_READ + READER_PUBLIC_CONFIG + CACHE + GENERATE + READER_TRACE + fx) a
handleWithCache query = do
  strategy <- cacheStrategy query

  case strategy of
    NotCached -> handle query
    Cached { ttlSec, invalidationVersion, subject } -> do
      let
        prefix = reflectName @query
        key = Cache.cacheKey prefix query invalidationVersion subject

      Cache.getOrSet key ttlSec (handle query)

defaultHandle
  :: ∀ query state payload a fx
   . Newtype query payload
  => (payload -> Filter) -- filter
  -> state -- initialState
  -> (state -> LoadedEvent -> state) -- play
  -> (∀ fx'. payload -> state -> Run (EXCEPT_LOGIC + fx') a) -- toResult
  -> query
  -> Run (EVENT_STORE + EXCEPT_LOGIC + PROJECTION_READ + READER_PUBLIC_CONFIG + CACHE + GENERATE + READER_TRACE + fx) a
defaultHandle filter initialState play toResult query = do
  let
    payload = unwrap query
    filter' = filter $ unwrap query

  loadedEvents <- loadEvents filter'

  let state = foldl play initialState loadedEvents

  toResult payload state