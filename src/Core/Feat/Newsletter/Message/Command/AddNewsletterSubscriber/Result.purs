module Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Result where

import Proem

import Core.Event.Event (Event)
import Run (Run)

type Result = Ɩ

toResult :: ∀ payload state fx. payload -> state -> Array Event -> Run fx Result
toResult _ _ _ = η ι
