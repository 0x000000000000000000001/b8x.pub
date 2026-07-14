module Inter.Ui.Page.Article.Hero.Illustration.Illustration
  (illustration
  , illustrationLoading
  ) where

import Proem

import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiArticle)
import Inter.Ui.Type.InstanceId (InstanceId)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Halogen.HTML (HTML, text)
import Inter.Ui.Capability.ArticleCache.ArticleCache (AlreadyKnown)
import Inter.Ui.Page.Article.Hero.Illustration.Caption.Caption (caption)
import Inter.Ui.Page.Article.Hero.Illustration.Image.Image (image)
import Inter.Ui.Page.Article.Hero.Type (IllustrationLayout(..))
import Inter.Ui.Page.Article.Hero.Illustration.Style.Style as Style

illustration :: ∀ w i r. { id :: InstanceId | r } -> IllustrationLayout -> UiArticle -> HTML w i
illustration state layout articleData =
  let
    illustrations = case articleData.illustrations of
      Given ills -> ills
      _ -> []

    firstIll = Array.head illustrations

    illSrc = case firstIll of
      Just ill -> case ill.image of
        Given img -> case img.src of
          Given path ->
            let
              isTooSmall = case img.dimensions of
                Given dims -> case dims.width, dims.height of
                  Given w, Given h -> w < 350 && h < 350
                  _, _ -> false
                _ -> false
            in
              if isTooSmall then Nothing else Just path
          _ -> Nothing
        _ -> Nothing
      Nothing -> Nothing

    illCaption = case firstIll of
      Just ill -> case ill.caption of
        Given cap -> cap
        _ -> Nothing
      Nothing -> Nothing
  in
    case illSrc of
      Just path ->
        Style.illustration_ state.id
          [ image state path (layout == Side)
          , caption state illCaption
          ]
      Nothing -> text ""

illustrationLoading :: ∀ w i r. { id :: InstanceId | r } -> IllustrationLayout -> Maybe AlreadyKnown -> HTML w i
illustrationLoading state layout mKnown =
  case mKnown >>= _.illustration of
    Just img ->
      let
        isTooSmall = img.dimensions.width < 350 && img.dimensions.height < 350
      in
        if isTooSmall || img.isFallback || layout == TextOnly then
          text ""
        else
          Style.illustration_ state.id
            [ image state img.src (layout == Side)
            , caption state img.caption
            ]
    Nothing -> case layout of
      TextOnly -> text ""
      Side -> Style.illustrationLoading_ state.id true
      CentralShifted -> Style.illustrationLoading_ state.id false
