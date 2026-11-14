module Inter.Ui.Page.Article.Books.Author.Author
  ( author
  ) where

import Proem hiding (div)

import Core.Message.Query.Result (Return(..))
import Core.Mod.Html.Html as Html
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Halogen (ComponentHTML)
import Halogen as Halogen
import Halogen.HTML (div, img, span, text)
import Halogen.HTML.Events (onClick, onMouseEnter)
import Halogen.HTML.Properties (class_, src)
import Inter.Ui.Mod.Tooltip.Tooltip (tooltip)
import Inter.Ui.Mod.Tooltip.Type (defaultInput)
import Inter.Ui.Page.Article.Books.Author.Style as Style
import Inter.Ui.Page.Article.Type (Action(..), State)
import Inter.Ui.Type.Device (Device(..))
import Inter.Ui.Type.Model (UiBookAuthor)
import Inter.Ui.UiM (UiM)
import Network.RemoteData (RemoteData(..))
import Util.Html.Clean.Render.Render (render, renderArray)
import Util.Style.Anchor (AnchorPosition(..))
import Util.Style.Size (Size(..))

author :: ∀ slots. State -> UiBookAuthor -> ComponentHTML Action slots UiM
author state authorData =
  let
    mAuthorInfo = case Map.lookup authorData.id state.bookAuthorInfos of
      Just (Success authorInfo) -> Just authorInfo
      _ -> Nothing

    mBiography = mAuthorInfo >>= _.biography
    mPortrait = mAuthorInfo >>= _.portrait

    disabled = state.context /= Desktop || case mBiography, mPortrait of
      Nothing, Nothing -> true
      _, _ -> false

    authorName = Html.unsafeFromString (unwrap authorData.name)

    innerNode =
      span
        [ class_ (Halogen.ClassName "authorLink")
        , onClick \e -> ClickAuthor e { id: authorData.id, name: authorName, ofBook: true }
        , onMouseEnter \_ -> LoadBookAuthorInfo authorData.id
        ]
        (renderArray authorData.name)

    outerNode =
      div [] $
        ( case mPortrait of
            Just portrait -> case portrait.src of
              Given srcStr -> [ div [ class_ (Halogen.ClassName "tooltipPortrait") ] [ img [ src srcStr ] ] ]
              _ -> []
            Nothing -> []
        )
          <> ( case mBiography of
                Just biography -> [ render biography ]
                Nothing -> []
             )
          <> [ div
                 [ class_ (Halogen.ClassName "exploreArchives")
                 , onClick \e -> ClickAuthor e { id: authorData.id, name: authorName, ofBook: true }
                 ]
                 [ text "Explorer ses archives" ]
             ]
  in
    Style.author_ state.id
      [ tooltip
          ( defaultInput
              { inner = innerNode
              , outer = outerNode
              , disabled = disabled
              , style = defaultInput.style
                  { anchorPosition = Just TopCenterToBottomCenter
                  , offset = Just { vertical: 0.6, horizontal: 0.0 }
                  , width = Just (Rem 35.0)
                  }
              }
          )
      ]
