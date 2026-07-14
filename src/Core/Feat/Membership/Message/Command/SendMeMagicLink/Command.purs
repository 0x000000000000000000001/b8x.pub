module Core.Feat.Membership.Message.Command.SendMeMagicLink.Command
  ( SendMeMagicLink(..)
  ) where

import Proem
import Foreign (Foreign)

import Core.Feat.Effect.Cache as Cache
import Core.Feat.Effect.Generate as Generate
import Core.Feat.Effect.Mail as EmailService
import Core.Feat.Effect.RateLimit (consumeOrThrow, rateLimitBucket)
import Core.Feat.Membership.Message.Command.SendMeMagicLink.Payload (Fields, Payload)
import Core.Feat.Membership.Message.Command.SendMeMagicLink.Result (Result)
import Core.Feat.Membership.Message.Command.SendMeMagicLink.State (State)
import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..))
import Core.Mod.Token.Token (unsafeFromString)
import Core.Mod.User.MagicLink.Token.Message.Field.Token (Token) as MagicLink
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap)
import Data.UUID as UUID
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Mod.User.Auth.Constant (refreshTokenTtlSec)

newtype SendMeMagicLink = SendMeMagicLink Payload

derive instance Newtype SendMeMagicLink _
derive instance Generic SendMeMagicLink _
derive newtype instance Random SendMeMagicLink
derive newtype instance WriteForeign SendMeMagicLink
derive newtype instance ReadForeign SendMeMagicLink

instance Reflect SendMeMagicLink where
  reflectName = reflectConstructorName @SendMeMagicLink

instance IsProtectedAgainstConcurrency SendMeMagicLink where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    SendMeMagicLink
    State
    Fields
    Payload
    Result
  where
  description = "Request a magic link for authentication"

  handle payload = do
    -- 1 email per 60 seconds
    consumeOrThrow (rateLimitBucket "magic_link" payload.email "1") 5 60

    uuid <- Generate.generateUuid
    let tokenStr = UUID.toString uuid
    let token = unsafeFromString tokenStr :: MagicLink.Token
    let cacheKey = Cache.cacheKey "magic_link" token "" (Nothing :: Maybe Foreign)

    now <- Generate.now
    let validUntil = now + (15.0 * 60.0 * 1000.0)
    let payloadToCache = { email: payload.email, validUntil }

    -- Save email to cache with the exact same TTL as a user refresh session
    Cache.set cacheKey refreshTokenTtlSec payloadToCache

    EmailService.sendMagicLink payload.email tokenStr (unwrap payload.returnTo)

    η $ Right { result: ι, newEvents: [] }

  