module Infra.RateLimit.Postgres.RateLimit
  ( interpretRateLimit
  ) where

import Proem
import Yoga.JSON as Yoga.JSON

import Promise.Aff (Promise, toAffE)
import Core.Feat.Effect.RateLimit (RATE_LIMIT, RateLimit(..), rateLimit', unRateLimitBucket)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (try)
import Infra.Client.Postgres.Postgres (Handle, READER_POSTGRES_EDGE_CLIENT, askEdgeConnectionPoolHandle, queryEdge)
import Run (AFF, EFFECT, Run, interpret, on, send)
import Type.Row (type (+))
import Util.Crypto.Hash (xxhash64)

foreign import _consume :: ∀ s t. Handle s t -> String -> Int -> Int -> Effect (Promise Boolean)

ensureRateLimitTable :: ∀ fx. Run (EFFECT + AFF + READER_POSTGRES_EDGE_CLIENT + fx) Ɩ
ensureRateLimitTable = ø $ queryEdge "CREATE TABLE IF NOT EXISTS rate_limit (key varchar(255) PRIMARY KEY, points integer NOT NULL DEFAULT 0, expire bigint)" []

interpretRateLimit
  :: ∀ fx a
   . Run (RATE_LIMIT + EFFECT + AFF + READER_POSTGRES_EDGE_CLIENT + fx) a
  -> Run (EFFECT + AFF + READER_POSTGRES_EDGE_CLIENT + fx) a
interpretRateLimit = interpret (on rateLimit' handle send)
  where
  handle :: ∀ fx' a'. RateLimit a' -> Run (EFFECT + AFF + READER_POSTGRES_EDGE_CLIENT + fx') a'
  handle (Consume { key, points: maxPoints, durationSec } next) = do
    let { prefix, payload, invalidationVersion } = unRateLimitBucket key
    hash <- ʌ' $ xxhash64 (Yoga.JSON.writeJSON payload)
    let keyStr = prefix <> "_" <> hash <> "_v" <> invalidationVersion

    pgHandle <- askEdgeConnectionPoolHandle
    resOrErr <- ʌ' $ try $ toAffE (_consume pgHandle keyStr maxPoints durationSec)

    case resOrErr of
      Right allowed -> η $ next allowed
      Left _ -> do
        ensureRateLimitTable
        allowed <- ʌ' $ toAffE (_consume pgHandle keyStr maxPoints durationSec)
        η $ next allowed
