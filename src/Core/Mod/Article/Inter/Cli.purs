module Core.Mod.Article.Inter.Cli where

import Proem
import Core.Mod.Message.Field.Inter.Cli.Type (CustomCliAct, CustomCliActResult(..), triggerCommand)
import Inter.Cli.Util.Prefix as Prefix
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection (Article(..), ArticleFilter(..), findArticles)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt)
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Html.Html as Html
import Data.Array as Array
import Data.Either (Either(..))
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Core.Feat.Review.Message.Command.WriteArticle.Command (WriteArticle)
import Core.Mod.Article.Projection.WrittenAt (WrittenAt(..))
import Core.Mod.Time.Instant (toHumanParisDate)

import Util.Type.String.ToString (toString)
import Util.Type.String.Cli (isYes)

askArticle :: ∀ fx. CustomCliAct fx
askArticle logPrefix = loop
  where
  loop = do
    let p = if logPrefix == "" then "" else logPrefix <> " "
    nameStr <- Prefix.ask ("What is the title of the " <> p <> "article we have to search?")
    case Html.make_ nameStr of
      Left _ -> do
        Prefix.log "Title cannot be empty."
        loop
      Right name -> do
        let filter = ArticleHasTitle { title: name, weight: 1.0 }
        page <- findArticles (defaultFindOpt { filter = Just filter, limit = Finite 5 })
        let articles = page.items

        if Array.length articles == 0 then do
          yn <- Prefix.ask ("No article found. Do you want to write a new one? (default: yes)")
          if isYes yn true then do
            η $ triggerCommand @WriteArticle
          else do
            Prefix.log "Let's restart the search."
            loop
        else do
          let
            formatArticle idx (Article record) =
              let
                (WrittenAt { instant }) = record.writtenAt
              in
                "   - " <> show idx <> ": " <> toString record.title <> " (" <> toHumanParisDate instant <> " @ Paris)"
            articlesStr = joinWith "\n" (Array.mapWithIndex formatArticle articles)

          Prefix.log "Articles found:"
          Prefix.log articlesStr

          choiceStr <- Prefix.ask "Type the number of the chosen article, 'new' to write it, or 'retry' to search again:"

          if choiceStr == "retry" then do
            Prefix.log "Let's restart the search."
            loop
          else if choiceStr == "new" then do
            η $ triggerCommand @WriteArticle
          else case Int.fromString choiceStr of
            Nothing -> do
              Prefix.log "Invalid number. Let's restart the search."
              loop
            Just idx -> case Array.index articles idx of
              Nothing -> do
                Prefix.log "This number is not in the list."
                loop
              Just (Article record) -> do
                Prefix.log ("Selected article: " <> toString record.title)
                η $ UserInput (toString record.id)
