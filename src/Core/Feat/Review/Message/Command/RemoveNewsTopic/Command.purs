module Core.Feat.Review.Message.Command.RemoveNewsTopic.Command
  ( RemoveNewsTopic(..)
  , RemoveNewsTopicAliasRow
  )
  where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Decide (decide)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Filter (filter)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Play (play)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Result (Result, toResult)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype RemoveNewsTopic = RemoveNewsTopic Payload

derive instance Newtype RemoveNewsTopic _
derive instance Generic RemoveNewsTopic _
derive newtype instance Random RemoveNewsTopic
derive newtype instance WriteForeign RemoveNewsTopic
derive newtype instance ReadForeign RemoveNewsTopic

instance Reflect RemoveNewsTopic where
  reflectName = reflectConstructorName @RemoveNewsTopic

instance IsProtectedAgainstConcurrency RemoveNewsTopic where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    RemoveNewsTopic
    State
    Fields
    Payload
    Result
  where
  description = "Remove a news topic"

  handle = defaultHandle @RemoveNewsTopic (Just filter) defaultCheckLoadedEvents initialState play decide toResult

type RemoveNewsTopicAliasRow r =
  ( "RemoveANewsTopic" :: RemoveNewsTopic
  , "JeterSujetDActualite" :: RemoveNewsTopic
  , "JeterSujetActualite" :: RemoveNewsTopic
  , "JeterUnSujetDActualite" :: RemoveNewsTopic
  , "JeterUnSujetActualite" :: RemoveNewsTopic
  , "JetteSujetDActualite" :: RemoveNewsTopic
  , "JetteSujetActualite" :: RemoveNewsTopic
  , "JetteUnSujetDActualite" :: RemoveNewsTopic
  , "JetteUnSujetActualite" :: RemoveNewsTopic
  , "SupprimerSujetActualite" :: RemoveNewsTopic
  , "SupprimerSujetDActualite" :: RemoveNewsTopic
  , "SupprimerUnSujetActualite" :: RemoveNewsTopic
  , "SupprimerUnSujetDActualite" :: RemoveNewsTopic
  , "SuppressionSujetActualite" :: RemoveNewsTopic
  , "SuppressionSujetDActualite" :: RemoveNewsTopic
  , "SuppressionDeSujetActualite" :: RemoveNewsTopic
  , "SuppressionDeSujetDActualite" :: RemoveNewsTopic
  , "SuppressionDUnSujetActualite" :: RemoveNewsTopic
  , "SuppressionDUnSujetDActualite" :: RemoveNewsTopic
  , "SupprimeSujetActualite" :: RemoveNewsTopic
  , "SupprimeSujetDActualite" :: RemoveNewsTopic
  , "SupprimeUnSujetActualite" :: RemoveNewsTopic
  , "SupprimeUnSujetDActualite" :: RemoveNewsTopic
  , "RetirerSujetActualite" :: RemoveNewsTopic
  , "RetirerSujetDActualite" :: RemoveNewsTopic
  , "RetirerUnSujetActualite" :: RemoveNewsTopic
  , "RetirerUnSujetDActualite" :: RemoveNewsTopic
  , "RetireSujetActualite" :: RemoveNewsTopic
  , "RetireSujetDActualite" :: RemoveNewsTopic
  , "RetireUnSujetActualite" :: RemoveNewsTopic
  , "RetireUnSujetDActualite" :: RemoveNewsTopic
  , "RetraitSujetActualite" :: RemoveNewsTopic
  , "RetraitSujetDActualite" :: RemoveNewsTopic
  , "RetraitDeSujetActualite" :: RemoveNewsTopic
  , "RetraitDeSujetDActualite" :: RemoveNewsTopic
  , "RetraitDUnSujetActualite" :: RemoveNewsTopic
  , "RetraitDUnSujetDActualite" :: RemoveNewsTopic
  , "EffacerSujetActualite" :: RemoveNewsTopic
  , "EffacerSujetDActualite" :: RemoveNewsTopic
  , "EffacerUnSujetActualite" :: RemoveNewsTopic
  , "EffacerUnSujetDActualite" :: RemoveNewsTopic
  , "EffaceSujetActualite" :: RemoveNewsTopic
  , "EffaceSujetDActualite" :: RemoveNewsTopic
  , "EffaceUnSujetActualite" :: RemoveNewsTopic
  , "EffaceUnSujetDActualite" :: RemoveNewsTopic
  , "EffacementSujetActualite" :: RemoveNewsTopic
  , "EffacementSujetDActualite" :: RemoveNewsTopic
  , "EffacementDeSujetActualite" :: RemoveNewsTopic
  , "EffacementDeSujetDActualite" :: RemoveNewsTopic
  , "EffacementDUnSujetActualite" :: RemoveNewsTopic
  , "EffacementDUnSujetDActualite" :: RemoveNewsTopic
  | r
  )