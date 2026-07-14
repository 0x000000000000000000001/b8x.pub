module Core.Feat.Review.Message.Command.ScheduleNewsletter.Filter where

import Proem hiding ((&&), (||))

import Core.Event.Filter (Filter(..), false_)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Payload (Payload)
import Core.Mod.Article.State as Article
import Data.Foldable (foldl)

filter :: Payload -> Filter
filter { articles } =
  foldl (\acc a -> Or acc (Article.filter a)) false_ articles
