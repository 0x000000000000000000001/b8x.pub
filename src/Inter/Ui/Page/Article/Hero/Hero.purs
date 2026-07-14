module Inter.Ui.Page.Article.Hero.Hero
  ( hero
  , heroLoading
  ) where

import Proem

import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiArticle)
import Inter.Ui.Type.InstanceId (InstanceId)
import Data.Array as Array
import Data.Maybe (Maybe(..), isJust)
import Inter.Ui.Page.Article.Hero.Header.Header (header, headerLoading)
import Inter.Ui.Page.Article.Hero.Illustration.Illustration (illustration, illustrationLoading)
import Inter.Ui.Page.Article.Hero.Type (IllustrationLayout(..))
import Inter.Ui.Page.Article.Hero.Style.Style as Style
import Inter.Ui.Capability.ArticleCache.ArticleCache (AlreadyKnown)
import Inter.Ui.Page.Article.Type (Action)
import Halogen (ComponentHTML)
import Inter.Ui.UiM (UiM)

hero :: ∀ slots r. { id :: InstanceId | r } -> UiArticle -> ComponentHTML Action slots UiM
hero state articleData =
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
  in
    Style.hero_ state.id layout
      [ header state layout articleData
      , illustration state layout articleData
      ]

heroLoading :: ∀ slots r. { id :: InstanceId | r } -> Maybe AlreadyKnown -> ComponentHTML Action slots UiM
heroLoading state mKnown =
  let
    layout = case mKnown of
      Just known -> case known.illustration of
        Just img ->
          let
            hasLead = not known.lead.isFallback && isJust known.lead.lead
          in
            if img.isFallback || (img.dimensions.width < 350 && img.dimensions.height < 350) then TextOnly
            else if not hasLead then CentralShifted
            else if img.dimensions.width < img.dimensions.height then Side
            else CentralShifted
        Nothing -> TextOnly
      Nothing -> TextOnly
  in
    Style.hero_ state.id layout
      [ headerLoading state layout mKnown
      , illustrationLoading state layout mKnown
      ]
