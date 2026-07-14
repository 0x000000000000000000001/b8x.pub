module Core.Feat.Review.Message.Query.GetArticle.Query where

import Proem

import Config.PublicConfig (askPublicConfig)
import Core.Feat.Review.Message.Query.GetArticle.Payload (Fields, Payload)
import Core.Feat.Review.Message.Query.GetArticle.Projection.Projection (Article(..), ArticleKey(..), findArticleById, findArticleBySlug)
import Core.Feat.Review.Message.Query.GetArticle.Result (Result)
import Core.Feat.Review.Message.Query.GetArticle.State (State)
import Core.Message.Query.Handle (build)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Article.Content.Message.Query.Build (buildContent)
import Core.Mod.Article.Identifier.ArticleIdentifier (ArticleIdentifier(..))
import Core.Mod.Article.Illustrations.Message.Query.Build (buildIllustrations, buildIllustration)
import Core.Mod.Article.Lead.Message.Query.Build (buildLead)
import Core.Mod.Article.Notes.Message.Query.Build (buildNotes)
import Core.Mod.Article.Sources.Message.Query.Build (buildSources)
import Core.Mod.Article.Title.Message.Query.Build (buildTitle)
import Core.Mod.Author.Message.Query.Build (buildAuthor)
import Core.Mod.Book.Message.Query.Build (buildBooks, buildBook)
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype GetArticle = GetArticle Payload

derive instance Newtype GetArticle _
derive instance Generic GetArticle _
derive newtype instance Random GetArticle
derive newtype instance WriteForeign GetArticle
derive newtype instance ReadForeign GetArticle

instance Reflect GetArticle where
  reflectName = reflectConstructorName @GetArticle

instance IsQuery GetArticle State Fields Payload Result where
  description = "Get an article"

  cacheStrategy (GetArticle { identifier }) = do
    let
      mKey = case identifier of
        Id id -> Just (ArticleKey { id: Just id, slug: Nothing })
        Slug slug -> Just (ArticleKey { id: Nothing, slug: Just slug })

    hash <- getReadModelHash @Article mKey
    
    η $ defaultCached hash

  handle (GetArticle { identifier, needs }) = do
    config <- askPublicConfig
    mArticle <- case identifier of
      Id reqArticleId -> findArticleById reqArticleId
      Slug reqSlug -> findArticleBySlug reqSlug

    case mArticle of
      Just (Article a) -> do
        η $ Just
          { id: build needs.id a.id
          , legacyId: build needs.legacyId a.legacyId
          , title: buildTitle needs.title a.title
          , content: buildContent needs.content a.content
          , theme: build needs.theme a.theme
          , books: buildBooks needs.books a.books (buildBook config.objectStorage.urlBase)
          , author: buildAuthor config.objectStorage.urlBase needs.author a.author
          , illustrations: buildIllustrations needs.illustrations a.illustrations a.books (buildIllustration config.objectStorage.urlBase)
          , lead: buildLead needs.lead a.lead a.content
          , notes: buildNotes needs.notes a.notes
          , sources: buildSources needs.sources a.sources
          , magazineIssue: build needs.magazineIssue a.magazineIssue
          }

      Nothing -> do
        η (Nothing :: Result)
