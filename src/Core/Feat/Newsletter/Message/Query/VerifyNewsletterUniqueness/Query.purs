module Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Query where

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Payload (Payload, Fields)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Projection.Projection (Filter(..), Newsletter(..), findNewsletters)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Result (Result)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Newsletter.Exception.NewsletterAlreadyScheduled (NewsletterAlreadyScheduled(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Time.Instant (Instant(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.DateTime.Instant (unInstant, instant) as Base
import Data.Foldable (any)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Number as Math
import Data.Time.Duration (Milliseconds(..))
import Util.Type.Limit (Limit(..))
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyNewsletterUniqueness = VerifyNewsletterUniqueness Payload

derive instance Newtype VerifyNewsletterUniqueness _
derive instance Generic VerifyNewsletterUniqueness _
derive newtype instance Random VerifyNewsletterUniqueness
derive newtype instance WriteForeign VerifyNewsletterUniqueness
derive newtype instance ReadForeign VerifyNewsletterUniqueness

instance Reflect VerifyNewsletterUniqueness where
  reflectName = reflectConstructorName @VerifyNewsletterUniqueness

instance IsQuery VerifyNewsletterUniqueness State Fields Payload Result where
  description = "Verify newsletter uniqueness"

  cacheStrategy _ = do
    hash <- getReadModelHash @Newsletter Nothing
    η $ defaultCached hash

  handle (VerifyNewsletterUniqueness { scheduledFor: scheduledForObj, articles: articlesObj }) = do
    let
      scheduledFor = scheduledForObj
      newArticles = articlesObj
      oneMonthMs = 3600.0 * 24.0 * 30.0 * 1000.0
      (Instant baseInstant) = scheduledFor
      (Milliseconds ms) = Base.unInstant baseInstant
      minDate = Instant (Base.instant (Milliseconds (ms - oneMonthMs)) ??⇒ bottom)
      maxDate = Instant (Base.instant (Milliseconds (ms + oneMonthMs)) ??⇒ bottom)

    page <- findNewsletters
      ( defaultFindOpt
          { filter = Just (ScheduledForBetween minDate maxDate)
          , limit = Infinite
          }
      )

    let
      isUnique = not $ flip any page.items \(Newsletter n) ->
        if n.scheduledFor == scheduledFor then true
        else if n.articles == newArticles then
          let
            (Instant existingBase) = n.scheduledFor
            (Instant newBase) = scheduledFor
            (Milliseconds existingMs) = Base.unInstant existingBase
            (Milliseconds newMs) = Base.unInstant newBase
            diff = existingMs - newMs
            absDiff = Math.abs diff
          in
            absDiff < oneMonthMs
        else false

    when (not isUnique) $ throw NewsletterAlreadyScheduled

    η {}
