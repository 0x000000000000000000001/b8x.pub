module Core.Mod.NewsTopic.Id.Id
  (NewsTopicId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id
import Core.Mod.NewsTopic.NewsTopic (NewsTopic)

type NewsTopicId = Id.Id NewsTopic
