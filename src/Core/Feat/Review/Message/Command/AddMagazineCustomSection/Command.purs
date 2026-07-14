module Core.Feat.Review.Message.Command.AddMagazineCustomSection.Command
  ( AddMagazineCustomSection(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Decide (decide)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Filter (filter)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Play (play)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Result (Result, toResult)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype AddMagazineCustomSection = AddMagazineCustomSection Payload

derive instance Newtype AddMagazineCustomSection _
derive instance Generic AddMagazineCustomSection _
derive newtype instance Random AddMagazineCustomSection
derive newtype instance WriteForeign AddMagazineCustomSection
derive newtype instance ReadForeign AddMagazineCustomSection

instance Reflect AddMagazineCustomSection where
  reflectName = reflectConstructorName @AddMagazineCustomSection

instance IsProtectedAgainstConcurrency AddMagazineCustomSection where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    AddMagazineCustomSection
    State
    Fields
    Payload
    Result
  where
  description = "Add a magazine custom section"

  handle payload =
    defaultHandle @AddMagazineCustomSection (Just filter)
      defaultCheckLoadedEvents
      initialState
      play
      decide
      toResult
      payload

  