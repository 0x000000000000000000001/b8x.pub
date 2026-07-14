module Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Payload where

import Core.Mod.Newsletter.ScheduledFor.Message.Field (ScheduledFor, ScheduledForField)
import Core.Mod.Newsletter.Articles.Message.Field (Articles, ArticlesField)

type Payload =
  { scheduledFor :: ScheduledFor
  , articles :: Articles
  }

type Fields =
  ( scheduledFor :: ScheduledForField
  , articles :: ArticlesField
  )
