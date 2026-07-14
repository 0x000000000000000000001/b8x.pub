module Core.Feat.Membership.Message.Command.ConsumeMagicLink.Command
  ( ConsumeMagicLink(..)
  ) where

import Proem

import Core.Feat.Membership.Message.Command.ConsumeMagicLink.Payload (Fields, Payload)
import Core.Feat.Membership.Message.Command.ConsumeMagicLink.Result (Result)
import Core.Feat.Membership.Message.Command.ConsumeMagicLink.State (State)
import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (exceptLogic')
import Core.Mod.User.MagicLink.Token.Exception.InvalidOrExpiredToken (InvalidOrExpiredToken(..))
import Core.Feat.Membership.Message.Command.RegisterUser.RegisterUser (childRegisterUser)
import Core.Feat.Effect.Generate as Generate
import Core.Feat.Effect.Cache as Cache
import Core.Mod.Email.Email (Email)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Foreign (Foreign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Data.Variant as Variant
import Core.Mod.User.MagicLink.Token.Exception.AlreadyLoggedInSameUser (AlreadyLoggedInSameUser(..))
import Core.Mod.Trace.Trace as Trace
import Core.Mod.Trace.Cause (CauseNode(..))
import Core.Mod.Trace.Subject (Subject(..))
import Core.Feat.Membership.Message.Command.Service.VerifyEmailUniqueness (verifyEmailUniqueness)
import Core.Mod.User.Exception.UserAlreadyRegistered (UserAlreadyRegistered(..))
import Core.Feat.Membership.Message.Command.Exception.EmailAlreadyTaken (EmailAlreadyTaken(..))
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Data.Either (Either(..))
import Run.Except (catchAt, throwAt)
import Core.Mod.User.Auth.Constant (refreshTokenTtlSec)

newtype ConsumeMagicLink = ConsumeMagicLink Payload

derive instance Newtype ConsumeMagicLink _
derive instance Generic ConsumeMagicLink _
derive newtype instance Random ConsumeMagicLink
derive newtype instance WriteForeign ConsumeMagicLink
derive newtype instance ReadForeign ConsumeMagicLink

instance Reflect ConsumeMagicLink where
  reflectName = reflectConstructorName @ConsumeMagicLink

type CachePayload = { email :: Email, validUntil :: Number }

instance IsProtectedAgainstConcurrency ConsumeMagicLink where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    ConsumeMagicLink
    State
    Fields
    Payload
    Result
  where
  description = "Verify a magic link and authenticate the user"

  handle payload = do
    let cacheKey = Cache.cacheKey "magic_link" payload.token "" (Nothing :: Maybe Foreign)

    mPayload :: Maybe CachePayload <- Cache.get cacheKey
    case mPayload of
      Nothing -> throw (InvalidOrExpiredToken {})
      Just cachePayload -> do
        now <- Generate.now
        if now > cachePayload.validUntil then do
          currentTrace <- Trace.askTrace
          let
            mSubject = case currentTrace.cause of
              Just (Command { subject }) -> subject
              _ -> Nothing

          case mSubject of
            Just (IdentifiedUiHuman p) -> do
              let currentUserId = p.userId
              takenEither <- catchAt exceptLogic' (\e -> η (Left e)) (Right <$> verifyEmailUniqueness cachePayload.email)
              case takenEither of
                Left logicError -> case Variant.prj (π @"Core.Feat.Membership.Message.Command.Exception.EmailAlreadyTaken") (unwrap logicError) of
                  Just (EmailAlreadyTaken { existingUserId }) -> do
                    if existingUserId == currentUserId then do
                      throw (AlreadyLoggedInSameUser {})
                    else do
                      throw (InvalidOrExpiredToken {})
                  Nothing -> do
                    throw (InvalidOrExpiredToken {})
                Right _ -> do
                  throw (InvalidOrExpiredToken {})
            _ -> do
              throw (InvalidOrExpiredToken {})
        else ηι

        Cache.set cacheKey refreshTokenTtlSec { email: cachePayload.email, validUntil: 0.0 }

        userIdToRegister <- Generate.generateId
        childResultEither <- catchAt exceptLogic' (\e -> η (Left e)) (Right <$> childRegisterUser { id: userIdToRegister, email: cachePayload.email })

        case childResultEither of
          Left logicError ->
            case Variant.prj (π @"Core.Mod.User.Exception.UserAlreadyRegistered") (unwrap logicError) of
              Just (UserAlreadyRegistered { existingUserId }) -> η $ Right { result: { userId: existingUserId, email: cachePayload.email }, newEvents: [] }
              Nothing -> case Variant.prj (π @"Core.Feat.Membership.Message.Command.Exception.EmailAlreadyTaken") (unwrap logicError) of
                Just (EmailAlreadyTaken { existingUserId }) -> η $ Right { result: { userId: existingUserId, email: cachePayload.email }, newEvents: [] }
                Nothing -> throwAt exceptLogic' logicError
          Right (Left tooMuchConcurrency) -> η (Left tooMuchConcurrency)
          Right (Right res) -> η $ Right { result: { userId: res.result.id, email: cachePayload.email }, newEvents: res.newEvents }

  