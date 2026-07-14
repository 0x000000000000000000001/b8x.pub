module Inter.Ui.Page.Article.Hero.Header.Header
  ( header
  , headerLoading
  ) where

import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiArticle)
import Inter.Ui.Type.InstanceId (InstanceId)
import Data.Maybe (Maybe(..), fromMaybe)
import Util.Type.String.ToString (toString)
import Inter.Ui.Capability.ArticleCache.ArticleCache (AlreadyKnown)
import Inter.Ui.Page.Article.Hero.Header.Author.Author (author)
import Inter.Ui.Page.Article.Hero.Header.Lead.Lead (lead)
import Inter.Ui.Page.Article.Hero.Header.Title.Title (title)
import Inter.Ui.Page.Article.Hero.Header.Style.Style as Style
import Inter.Ui.Page.Article.Hero.Type (IllustrationLayout)
import Inter.Ui.Page.Article.Type (Action)
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..))
import Halogen (ComponentHTML)
import Inter.Ui.UiM (UiM)

header :: ∀ slots r. { id :: InstanceId | r } -> IllustrationLayout -> UiArticle -> ComponentHTML Action slots UiM
header state layout articleData =
  let
    titleTxt = case articleData.title of
      Given t -> t
      _ -> SanitizedHtmlString ""

    leadTxt = case articleData.lead of
      Given l -> case l.isFallback of
        Given true -> SanitizedHtmlString ""
        _ -> case l.lead of
          Given (Just html) -> html
          _ -> SanitizedHtmlString ""
      _ -> SanitizedHtmlString ""

    mAuthorId = case articleData.author of
      Given (Just a) -> case a.id of
        Given id -> Just (toString id)
        _ -> Nothing
      _ -> Nothing

    authorTxt = case articleData.author of
      Given (Just a) -> case a.name of
        Given n -> n
        _ -> SanitizedHtmlString ""
      _ -> SanitizedHtmlString ""

    mAuthorBio = case articleData.author of
      Given (Just a) -> case a.biography of
        Given bio -> bio
        _ -> Nothing
      _ -> Nothing

    mAuthorPortrait = case articleData.author of
      Given (Just a) -> case a.portrait of
        Given p -> p
        _ -> Nothing
      _ -> Nothing
  in
    Style.header_ state.id layout
      [ title state titleTxt
      , author state layout mAuthorId authorTxt mAuthorBio mAuthorPortrait
      , lead state leadTxt
      ]

headerLoading :: ∀ slots r. { id :: InstanceId | r } -> IllustrationLayout -> Maybe AlreadyKnown -> ComponentHTML Action slots UiM
headerLoading state layout mKnown =
  let

    titleTxt = case mKnown of
      Just known -> known.title
      Nothing -> SanitizedHtmlString ""

    mAuthorIdLoading = case mKnown of
      Just known -> case known.author of
        Just aa -> Just aa.id
        Nothing -> Nothing
      Nothing -> Nothing

    authorTxt = case mKnown of
      Just known -> case known.author of
        Just aa -> aa.name
        Nothing -> SanitizedHtmlString ""
      Nothing -> SanitizedHtmlString ""

    leadTxt = case mKnown of
      Just known -> if known.lead.isFallback then SanitizedHtmlString "" else fromMaybe (SanitizedHtmlString "") known.lead.lead
      Nothing -> SanitizedHtmlString ""
  in
    Style.header_ state.id layout
      [ title state titleTxt
      , author state layout mAuthorIdLoading authorTxt Nothing Nothing
      , lead state leadTxt
      ]
