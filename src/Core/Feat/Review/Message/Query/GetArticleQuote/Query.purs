module Core.Feat.Review.Message.Query.GetArticleQuote.Query where

import Proem

import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Review.Message.Query.GetArticleQuote.Payload (Fields, Payload)
import Core.Feat.Review.Message.Query.GetArticleQuote.Result (Result)
import Core.Feat.Review.Message.Query.GetArticleQuote.State (State)
import Core.Feat.Review.Message.Query.GetArticleQuote.Projection.Projection (Quote(..), findMostRecentQuote)
import Core.Message.Query.Handle (build)
import Config.PublicConfig (askPublicConfig)
import Core.Mod.Article.Illustrations.Message.Query.Build (buildIllustration, buildIllustrations)
import Core.Mod.Article.Lead.Message.Query.Build (buildLead)
import Core.Mod.Article.Title.Message.Query.Build (buildTitle)
import Core.Mod.Author.Message.Query.Build (buildAuthor)
import Core.Mod.Book.Message.Query.Build (buildBook, buildBooks)
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype GetArticleQuote = GetArticleQuote Payload

derive instance Newtype GetArticleQuote _
derive instance Generic GetArticleQuote _
derive newtype instance Random GetArticleQuote
derive newtype instance WriteForeign GetArticleQuote
derive newtype instance ReadForeign GetArticleQuote

instance Reflect GetArticleQuote where
  reflectName = reflectConstructorName @GetArticleQuote

instance IsQuery GetArticleQuote State Fields Payload Result where
  description = "Get the most recent article quote"

  cacheStrategy _ = do
    hash <- getReadModelHash @Quote Nothing
    η $ defaultCached hash

  handle (GetArticleQuote { needs, theme }) = do
    config <- askPublicConfig

    mQuote <- findMostRecentQuote theme

    case mQuote of
      Nothing -> η Nothing
      Just (Quote q) -> do
        let a = q.article
        η $ Just
          { quote: q.quote
          , slug: a.slug
          , article:
              { id: build needs.id a.id
              , title: buildTitle needs.title a.title
              , books: buildBooks needs.books a.books (buildBook config.objectStorage.urlBase)
              , author: buildAuthor config.objectStorage.urlBase needs.author a.author
              , illustrations: buildIllustrations needs.illustrations a.illustrations a.books (buildIllustration config.objectStorage.urlBase)
              , lead: buildLead needs.lead a.lead a.content
              , slug: build needs.slug a.slug
              }
          }
