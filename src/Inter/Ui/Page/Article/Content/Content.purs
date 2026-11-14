module Inter.Ui.Page.Article.Content.Content
  (content
  ) where

import Proem

import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiArticle)
import Inter.Ui.Type.InstanceId (InstanceId)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)

import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Inter.Ui.Page.Article.Type (Action(..), Slots)
import Inter.Ui.Mod.AdPlaceholder.AdPlaceholder as AdPlaceholder
import Util.Style.Size as Size
import Inter.Ui.Mod.StopPub.Type (defaultStopPubPlacement)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Page.Article.Content.Body.Body (body)
import Inter.Ui.Page.Article.Content.Notes.Notes (notes, sources)
import Inter.Ui.Page.Article.SocialShare.SocialShare (socialShare)
import Core.Mod.Article.Slug.Slug (Slug)
import Inter.Ui.Page.Article.Content.Style.Style as Style
import Inter.Ui.Page.Article.Hero.Type (IllustrationLayout(..))

content :: ∀ r1 r2. { id :: InstanceId, input :: { slug :: Slug | r1 } | r2 } -> UiArticle -> ComponentHTML Action Slots UiM
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
      [ HH.div
          [ HP.style "display: flex; flex-direction: row; justify-content: center; gap: 4rem; width: 100%; align-items: flex-start;" ]
          [ HH.div
              [ HP.style "display: flex; flex-direction: column; width: 100%; max-width: 45rem; min-width: 0;" ]
              [ body state articleData
              , sources state articleData
              , notes state articleData
              , socialShare state.input.slug
              ]
          , HH.slot (π @"adPlaceholder") "grand_angle_1" AdPlaceholder.component { width: Size.Px 300.0, height: Size.Px 600.0, name: "grand_angle_1", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Just "article-sidebar-ad", wrapperStyle: Just "display: none; position: sticky; top: 3rem; height: fit-content;" } HandleAdLinkOutput
          ]
      , HH.style [] [ HH.text "@media (min-width: 1024px) { .article-sidebar-ad { display: flex !important; } }" ]
      ]
