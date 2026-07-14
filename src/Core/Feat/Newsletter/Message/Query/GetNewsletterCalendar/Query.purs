module Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Query where

import Proem

import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Payload (Payload)
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Result (Result(..))
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.State (State)
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Projection.Projection (Calendar, findCalendar)
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Map as Map
import Data.Newtype (class Newtype, unwrap)
import Data.Maybe (Maybe(..))
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype GetNewsletterCalendar = GetNewsletterCalendar Payload

derive instance Newtype GetNewsletterCalendar _
derive instance Generic GetNewsletterCalendar _
derive newtype instance Random GetNewsletterCalendar
derive newtype instance WriteForeign GetNewsletterCalendar
derive newtype instance ReadForeign GetNewsletterCalendar

instance Reflect GetNewsletterCalendar where
  reflectName = reflectConstructorName @GetNewsletterCalendar

instance IsQuery GetNewsletterCalendar State () Payload Result where
  description = "Get newsletter calendar"

  cacheStrategy _ = do
    hash <- getReadModelHash @Calendar Nothing
    η $ defaultCached hash

  handle (GetNewsletterCalendar _) = do
    mCalendar <- findCalendar
    case mCalendar of
      Just calendar ->
        η (Result { calendar: (unwrap calendar).calendar })
      Nothing ->
        η (Result { calendar: Map.empty })
