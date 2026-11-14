module Core.Mod.Editor.Inter.Cli where

import Proem
import Core.Mod.Message.Field.Inter.Cli.Type (CustomCliAct, CustomCliActResult(..), triggerCommand)
import Inter.Cli.Util.Prefix as Prefix
import Core.Feat.Reference.Message.Query.SearchEditors.Projection.Projection (Editor(..), EditorFilter(..), findEditors)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt)
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Html.Html as Html
import Data.Array as Array
import Data.Either (Either(..))
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Command (ReferenceEditor)

import Util.Type.String.ToString (toString)
import Util.Type.String.Cli (isYes)

askEditor :: ∀ fx. CustomCliAct fx
askEditor prefix = loop
  where
  loop = do
    let p = if prefix == "" then "" else prefix <> " "
    nameStr <- Prefix.ask ("What is the name of the " <> p <> "editor we have to search?")
    case Html.make_ nameStr of
      Left _ -> do
        Prefix.log "Name cannot be empty."
        loop
      Right name -> do
        let filter = EditorHasName { name: name, weight: 1.0 }
        page <- findEditors (defaultFindOpt { filter = Just filter, limit = Finite 5 })
        let editors = page.items

        if Array.length editors == 0 then do
          yn <- Prefix.ask ("No editor found. Do you want to reference a new one? (default: yes)")
          if isYes yn true then do
            η $ triggerCommand @ReferenceEditor
          else do
            Prefix.log "Let's restart the search."
            loop
        else do
          let
            formatEditor idx (Editor record) =
              "   - " <> show idx <> ": " <> toString record.name
            editorsStr = joinWith "\n" (Array.mapWithIndex formatEditor editors)

          Prefix.log "Editors found:"
          Prefix.log editorsStr

          choiceStr <- Prefix.ask "Type the number of the chosen editor, 'new' to reference it, or 'retry' to search again:"

          if choiceStr == "retry" then do
            Prefix.log "Let's restart the search."
            loop
          else if choiceStr == "new" then do
            η $ triggerCommand @ReferenceEditor
          else case Int.fromString choiceStr of
            Nothing -> do
              Prefix.log "Invalid number. Let's restart the search."
              loop
            Just idx -> case Array.index editors idx of
              Nothing -> do
                Prefix.log "This number is not in the list."
                loop
              Just (Editor record) -> do
                Prefix.log ("Selected editor: " <> toString record.name)
                η $ UserInput (toString record.id)
