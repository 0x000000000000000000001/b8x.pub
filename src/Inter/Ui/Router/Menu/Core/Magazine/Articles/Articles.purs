module Inter.Ui.Router.Menu.Core.Magazine.Articles.Articles where

import Proem hiding (div)

import CSS (width, pct, rem, marginBottom)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Mod.Time.Year (Year)
import Data.Maybe (Maybe(..))
import Data.Array as Array
import Halogen (ComponentHTML)
import Halogen.HTML (HTML, div, strong_, text)
import Halogen.HTML.CSS (style)
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties (class_, classes)
import Inter.Ui.Router.Menu.Core.Magazine.Articles.Item.Item as Item
import Inter.Ui.Router.Menu.Core.Magazine.BackButton.BackButton (backButton, backButtonDisabled)
import Inter.Ui.Router.Menu.Core.Magazine.Style.Style as Style
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Style as ContentStyle
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Style as CoreStyle
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Style as TitleStyle
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Style as ItemStyle
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Style as ThumbStyle
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)
import Network.RemoteData (RemoteData(..))
import Util.Style.Effect (defaultLoading)
import Util.Type.String.ToString (toString)

skeletonItem :: ∀ w i. State -> HTML w i
skeletonItem state =
  div [ classes [ ClassName ItemStyle.staticClass, ClassName (ItemStyle.class' state.id) ] ]
    [ div
        [ classes [ ClassName ThumbStyle.staticClass, ClassName ThumbStyle.staticClassWhenSquare ]
        , style defaultLoading
        ]
        []
    , CoreStyle.core_
        [ TitleStyle.title
            [ style do
                defaultLoading
                width (pct 40.0)
            ]
            [ text "This is a mock title" ]
        , ContentStyle.content
            [ style do
                defaultLoading
                width (pct 60.0)
                marginBottom (rem 0.3)
            ]
            [ text "Mock authors and books." ]
        , ContentStyle.content
            [ style do
                defaultLoading
                width (pct 100.0)
            ]
            [ text "This is a mock lead that takes one line. More than one line, in fact. Maybe several. More than one. Yes. Repeat after me. More than one. More than one. More than one. More than one. More than one. More than one. More than one. More than one." ]
        ]
    ]

articles :: State -> Maybe Year -> Slug -> Array (ComponentHTML Action Slots UiM)
articles state mYear _slug =
  [ case mYear of
      Just year -> backButton state (GoToMagazineCovers year)
        [ text "← Quitter le "
        , strong_ [ text "sommaire" ]
        , text " et revenir aux numéros"
        ]
      Nothing -> backButtonDisabled state
        [ text "← Quitter le "
        , strong_ [ text "sommaire" ]
        , text " et revenir aux numéros"
        ]
  , Style.items_ state.id itemsHtml
  ]
  where
  itemsHtml = case state.magazine.articles of
    Success result ->
      [ div [ class_ (ClassName "magazine-articles") ]
          (Array.mapWithIndex (\idx a -> Item.item (toString idx) a) result.articles)
      ]
    _ ->
      [ div [ class_ (ClassName "magazine-articles") ]
          [ skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          , skeletonItem state
          ]
      ]
