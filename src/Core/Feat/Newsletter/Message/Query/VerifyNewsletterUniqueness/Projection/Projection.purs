module Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Projection.Projection where

import Proem hiding (add)

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.NewsletterScheduled.Payload as NewsletterScheduled
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Time.Instant (Instant)
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Finder.Filter (class IsFilter, GreaterThan(..), LessThan(..), by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

data VerifyNewsletterUniquenessProjection

instance
  IsProjection
    VerifyNewsletterUniquenessProjection
    "verifyNewsletterUniqueness"
    "verifyNewsletterUniquenessProjectionWriteOps"
    (VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_OPS ())
    "verifyNewsletterUniquenessProjectionReadSyncProject"
    { verifyNewsletterUniqueness :: Newsletter }
    { verifyNewsletterUniqueness :: NewsletterIndexNeeds }
    { verifyNewsletterUniqueness :: Record () }
  where
  indexNeeds =
    { verifyNewsletterUniqueness:
        { id: rawIndexOnly
        , scheduledFor: rawIndexOnly
        }
    }

  play = coerce @(VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_OPS ()) play

type VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_OPS fx = (verifyNewsletterUniquenessProjectionWriteOps :: ProjectionWriteOps | fx)
type VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT fx = (verifyNewsletterUniquenessProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    NewsletterKey
    Newsletter
    NewsletterRecord
    NewsletterIndexNeeds
    ()
    "verifyNewsletterUniqueness"
    "verifyNewsletterUniquenessNewsletters"
    "verifyNewsletterUniquenessProjectionReadFind"
    VerifyNewsletterUniquenessProjection
  where
  toKey (Newsletter { id }) = NewsletterKey id
  single = false

newtype Newsletter = Newsletter NewsletterRecord

type NewsletterRecord =
  { id :: NewsletterId
  , scheduledFor :: Instant
  , articles :: Array ArticleId
  }

type NewsletterIndexNeeds =
  { id :: RawIndexOnly NewsletterId
  , scheduledFor :: RawIndexOnly Instant
  }

derive instance Newtype Newsletter _
derive instance Generic Newsletter _
derive instance Eq Newsletter
derive instance Ord Newsletter
derive newtype instance ReadForeign Newsletter
derive newtype instance WriteForeign Newsletter

newtype NewsletterKey = NewsletterKey NewsletterId

derive instance Newtype NewsletterKey _
instance ToAliasedPrimary NewsletterKey where
  toAliasedPrimary (NewsletterKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq NewsletterKey
derive newtype instance Ord NewsletterKey

-- Find

type VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ_FIND fx = (verifyNewsletterUniquenessProjectionReadFind :: Find Newsletter | fx)
type VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ fx =
  VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ_FIND
    + VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT
    + fx

-- Filter

data Filter
  = ScheduledForBetween Instant Instant
  | And Filter Filter
  | Or Filter Filter
  | Not Filter
  | True
  | False

derive instance Eq Filter
derive instance Ord Filter
derive instance Generic Filter _
instance Show Filter where
  show filter = genericShow filter

instance HeytingAlgebra Filter where
  ff = False
  tt = True
  not = Not
  implies a b = (Not a) || b
  conj = And
  disj = Or

instance IsFilter Filter Newsletter where
  compile _ (ScheduledForBetween start end) =
    (by @"scheduledFor" GreaterThan start)
      && (by @"scheduledFor" LessThan end)
  compile e (And f1 f2) = (compile e f1) && (compile e f2)
  compile e (Or f1 f2) = (compile e f1) || (compile e f2)
  compile e (Not f) = not (compile e f)
  compile _ True = Base.True
  compile _ False = Base.False

findNewsletters
  :: ∀ fx
   . FindOpt Filter NewsletterId Newsletter
  -> Run (VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_READ + fx) (Page Newsletter)
findNewsletters opt = findMany_ opt { after = opt.after <#> NewsletterKey ▷ persistenceKeyFromKey }

-- Play

play :: ∀ fx. LoadedEvent -> Run (VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  NewsletterScheduled payload -> onNewsletterScheduled payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
  MagazineIssueReferenced _ -> ηι
  MagazineIssueDereferenced _ -> ηι
  EditorReferenced _ -> ηι
  EditorDereferenced _ -> ηι
  UserEmailChanged _ -> ηι
  UserRegistered _ -> ηι
  UserUnregistered _ -> ηι
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
  UserDonated _ -> ηι

onNewsletterScheduled :: ∀ fx. NewsletterScheduled.Payload -> Run (VERIFY_NEWSLETTER_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onNewsletterScheduled { id, scheduledFor, articles } = add $ Newsletter { id, scheduledFor, articles }
