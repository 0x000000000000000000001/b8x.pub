module Infra.Cache.Postgres.Cache
  ( interpretCache
  , deleteExpiredCache
  , deleteExpiredCache_
  ) where

import Proem
import Yoga.JSON as JSON
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), hush)
import Foreign.Object as Object
import Foreign (F, Foreign)

import Core.Feat.Effect.Cache (CACHE, Cache(..), CacheKey, cache', innerSalt, unCacheKey)
import Foreign as Foreign
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Effect.Exception (Error)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, queryEdge, tryQueryEdge)
import Run (AFF, EFFECT, Run, interpret, on, send)
import Type.Row (type (+))
import Util.Crypto.Hash (xxhash64)

ensureCacheTable :: ∀ fx. Run (EFFECT + AFF + READER_POSTGRES_EDGE_CLIENT + fx) Ɩ
ensureCacheTable = do
  _ <- queryEdge "CREATE UNLOGGED TABLE IF NOT EXISTS cache (key TEXT PRIMARY KEY, value JSONB, expires_at TIMESTAMP WITH TIME ZONE, key_prehash_payload JSONB)" []
  η ι

queryWithRetry
  :: ∀ fx
   . String
  -> Array Foreign
  -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) (Array Foreign)
queryWithRetry sql params = do
  resOrErr <- tryQueryEdge sql params
  case resOrErr of
    Right r -> η r
    Left _ -> do
      ensureCacheTable
      queryEdge sql params

deleteExpiredCache :: ∀ fx. Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) (Either Error (Array Foreign))
deleteExpiredCache = tryQueryEdge "DELETE FROM cache WHERE expires_at < NOW()" []

deleteExpiredCache_ :: ∀ fx. Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) Ɩ
deleteExpiredCache_ = ø deleteExpiredCache

buildCacheKeyString :: ∀ fx. CacheKey -> Run (EFFECT + AFF + fx) String
buildCacheKeyString key = do
  let { prefix, payload, invalidationVersion, subject } = unCacheKey key
  hash <- ʌ' $ xxhash64 $ JSON.writeJSON payload
  subHash <- case subject of
    Nothing -> η "0"
    Just s -> ʌ' $ xxhash64 $ JSON.writeJSON s
  invHash <- ʌ' $ xxhash64 $ invalidationVersion
  η $ prefix <> "_pld_" <> hash <> "_sub_" <> subHash <> "_inv_" <> invHash <> "_slt_" <> innerSalt

interpretCache
  :: ∀ fx a
   . Run (CACHE + EFFECT + AFF + READER_POSTGRES_EDGE_CLIENT + fx) a
  -> Run (EFFECT + AFF + READER_POSTGRES_EDGE_CLIENT + fx) a
interpretCache = interpret (on cache' handle send)
  where
  handle :: ∀ fx' a'. Cache a' -> Run (EFFECT + AFF + READER_POSTGRES_EDGE_CLIENT + fx') a'
  handle (Get key next) = do
    keyStr <- buildCacheKeyString key
    let q = "SELECT value FROM cache WHERE key = $1 AND expires_at > NOW()"
    res <- queryWithRetry q [ Foreign.unsafeToForeign keyStr ]
    let
      mValue = do
        row <- Array.head res
        obj <- hush (runExcept (JSON.readImpl row :: F (Object.Object Foreign)))
        Object.lookup "value" obj
    η $ next mValue

  handle (Set key ttlSec value next) = do
    keyStr <- buildCacheKeyString key
    let { payload } = unCacheKey key
    let q = "INSERT INTO cache (key, value, expires_at, key_prehash_payload) VALUES ($1, $2, NOW() + ($3 || ' seconds')::interval, $4) ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, expires_at = EXCLUDED.expires_at, key_prehash_payload = EXCLUDED.key_prehash_payload"
    _ <- queryWithRetry q [ Foreign.unsafeToForeign keyStr, value, Foreign.unsafeToForeign ttlSec, payload ]
    η $ next ι
