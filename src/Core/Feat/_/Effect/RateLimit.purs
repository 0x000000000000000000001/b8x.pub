module Core.Feat.Effect.RateLimit
  ( RATE_LIMIT
  , RateLimit(..)
  , rateLimit'
  , RateLimitBucket_
  , RateLimitBucket(..)
  , rateLimitBucket
  , unRateLimitBucket
  , consume
  , consumeOrThrow
  ) where

import Proem
import Yoga.JSON as Yoga.JSON

import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Mod.RateLimit.Exception.Index (RateLimitExceeded(..))
import Foreign (Foreign)
import Yoga.JSON (class WriteForeign, writeImpl)
import Run (Run, lift)
import Type.Row (type (+))

type RateLimitBucket_ =
  { prefix :: String
  , payload :: Foreign
  , invalidationVersion :: String
  }

newtype RateLimitBucket = RateLimitBucket RateLimitBucket_

unRateLimitBucket :: RateLimitBucket -> RateLimitBucket_
unRateLimitBucket (RateLimitBucket k) = k

rateLimitBucket :: ∀ v p. WriteForeign p => WriteForeign v => String -> p -> v -> RateLimitBucket
rateLimitBucket prefix payload invalidationVersion = RateLimitBucket
  { prefix
  , payload: writeImpl payload
  , invalidationVersion: invalidationVersion # Yoga.JSON.writeJSON
  }

data RateLimit a = Consume
  { key :: RateLimitBucket
  , points :: Int
  , durationSec :: Int
  }
  (Boolean -> a)

derive instance Functor RateLimit

type RATE_LIMIT fx = (rateLimit :: RateLimit | fx)

rateLimit' = π :: Π "rateLimit"

consume :: ∀ fx. RateLimitBucket -> Int -> Int -> Run (RATE_LIMIT + fx) Boolean
consume key points durationSec = lift rateLimit' (Consume { key, points, durationSec } identity)

consumeOrThrow :: ∀ fx. RateLimitBucket -> Int -> Int -> Run (RATE_LIMIT + EXCEPT_LOGIC + fx) Ɩ
consumeOrThrow key points durationSec = do
  allowed <- consume key points durationSec
  unless allowed $ throw RateLimitExceeded
