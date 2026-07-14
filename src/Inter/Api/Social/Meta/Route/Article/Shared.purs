-- | This module contains UI-safe pure functions for metadata generation.
-- | It is separated from `Query.purs` to prevent the frontend from importing
-- | backend dependencies (like `pg.js` via `ApiM`) when it needs `buildMeta` or `makeQuery`.
module Inter.Api.Social.Meta.Route.Article.Shared where

import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..))
import Proem

import Config.PublicConfig (publicConfig, toAbsolute_)
import Core.Feat.Review.Message.Query.GetArticle.Field.Needs (defaultNeeds)
import Core.Feat.Review.Message.Query.GetArticle.Query (GetArticle(..))
import Core.Feat.Review.Message.Query.GetArticle.Result (Article)
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result (Return(..))
import Core.Mod.Article.Content.Message.Query.Opt (defaultContentOpt)
import Core.Mod.Article.Identifier.ArticleIdentifier (ArticleIdentifier(..))
import Core.Mod.Article.Slug.Slug as Slug
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Inter.Api.Route (Route(..), routeCodec) as ApiRoute
import Inter.Api.Social.Meta.Type (Meta)
import Routing.Duplex (print)
import Util.Html.Clean.Clean (TagList(..))
import Util.Type.String.ToString (toString)

buildMeta :: Maybe String -> Article -> Meta
buildMeta mAgent { title, lead, illustrations } =
  let
    titleStr = case title of
      Given t -> Just (toString t)
      _ -> Nothing

    descriptionStr = case lead of
      Given l -> case l.lead of
        Given (Just h) -> Just (toString h)
        _ -> Nothing
      _ -> Nothing

    mImageSrc = case illustrations of
      Given ills -> head ills >>= \ill -> case ill.image of
        Given img -> case img.src of
          Given src | src /= "" -> Just src
          _ -> Nothing
        _ -> Nothing
      _ -> Nothing

    watermarkUrl = toAbsoluteWatermark mImageSrc mAgent
  in
    { title: titleStr
    , description: descriptionStr
    , image: Just watermarkUrl
    }

toAbsoluteWatermark :: Maybe String -> Maybe String -> String
toAbsoluteWatermark mUrl mAgent =
  toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec (ApiRoute.SocialWatermark { url: mUrl, agent: mAgent, v: Just "1" }))

makeQuery :: Slug.Slug -> GetArticle
makeQuery slug =
  GetArticle
    { identifier: Slug slug
    , needs: defaultNeeds
        { title = Needed { untagHtml: { whitelist: Tags [], blacklistInWhitelist: Tags [] } } ι
        , lead = Needed { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " " }, untagHtml: { whitelist: Tags [], blacklistInWhitelist: Tags [] } } { isFallback: Needed ι ι }
        , content = Needed defaultContentOpt ι
        , illustrations = Needed { priorizeRatio: Nothing, fallbackToBookCovers: true } { image: Needed ι { src: Needed { absolute: true } ι, dimensions: NotNeeded }, caption: Needed ι ι, isFallback: NotNeeded }
        }
    }
