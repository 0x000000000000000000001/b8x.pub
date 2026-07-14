module Inter.Ui.Router.Menu.Core.Magazine.Covers.Covers where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Halogen.HTML (div, img, text)
import Halogen.HTML.Events (onClick)
import Halogen.HTML.Properties (src)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Core.Magazine.BackButton.BackButton (backButton)
import Inter.Ui.Router.Menu.Core.Magazine.Style.Style as Style
import Inter.Ui.UiM (UiM)
import Data.Newtype (unwrap)
import Data.Maybe (Maybe(..))
import Network.RemoteData (RemoteData(..))
import Data.Enum (fromEnum)
import Halogen.HTML.Core (AttrName(..))
import Core.Mod.Time.Year (Year(..))
import Data.Array as Array
import Data.Map as Map
import Data.Int as Int
import Util.Style.Classname (class_, classes)
import Core.Message.Query.Result (Return(..))
import Halogen.HTML.Properties as HP
import Util.Type.String.ToString (toString)
import Inter.Ui.Router.Menu.Core.Newsletter.Months.Months (translateMonth)
import Core.Mod.Time.Month (Month(..))
import Core.Mod.MagazineIssue.ReleasedAt.ReleasedAt (ReleasedAt(..))

covers :: State -> Year -> Array (ComponentHTML Action Slots UiM)
covers state year =
  [ backButton state OpenMagazine [ text "← Revenir aux années" ]
  , Style.mosaic_ state.id coversArray
  ]
  where
  coversArray = case state.magazine.calendar of
    Success res ->
      case Map.lookup year (unwrap res).calendar of
        Just issues ->
          let
            -- sort issues by number descending
            sorted = Array.sortWith (\issue -> -issue.number) issues
          in
            map renderCover sorted
        Nothing -> []
    _ -> []

  showYear (Year y) = show (fromEnum y)

  formatReleasedAt releasedAt = case releasedAt of
    Single { month: Month m, year: y } ->
      translateMonth m <> " " <> showYear y
    Span { start: d1, end: d2 } ->
      let
        Month m1 = d1.month
        Month m2 = d2.month
      in
        if d1.year == d2.year then
          translateMonth m1 <> "-" <> translateMonth m2 <> " " <> showYear d1.year
        else
          translateMonth m1 <> " " <> showYear d1.year <> "-" <> translateMonth m2 <> " " <> showYear d2.year

  renderCover issue =
    let
      overlay = div [ class_ Style.mosaicItemOverlayClass ]
        [ div [ classes [ Style.class' state.id, "title" ] ] [ text issue.name ]
        , div [ classes [ Style.class' state.id, "number" ] ] [ text ("N° " <> toString issue.number) ]
        , case issue.releasedAt of
            Just rAt -> div [ classes [ Style.class' state.id, "date" ] ] [ text (formatReleasedAt rAt) ]
            Nothing -> text ""
        ]
    in
      case issue.cover of
        Just { src: Given s, dimensions: Given d } ->
          let
            wrapperStyle = case d.width, d.height of
              Given w, Given h -> 
                let ratio = (Int.toNumber h / Int.toNumber w) * 100.0
                in [ HP.attr (AttrName "style") ("padding-bottom: " <> show ratio <> "%; height: 0;") ]
              _, _ -> []
            imgProps = [ src s, class_ Style.mosaicItemImageClass ]
          in
          div ( [ class_ Style.mosaicItemClass, onClick \_ -> GoToMagazineArticles year issue.slug ] <> wrapperStyle )
              [ img imgProps
              , overlay
              ]
        Just { src: Given s } ->
          div [ class_ Style.mosaicItemClass, onClick \_ -> GoToMagazineArticles year issue.slug ]
              [ img [ src s, class_ Style.mosaicItemImageClass ]
              , overlay
              ]
        _ ->
          div [ class_ Style.mosaicItemClass, onClick \_ -> GoToMagazineArticles year issue.slug ] [ overlay ]
