module Core.Feat.Review.Message.Command.RemoveNewsTopic.Filter where

import Proem hiding ((&&))

import Core.Event.Filter (Filter)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Payload (Payload)
import Core.Mod.NewsTopic.State as NewsTopic

filter :: Payload -> Filter
filter { newsTopic } = NewsTopic.filter newsTopic
