module Core.Feat.Review.Message.Command.ScheduleNewsletter.Payload where

import Core.Mod.Newsletter.Id.Message.Field.AutoId (Id, IdField)
import Core.Mod.Newsletter.ScheduledFor.Message.Field (ScheduledFor, ScheduledForField)
import Core.Mod.Newsletter.Articles.Message.Field (Articles, ArticlesField)

type Payload =
  { id :: Id
  , scheduledFor :: ScheduledFor
  , articles :: Articles
  }

type Fields =
  (id :: IdField
  , scheduledFor :: ScheduledForField
  , articles :: ArticlesField
  )
