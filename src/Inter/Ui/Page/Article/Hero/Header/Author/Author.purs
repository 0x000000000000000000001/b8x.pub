module Inter.Ui.Page.Article.Hero.Header.Author.Author where

import Prelude (($), (<>))

import Data.Maybe (Maybe(..))
import Core.Mod.Id.Id as Id
import Core.Mod.Html.Html as Html
import Halogen (ComponentHTML)
import Halogen as Halogen
import Halogen.HTML (span, text, div, img)
import Halogen.HTML.Events (onClick)
import Halogen.HTML.Properties (class_, src)
import Inter.Ui.Mod.Tooltip.Tooltip (tooltip)
import Inter.Ui.Mod.Tooltip.Type (defaultInput)
import Inter.Ui.Page.Article.Hero.Header.Author.Style as Style
import Inter.Ui.Page.Article.Type (Action(..))
import Core.Message.Query.Result (Return(..))
import Core.Mod.Image.Message.Query.Result (Image)
import Inter.Ui.Type.InstanceId (InstanceId)
import Inter.Ui.UiM (UiM)
import Util.Html.Clean.Render.Render (SanitizedHtmlString, render)
import Util.Style.Anchor (AnchorPosition(..))
import Util.Style.Size (Size(..))
import Inter.Ui.Page.Article.Hero.Type (IllustrationLayout(..))
import Data.Newtype (unwrap)

author :: ∀ slots r. { id :: InstanceId | r } -> IllustrationLayout -> Maybe String -> SanitizedHtmlString -> Maybe SanitizedHtmlString -> Maybe Image -> ComponentHTML Action slots UiM
author state layout mAuthorId authorTxt mAuthorBio mAuthorPortrait =
  let
    innerNode = case mAuthorId of
      Just authorId ->
        span
          [ class_ (Halogen.ClassName "authorLink")
          , onClick \e -> ClickAuthor e { id: Id.unsafeFromString authorId, name: Html.unsafeFromString (unwrap authorTxt), ofBook: false }
          ]
          [ render authorTxt ]
      Nothing ->
        render authorTxt
  in
    Style.author_ state.id
      [ tooltip
          ( defaultInput
              { inner = innerNode
              , outer = case mAuthorPortrait, mAuthorBio of
                  Nothing, Nothing -> text ""
                  p, b ->
                    div [] $
                      (case p of
                         Just portrait -> case portrait.src of
                           Given srcStr -> [ div [ class_ (Halogen.ClassName "tooltipPortrait") ] [ img [ src srcStr ] ] ]
                           _ -> []
                         Nothing -> []
                      ) <>
                      (case b of
                         Just bio -> [ render bio ]
                         Nothing -> []
                      ) <>
                      (case mAuthorId of
                         Just authorId -> [ div [ class_ (Halogen.ClassName "exploreArchives"), onClick \e -> ClickAuthor e { id: Id.unsafeFromString authorId, name: Html.unsafeFromString (unwrap authorTxt), ofBook: false } ] [ text "Explorer ses archives" ] ]
                         Nothing -> []
                      )
              , disabled = case mAuthorPortrait, mAuthorBio of
                  Nothing, Nothing -> true
                  _, _ -> false
              , style = defaultInput.style
                  { anchorPosition = Just (case layout of
                      Side -> TopLeftToBottomLeft
                      _ -> TopCenterToBottomCenter)
                  , offset = Just { vertical: 0.6, horizontal: 0.0 }
                  , width = Just (Rem 35.0)
                  }
              }
          )
      ]
