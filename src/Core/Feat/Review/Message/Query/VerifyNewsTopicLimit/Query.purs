module Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Payload (Payload, Fields)
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Projection.Projection (NewsTopic, findAllNewsTopics)
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Result (Result)
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.NewsTopic.Exception.TooManyNewsTopicsAdded (TooManyNewsTopicsAdded(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyNewsTopicLimit = VerifyNewsTopicLimit Payload

derive instance Newtype VerifyNewsTopicLimit _
derive instance Generic VerifyNewsTopicLimit _
derive newtype instance Random VerifyNewsTopicLimit
derive newtype instance WriteForeign VerifyNewsTopicLimit
derive newtype instance ReadForeign VerifyNewsTopicLimit

instance Reflect VerifyNewsTopicLimit where
  reflectName = reflectConstructorName @VerifyNewsTopicLimit

instance IsQuery VerifyNewsTopicLimit State Fields Payload Result where
  description = "Verify news topic max limit"

  cacheStrategy _ = do
    hash <- getReadModelHash @NewsTopic Nothing
    η $ defaultCached hash

  handle (VerifyNewsTopicLimit _) = do
    items <- findAllNewsTopics

    when
      (Array.length items >= 12)
      (throw $ TooManyNewsTopicsAdded 12)

    η {}
