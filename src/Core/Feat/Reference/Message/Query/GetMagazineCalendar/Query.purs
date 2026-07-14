module Core.Feat.Reference.Message.Query.GetMagazineCalendar.Query where

import Proem
import Config.PublicConfig (askPublicConfig)
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Payload (Payload)
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Result (Result(..))
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.State (State)
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Projection.Projection (Calendar, findCalendar)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Message.Query.Payload (Need(..))
import Core.Mod.Image.Message.Query.Build (buildImage)
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Map as Map
import Data.Newtype (class Newtype, unwrap)
import Data.Maybe (Maybe(..))
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype GetMagazineCalendar = GetMagazineCalendar Payload

derive instance Newtype GetMagazineCalendar _
derive instance Generic GetMagazineCalendar _
derive newtype instance Random GetMagazineCalendar
derive newtype instance WriteForeign GetMagazineCalendar
derive newtype instance ReadForeign GetMagazineCalendar

instance Reflect GetMagazineCalendar where
  reflectName = reflectConstructorName @GetMagazineCalendar

instance IsQuery GetMagazineCalendar State () Payload Result where
  description = "Get magazine calendar"

  cacheStrategy _ = do
    hash <- getReadModelHash @Calendar Nothing
    η $ defaultCached hash

  handle (GetMagazineCalendar _) = do
    config <- askPublicConfig

    mCalendar <- findCalendar

    case mCalendar of
      Just calendar -> do
        let
          mapImage img = buildImage config.objectStorage.urlBase ι { src: Needed { absolute: true } ι, dimensions: Needed ι { width: Needed ι ι, height: Needed ι ι } } img
          mappedCalendar = map
            ( map
                ( \item ->
                    { id: item.id
                    , name: item.name
                    , number: item.number
                    , slug: item.slug
                    , cover: mapImage <$> item.cover
                    , releasedAt: item.releasedAt
                    }
                )
            )
            (unwrap calendar).calendar

        η (Result { calendar: mappedCalendar })

      Nothing ->
        η (Result { calendar: Map.empty })
