module Core.Mod.Article.Author.Inter.Cli where

import Proem

import Core.Mod.Message.Field.Inter.Cli.Type (CustomCliAct, CustomCliActResult(..), triggerCommand, triggerCommandWith)
import Inter.Cli.Util.Prefix as Prefix
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Projection (Author(..), AuthorFilter(..), findAuthors)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt)
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Html.Html as Html
import Data.Array as Array
import Data.Either (Either(..))
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Command (ReferenceAuthor)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Command (CorrectAuthor)
import Util.Type.String.ToString (toString)
import Util.Type.String.Cli (isYes)

askAuthor :: ∀ fx. String -> CustomCliAct fx
askAuthor sndPrefix fstPrefix = loop
  where
  loop = do
    let 
      fst = if fstPrefix == "" then "" else fstPrefix <> " "
      snd = if sndPrefix == "" then "" else sndPrefix <> " "

    nameStr <- Prefix.ask ("What is the name of the " <> fst <> snd <> "author we have to search?")
    case Html.make_ nameStr of
      Left _ -> do
        Prefix.log "Name cannot be empty."
        loop
      Right name -> do
        let filter = AuthorHasName { name: name, weight: 1.0 }
        page <- findAuthors (defaultFindOpt { filter = Just filter, limit = Finite 5 })
        let authors = page.items

        if Array.length authors == 0 then do
          yn <- Prefix.ask ("No author found. Do you want to reference a new one? (default: yes)")
          if isYes yn true then do
            η $ triggerCommand @ReferenceAuthor
          else do
            Prefix.log "Let's restart the search."
            loop
        else do
          let
            formatAuthor idx (Author record) =
              let
                booksStr =
                  if Array.length record.books.names > 0 then " (" <> joinWith ", " (map toString record.books.names) <> ")"
                  else ""
              in
                "   - " <> show idx <> ": " <> toString record.name <> booksStr
            authorsStr = joinWith "\n" (Array.mapWithIndex formatAuthor authors)

          Prefix.log "Authors found:"
          Prefix.log authorsStr

          choiceStr <- Prefix.ask "Type the number of the chosen author, 'new' to reference it, or 'retry' to search again:"

          if choiceStr == "retry" then do
            Prefix.log "Let's restart the search."
            loop
          else if choiceStr == "new" then do
            η $ triggerCommand @ReferenceAuthor
          else case Int.fromString choiceStr of
            Nothing -> do
              Prefix.log "Invalid number. Let's restart the search."
              loop
            Just idx -> case Array.index authors idx of
              Nothing -> do
                Prefix.log "This number is not in the list."
                loop
              Just (Author record) -> do
                Prefix.log ("Selected author: " <> toString record.name)

                updateBiography <- Prefix.askBoolean "Do you want to update the author's biography, on the fly?" false

                if updateBiography then
                  η $ triggerCommandWith @CorrectAuthor { id: record.id }
                else
                  η $ UserInput (toString record.id)
