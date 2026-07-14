module Infra.Cache.Fs.Cache
  ( interpretCache
  , deleteExpiredCache
  , deleteExpiredCache_
  , cacheDir
  ) where

import Data.Maybe (Maybe(..))
import Proem
import Yoga.JSON as JSON
import Control.Monad.Except as Control.Monad.Except
import Core.Feat.Effect.Cache (CACHE, Cache(..), CacheKey, cache', innerSalt, unCacheKey)
import Foreign (Foreign)
import Data.DateTime.Instant (unInstant)
import Data.Either (Either(..))
import Data.Foldable (traverse_)
import Data.Int (toNumber)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff (attempt)
import Effect.Exception (Error)
import Effect.Now (now)
import Foreign.Object as Object
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff as FS
import Node.Path as Path
import Run (AFF, EFFECT, Run, interpret, on, send)
import Type.Row (type (+))
import Util.Aff (ʌ')
import Util.Crypto.Hash (xxhash64)
import Util.File.Path (_rootDirAbsolutePath)
import Util.Type.Ulid as Ulid

cacheDir :: String
cacheDir = _rootDirAbsolutePath <> "var/api/cache"

ensureCacheDir :: ∀ fx. Run (EFFECT + AFF + fx) Ɩ
ensureCacheDir =
  ʌ' do
    _ <- attempt $ FS.mkdir (_rootDirAbsolutePath <> "var")
    _ <- attempt $ FS.mkdir (_rootDirAbsolutePath <> "var/api")
    _ <- attempt $ FS.mkdir cacheDir
    η ι

buildCacheKeyString :: ∀ fx. CacheKey -> Run (EFFECT + AFF + fx) String
buildCacheKeyString key = do
  let { prefix, payload, invalidationVersion, subject } = unCacheKey key
  hash <- ʌ' $ xxhash64 $ JSON.writeJSON payload
  subHash <- case subject of
    Nothing -> η "0"
    Just s -> ʌ' $ xxhash64 $ JSON.writeJSON s
  invHash <- ʌ' $ xxhash64 $ invalidationVersion
  η $ prefix <> "_pld_" <> hash <> "_sub_" <> subHash <> "_inv_" <> invHash <> "_slt_" <> innerSalt

getCachePath :: String -> String
getCachePath keyStr = Path.concat [ cacheDir, keyStr <> ".json" ]

type CacheEntry =
  { value :: Foreign
  , expiresAtMs :: Number
  , hashValue :: Foreign
  }



encodeCacheEntry :: CacheEntry -> Foreign
encodeCacheEntry entry =
  JSON.writeImpl
    $ Object.fromFoldable
        [ "value" /\ entry.value
        , "expiresAtMs" /\ JSON.writeImpl entry.expiresAtMs
        , "hashValue" /\ entry.hashValue
        ]

deleteExpiredCache :: ∀ fx. Run (EFFECT + AFF + fx) (Either Error (Array Foreign))
deleteExpiredCache = do
  ensureCacheDir
  filesErr <- ʌ' $ attempt $ FS.readdir cacheDir
  case filesErr of
    Left e -> η $ Left e
    Right files -> do
      currentInstant <- ʌ now
      let
        (Milliseconds currentMs) = unInstant currentInstant
      _ <-
        ʌ'
          $ traverse_
              ( \fileName ->
                  attempt do
                    let
                      filePath = Path.concat [ cacheDir, fileName ]
                    content <- FS.readTextFile UTF8 filePath
                    case (JSON.readJSON_ content :: Maybe CacheEntry) of
                      Nothing -> FS.unlink filePath
                      Just entry ->
                        if currentMs > entry.expiresAtMs then
                          FS.unlink filePath
                        else
                          pure unit
              )
              files
      η $ Right []

deleteExpiredCache_ :: ∀ fx. Run (EFFECT + AFF + fx) Ɩ
deleteExpiredCache_ = ø deleteExpiredCache

interpretCache
  :: ∀ fx a
   . Run (CACHE + EFFECT + AFF + fx) a
  -> Run (EFFECT + AFF + fx) a
interpretCache = interpret (on cache' handle send)
  where
  handle :: ∀ fx' a'. Cache a' -> Run (EFFECT + AFF + fx') a'
  handle (Get key next) = do
    keyStr <- buildCacheKeyString key
    let
      filePath = getCachePath keyStr
    fileContentErr <- ʌ' $ attempt $ FS.readTextFile UTF8 filePath
    case fileContentErr of
      Left _ -> η $ next Nothing
      Right content -> case (JSON.readJSON_ content :: Maybe CacheEntry) of
        Nothing -> do
          -- Delete corrupted file
          _ <- ʌ' $ attempt $ FS.unlink filePath
          η $ next Nothing
        Just entry -> do
          currentInstant <- ʌ now
          let
            (Milliseconds currentMs) = unInstant currentInstant
          if currentMs > entry.expiresAtMs then do
            _ <- ʌ' $ attempt $ FS.unlink filePath
            η $ next Nothing
          else do
            case Control.Monad.Except.runExcept (JSON.readImpl entry.value) of
              Left _err -> do
                _ <- ʌ' $ attempt $ FS.unlink filePath
                η $ next Nothing
              Right val ->
                η $ next (Just val)

  handle (Set key ttlSec value next) = do
    ensureCacheDir
    keyStr <- buildCacheKeyString key
    let
      filePath = getCachePath keyStr
    currentInstant <- ʌ now
    let
      (Milliseconds currentMs) = unInstant currentInstant
    ulid <- ʌ Ulid.generateUlid
    let
      -- We append a unique ULID to the tmp file name to prevent race conditions 
      -- (e.g. concurrent Set operations overwriting the same .tmp file).
      tmpFilePath = filePath <> "." <> Ulid.toString ulid <> ".tmp"
    let
      expiresAtMs = currentMs + (toNumber ttlSec * 1000.0)
    let
      { payload: keyPayload } = unCacheKey key
      entry = { value, expiresAtMs, hashValue: keyPayload }
    let
      content = JSON.writeJSON (encodeCacheEntry entry)
    _ <-
      ʌ'
        $ attempt do
            FS.writeTextFile UTF8 tmpFilePath content
            -- POSIX atomic rename: ensures that readers will never read a partially 
            -- written file, and concurrent renames simply overwrite the directory 
            -- entry pointer without corruption or downtime.
            FS.rename tmpFilePath filePath
    η $ next ι
