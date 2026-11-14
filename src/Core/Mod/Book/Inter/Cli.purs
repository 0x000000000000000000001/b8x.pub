module Core.Mod.Book.Inter.Cli where

import Proem
import Core.Mod.Message.Field.Inter.Cli.Type (CustomCliAct, CustomCliActResult(..), triggerCommand)
import Inter.Cli.Util.Prefix as Prefix
import Core.Feat.Reference.Message.Query.SearchBooks.Projection.Projection (Book(..), BookFilter(..), findBooks)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt)
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Html.Html as Html
import Data.Array as Array
import Data.Either (Either(..))
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Core.Feat.Reference.Message.Command.ReferenceBook.Command (ReferenceBook)

import Util.Type.String.ToString (toString)
import Util.Type.String.Cli (isYes)

askBook :: ∀ fx. CustomCliAct fx
askBook logPrefix = loop
  where
  loop = do
    let p = if logPrefix == "" then "" else logPrefix <> " "
    nameStr <- Prefix.ask ("What is the title of the " <> p <> "book we have to search?")
    case Html.make_ nameStr of
      Left _ -> do
        Prefix.log "Title cannot be empty."
        loop
      Right name -> do
        let filter = BookHasName { name: name, weight: 1.0 }
        page <- findBooks (defaultFindOpt { filter = Just filter, limit = Finite 5 })
        let books = page.items

        if Array.length books == 0 then do
          yn <- Prefix.ask ("No book found. Do you want to reference a new one? (default: yes)")
          if isYes yn true then do
            η $ triggerCommand @ReferenceBook
          else do
            Prefix.log "Let's restart the search."
            loop
        else do
          let
            formatBook idx (Book record) =
              "   - " <> show idx <> ": " <> toString record.name
            booksStr = joinWith "\n" (Array.mapWithIndex formatBook books)

          Prefix.log "Books found:"
          Prefix.log booksStr

          choiceStr <- Prefix.ask "Type the number of the chosen book, 'new' to reference it, or 'retry' to search again:"

          if choiceStr == "retry" then do
            Prefix.log "Let's restart the search."
            loop
          else if choiceStr == "new" then do
            η $ triggerCommand @ReferenceBook
          else case Int.fromString choiceStr of
            Nothing -> do
              Prefix.log "Invalid number. Let's restart the search."
              loop
            Just idx -> case Array.index books idx of
              Nothing -> do
                Prefix.log "This number is not in the list."
                loop
              Just (Book record) -> do
                Prefix.log ("Selected book: " <> toString record.name)
                η $ UserInput (toString record.id)
