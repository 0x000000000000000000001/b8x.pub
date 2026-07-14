module Inter.Ui.Page.Article.Content.Content
  (content
  ) where

import Proem

import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiArticle)
import Inter.Ui.Type.InstanceId (InstanceId)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Halogen.HTML (HTML)
import Inter.Ui.Page.Article.Content.Body.Body (body)
import Inter.Ui.Page.Article.Content.Notes.Notes (notes, sources)
import Inter.Ui.Page.Article.SocialShare.SocialShare (socialShare)
import Core.Mod.Article.Slug.Slug (Slug)
import Inter.Ui.Page.Article.Content.Style.Style as Style
import Inter.Ui.Page.Article.Hero.Type (IllustrationLayout(..))

content :: ∀ w i r1 r2. { id :: InstanceId, input :: { slug :: Slug | r1 } | r2 } -> UiArticle -> HTML w i
content state articleData =
  let
    illustrations = case articleData.illustrations of
      Given ills -> ills
      _ -> []

    firstIll = Array.head illustrations

    hasLead = case articleData.lead of
      Given l -> case l.isFallback of
        Given true -> false
        _ -> case l.lead of
          Given (Just _) -> true
          _ -> false
      _ -> false

    layout = case firstIll of
      Just ill -> case ill.image of
        Given img -> case img.dimensions of
          Given dims -> case dims.width, dims.height of
            Given w, Given h -> 
              if w < 350 && h < 350 then TextOnly
              else if not hasLead then CentralShifted
              else if w < h then Side 
              else CentralShifted
            _, _ -> CentralShifted
          _ -> CentralShifted
        _ -> CentralShifted
      Nothing -> TextOnly

    isShifted = layout == CentralShifted
  in
    Style.content_ state.id isShifted
      [ socialShare state.input.slug
      , body state articleData
      , sources state articleData
      , notes state articleData
      ]
