module Core.Feat.Membership.Message.Query.GetUserAccount.Query where

import Proem

import Core.Feat.Membership.Message.Query.GetUserAccount.Payload (Payload, Fields)
import Core.Feat.Membership.Message.Query.GetUserAccount.Result (Result)
import Core.Feat.Membership.Message.Query.GetUserAccount.State (State)
import Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Projection (Account(..), Donation(..), findAccount, findDonation)
import Core.Message.Query.Query (class IsQuery, CacheStrategy(..))
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
import Data.Array as Array

-- | Minimum amount, in cents, donated over the recent window for a user to be
-- | considered as a supporter (e.g. to disable ads).
minSupportAmountCents :: Int
minSupportAmountCents = 400

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

  cacheStrategy _ = η NotCached -- We get info from the outside (e.g., HelloAsso)

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
                Nothing -> do
                  η (QueryResult.Given false)
                Just (Donation { history }) -> do
                  currentMs <- now
                  let recentWindowMs = 35.0 * 24.0 * 60.0 * 60.0 * 1000.0
                  let
                    recentDonations = Array.filter
                      ( \d ->
                          let
                            Milliseconds dMs = unInstant (let (Instant inst) = d.date in inst)
                          in
                            currentMs - dMs <= recentWindowMs
                      )
                      history
                  let totalDonated = Array.foldl (\acc d -> acc + d.amount) 0 recentDonations
                  η (QueryResult.Given (totalDonated >= minSupportAmountCents))

        adFreeRes <- calcSubscriptionStatus needs.adFree
        hasPaidLastYearRes <- calcSubscriptionStatus needs.hasPaidLastYear
        η $ { email, adFree: adFreeRes, hasPaidLastYear: hasPaidLastYearRes }

      Nothing -> throw $ UserNotRegistered actualUser
