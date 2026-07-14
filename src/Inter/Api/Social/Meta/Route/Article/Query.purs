module Inter.Api.Social.Meta.Route.Article.Query where

import Proem

import Core.Message.Query.Query as Query
import Core.Mod.Article.Slug.Slug as Slug
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Inter.Api.ApiM (Context, runApiM)

import Core.Mod.Id.Id as Id
import Inter.Api.Social.Meta.Route.Article.Shared (buildMeta, makeQuery)
import Inter.Api.Social.Meta.Type (Meta)

queryMeta :: Context -> String -> Aff (Maybe Meta)
queryMeta ctx slugStr = do
  case Slug.make_ false slugStr of
    Left _ -> η Nothing
    Right slug -> do
      runId <- ʌ Id.generate
      let cause = { run: runId, append: Nothing, cause: Nothing , overriddenAt: Nothing }
      res_ <- Aff.try $ runApiM ctx cause $ Query.handleWithCache (makeQuery slug)
      case res_ of
        Right (Right (Just article)) -> η (Just (buildMeta Nothing article))
        _ -> η Nothing
