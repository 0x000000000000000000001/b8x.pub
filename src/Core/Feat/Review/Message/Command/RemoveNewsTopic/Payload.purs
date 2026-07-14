module Core.Feat.Review.Message.Command.RemoveNewsTopic.Payload where

import Core.Mod.NewsTopic.Id.Message.Field.NewsTopic (NewsTopic, NewsTopicField)

type Payload =
  { newsTopic :: NewsTopic
  }

type Fields =
  (newsTopic :: NewsTopicField
  )
