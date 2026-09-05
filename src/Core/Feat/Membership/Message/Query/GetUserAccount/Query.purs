module Core.Feat.Membership.Message.Query.GetUserAccount.Query where

import Proem

import Core.Feat.Membership.Message.Query.GetUserAccount.Payload (Payload, Fields)
import Core.Feat.Membership.Message.Query.GetUserAccount.Result (Result)
import Core.Feat.Membership.Message.Query.GetUserAccount.State (State)
import Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Projection (Account(..), AccountKey(..), findAccount, Donation(..), findDonation)
import Core.Message.Query.Query (class IsQuery, CacheStrategy(..), defaultCached, defaultCachedWithSubject)
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Exception.Exception (throw)
import Core.Mod.User.Exception.UserNotRegistered (UserNotRegistered(..))
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result as QueryResult
import Core.Mod.Time.Instant (Instant(..))
import Data.DateTime.Instant (unInstant)
import Data.Time.Duration (Milliseconds(..))
import Core.Feat.Effect.Generate (now)
import Core.Feat.Membership.Message.Query.GetUserAccount.Field.Needs (Needs(..))
import Core.Mod.User.Id.Message.Field.TargetUser (TargetUser(..))
import Core.Mod.Trace.Trace (askSubject)
import Core.Mod.Trace.Subject (Subject(..))
import Core.Mod.Id.Id as Id

newtype GetUserAccount = GetUserAccount Payload

derive instance Newtype GetUserAccount _
derive instance Generic GetUserAccount _
derive newtype instance Random GetUserAccount
derive newtype instance WriteForeign GetUserAccount
derive newtype instance ReadForeign GetUserAccount

instance Reflect GetUserAccount where
  reflectName = reflectConstructorName @GetUserAccount

instance
  IsQuery
    GetUserAccount
    State
    Fields
    Payload
    Result where
  description = "Get the account of a user"

  cacheStrategy _ = η NotCached

  handle (GetUserAccount { user, needs: Needs needs }) = do
    actualUser <- case user of
      Me -> do
        mSubject <- askSubject
        case mSubject of
          Just (IdentifiedUiHuman { userId }) -> η userId
          _ -> throw (UserNotRegistered (Id.unsafeFromString ""))
      ById id -> η id
    mAccount <- findAccount actualUser
    case mAccount of
      Just (Account { email }) -> do
        let
          calcSubscriptionStatus need = case need of
            NotNeeded -> η QueryResult.NotGivenBecauseNotNeeded
            Needed _ _ -> do
              mDonation <- findDonation email
              case mDonation of
                Nothing -> η (QueryResult.Given false)
                Just (Donation { latestDonation: Instant ld }) -> do
                  currentMs <- now
                  let Milliseconds ldMs = unInstant ld
                  let oneYearMs = 365.25 * 24.0 * 60.0 * 60.0 * 1000.0
                  η (QueryResult.Given (currentMs - ldMs < oneYearMs))

        adFreeRes <- calcSubscriptionStatus needs.adFree
        hasPaidLastYearRes <- calcSubscriptionStatus needs.hasPaidLastYear
        η $ { email, adFree: adFreeRes, hasPaidLastYear: hasPaidLastYearRes }

      Nothing -> throw $ UserNotRegistered actualUser