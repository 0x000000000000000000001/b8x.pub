module Core.Mod.NewsTopic.Inter.Cli where

import Proem

import Core.Mod.Message.Field.Inter.Cli.Type (BaseCliFx, CustomCliAct, CustomCliActResult(..), triggerCommand)
import Inter.Cli.Util.Prefix as Prefix
import Core.Feat.Review.Message.Query.SearchNewsTopics.Projection.Projection (NewsTopic(..), NewsTopicFilter(..), findNewsTopics)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt)
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.NonEmptyString.NonEmptyString as NonEmptyString
import Data.Array as Array
import Data.Either (Either(..))
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Core.Feat.Review.Message.Command.AddNewsTopic.Command (AddNewsTopic)
import Run (Run)

import Util.Type.String.ToString (toString)
import Util.Type.String.Cli (isYes)

askNewsTopic :: ∀ fx. CustomCliAct fx
askNewsTopic logPrefix = loop
  where
  loop :: ∀ fx'. Run (BaseCliFx fx') CustomCliActResult
  loop = do
    let p = if logPrefix == "" then "" else logPrefix <> " "
    nameStr <- Prefix.ask ("What is the name of the " <> p <> "news topic we have to search?")
    case NonEmptyString.make_ nameStr of
      Left _ -> do
        Prefix.log "Name cannot be empty."
        loop
      Right searchInput -> do
        let filter = NewsTopicHasSearchInput { searchInput, weight: 1.0 }
        { items: newsTopics } <- findNewsTopics (defaultFindOpt { filter = Just filter, limit = Finite 5 })

        if Array.length newsTopics == 0 then do
          yn <- Prefix.ask "No news topic found. Do you want to add a new one? (default: yes)"
          if isYes yn true then do
            η $ triggerCommand @AddNewsTopic
          else do
            Prefix.log "Let's restart the search."
            loop
        else do
          let
            formatNewsTopic :: Int -> NewsTopic -> String
            formatNewsTopic idx (NewsTopic { searchInput: name }) =
              "   - " <> show idx <> ": " <> toString name
            newsTopicsStr = joinWith "\n" (Array.mapWithIndex formatNewsTopic newsTopics)

          Prefix.log "News topics found:"
          Prefix.log newsTopicsStr

          choiceStr <- Prefix.ask "Type the number of the chosen news topic, 'new' to add it, or 'retry' to search again:"

          if choiceStr == "retry" then do
            Prefix.log "Let's restart the search."
            loop
          else if choiceStr == "new" then do
            η $ triggerCommand @AddNewsTopic
          else case Int.fromString choiceStr of
            Nothing -> do
              Prefix.log "Invalid number. Let's restart the search."
              loop
            Just idx -> case Array.index newsTopics idx of
              Nothing -> do
                Prefix.log "This number is not in the list."
                loop
              Just (NewsTopic { id, searchInput: name }) -> do
                Prefix.log ("Selected news topic: " <> toString name)
                η $ UserInput (toString id)
