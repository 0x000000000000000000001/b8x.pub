module Core.Feat.Membership.Message.Query.GetUserAccount.Projection.Projection where

import Proem hiding (add)

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.UserEmailChanged.Payload as UserEmailChanged
import Core.Event.UserRegistered.Payload as UserRegistered
import Core.Event.UserUnregistered.Payload as UserUnregistered
import Core.Mod.Email.Email (Email)
import Core.Mod.Projection.Finder.Finder (Find, findOneByKey)
import Core.Mod.Projection.Pair (class IsPair, class ToPrimary, class ToAliases)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete, patch, get)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Mod.User.Id.Id (UserId)
import Core.Mod.Time.Instant (Instant)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random)
import Util.Type.String.ToString (toString)
import Data.Array as Array

data GetUserAccountProjection

instance
  IsProjection
    GetUserAccountProjection
    "getUserAccount"
    "getUserAccountProjectionWriteOps"
    (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS ())
    "getUserAccountProjectionReadSyncProject"
    { account :: Account, donation :: Donation }
    { account :: AccountIndexNeeds, donation :: DonationIndexNeeds }
    { account :: {}, donation :: {} }
  where
  indexNeeds = { account: {}, donation: {} }

  play = coerce @(GET_USER_ACCOUNT_PROJECTION_WRITE_OPS ()) play

type GET_USER_ACCOUNT_PROJECTION_WRITE_OPS fx = (getUserAccountProjectionWriteOps :: ProjectionWriteOps | fx)
type GET_USER_ACCOUNT_PROJECTION_READ_SYNC_PROJECT fx = (getUserAccountProjectionReadSyncProject :: SyncProject | fx)
type GET_USER_ACCOUNT_PROJECTION_READ_FIND fx = GET_USER_ACCOUNT_ACCOUNT_PROJECTION_READ_FIND
  + GET_USER_ACCOUNT_DONATION_PROJECTION_READ_FIND
  + fx

-- Model

instance
  IsPair
    AccountKey
    Account
    AccountRecord
    AccountIndexNeeds
    ()
    "account"
    "accounts"
    "getUserAccountAccountProjectionReadFind"
    GetUserAccountProjection
  where
  toKey (Account { id }) = AccountKey id

  single = false

newtype Account = Account AccountRecord

instance ToAliases Account where
  toAliases _ = []

type AccountRecord =
  { id :: UserId
  , email :: Email
  }

type AccountIndexNeeds = {}

derive instance Newtype Account _
derive instance Generic Account _
derive instance Eq Account
derive instance Ord Account
derive newtype instance ReadForeign Account
derive newtype instance WriteForeign Account
derive newtype instance Random Account

newtype AccountKey = AccountKey UserId

derive instance Generic AccountKey _
derive instance Eq AccountKey
derive instance Ord AccountKey
instance ToPrimary AccountKey where
  toPrimary (AccountKey id) = toString id

instance
  IsPair
    DonationKey
    Donation
    DonationRecord
    DonationIndexNeeds
    ()
    "donation"
    "donations"
    "getUserAccountDonationProjectionReadFind"
    GetUserAccountProjection
  where
  toKey (Donation { email }) = DonationKey email
  single = false

newtype Donation = Donation DonationRecord

instance ToAliases Donation where
  toAliases _ = []

type DonationRecord =
  { email :: Email
  , history :: Array { amount :: Int, date :: Instant }
  }

type DonationIndexNeeds = {}

derive instance Newtype Donation _
derive instance Generic Donation _
derive instance Eq Donation
derive instance Ord Donation
derive newtype instance ReadForeign Donation
derive newtype instance WriteForeign Donation
derive newtype instance Random Donation

newtype DonationKey = DonationKey Email

derive instance Generic DonationKey _
derive instance Eq DonationKey
derive instance Ord DonationKey
instance ToPrimary DonationKey where
  toPrimary (DonationKey id) = toString id

-- Find

type GET_USER_ACCOUNT_ACCOUNT_PROJECTION_READ_FIND fx = (getUserAccountAccountProjectionReadFind :: Find Account | fx)
type GET_USER_ACCOUNT_DONATION_PROJECTION_READ_FIND fx = (getUserAccountDonationProjectionReadFind :: Find Donation | fx)
type GET_USER_ACCOUNT_ACCOUNT_PROJECTION_READ fx =
  GET_USER_ACCOUNT_ACCOUNT_PROJECTION_READ_FIND
    + GET_USER_ACCOUNT_PROJECTION_READ_SYNC_PROJECT
    + fx

findAccount :: ∀ fx. UserId -> Run (GET_USER_ACCOUNT_ACCOUNT_PROJECTION_READ + fx) (Maybe Account)
findAccount = findOneByKey ◁ AccountKey

findDonation :: ∀ fx. Email -> Run (GET_USER_ACCOUNT_DONATION_PROJECTION_READ_FIND + GET_USER_ACCOUNT_PROJECTION_READ_SYNC_PROJECT + fx) (Maybe Donation)
findDonation = findOneByKey ◁ DonationKey

-- Play

play :: ∀ fx. LoadedEvent -> Run (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  UserRegistered payload -> onUserRegistered payload
  UserEmailChanged payload -> onUserEmailChanged payload
  UserUnregistered payload -> onUserUnregistered payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
  BookEditorCorrected _ -> ηι
  BookCoverCorrected _ -> ηι
  ArticleTitleCorrected _ -> ηι
  ArticleContentCorrected _ -> ηι
  AuthorBiographyCorrected _ -> ηι
  MagazineIssueReferenced _ -> ηι
  MagazineIssueDereferenced _ -> ηι
  EditorReferenced _ -> ηι
  EditorDereferenced _ -> ηι
  ArticleDiscarded _ -> ηι
  ArticleFeaturedOnFrontPage _ -> ηι
  ArticleWritten _ -> ηι
  ArticleQuoted _ -> ηι
  NewsTopicAdded _ -> ηι
  NewsTopicRemoved _ -> ηι
  ArticleAddedToNewsRelatedWhitelist _ -> ηι
  ArticleRemovedFromNewsRelatedWhitelist _ -> ηι
  ArticleAddedToNewsRelatedBlacklist _ -> ηι
  ArticleRemovedFromNewsRelatedBlacklist _ -> ηι
  ArticleRead _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated payload -> onUserDonated payload
  NewsletterScheduled _ -> ηι

onUserRegistered :: ∀ fx. UserRegistered.Payload -> Run (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS fx) Ɩ
onUserRegistered { id, email } = add $ Account { id, email }

onUserEmailChanged :: ∀ fx. UserEmailChanged.Payload -> Run (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS fx) Ɩ
onUserEmailChanged { user, email } = patch (AccountKey user) \(Account a) -> Account (a { email = email })

onUserUnregistered :: ∀ fx. UserUnregistered.Payload -> Run (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS fx) Ɩ
onUserUnregistered { user } = delete $ AccountKey user

onUserDonated :: ∀ fx. { thirdPartyEmail :: Email, donatedAt :: Instant, amount :: Int } -> Run (GET_USER_ACCOUNT_PROJECTION_WRITE_OPS fx) Ɩ
onUserDonated { thirdPartyEmail, donatedAt, amount } = do
  mDonation <- get (DonationKey thirdPartyEmail)
  case mDonation of
    Just (Donation _) -> do
      patch (DonationKey thirdPartyEmail) \(Donation doc) -> 
        Donation (doc { history = Array.snoc doc.history { amount, date: donatedAt } })
    Nothing -> add $ Donation { email: thirdPartyEmail, history: [ { amount, date: donatedAt } ] }
