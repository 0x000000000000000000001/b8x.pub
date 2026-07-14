module Inter.Cli.CodeGen.Lexicon
  ( Options
  , description
  , parser
  , run
  , shortModuleName
  ) where

import Proem

import Data.Foldable (for_)
import Data.String (Pattern(..), Replacement(..), replace, replaceAll)
import Inter.Cli.CodeGen.CodeGenM (CodeGenM)
import Inter.Cli.CodeGen.Util (withHeader)
import Util.Log.Info (info)
import Util.Log.Success (success)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile, writeTextFile)
import Node.Path (FilePath)
import Options.Applicative (Parser)
import Util.File.Path (srcDirAbsolutePath)
import Util.Lexicon.X as X
import Util.Type.String.String (lowerCaseFirst)

shortModuleName :: String
shortModuleName = "Lexicon"

fullModuleName :: String
fullModuleName = "Inter.Cli.CodeGen.Lexicon"

words :: Array String
words =
  [ "About"
  , "Append"
  , "AppendId"
  , "BackgroundColor"
  , "Border"
  , "Carrousel"
  , "Collaborators"
  , "Color"
  , "Country"
  , "Date"
  , "Day"
  , "Dev"
  , "Dispatch"
  , "Email"
  , "Event"
  , "EventStore"
  , "Errored"
  , "ExceptLogic"
  , "ExpiresAtTs"
  , "Find"
  , "Firstname"
  , "Fit"
  , "Focus"
  , "Height"
  , "Home"
  , "Hover"
  , "Id"
  , "Image"
  , "Incorrect"
  , "Inner"
  , "Input"
  , "Items"
  , "Job"
  , "Lastname"
  , "Left"
  , "Loaded"
  , "Loading"
  , "MalformedPayloadValue"
  , "Members"
  , "Menu"
  , "Minute"
  , "Modal"
  , "Month"
  , "MqConfig"
  , "NewEmail"
  , "Next"
  , "Password"
  , "PasswordInputValue"
  , "Payload"
  , "Person"
  , "Persons"
  , "Phase"
  , "Phone"
  , "Portrait"
  , "PortraitId"
  , "Portraits"
  , "Prev"
  , "Prod"
  , "Projection"
  , "PSql"
  , "QuestionMark"
  , "Queue"
  , "RabbitMq"
  , "Radius"
  , "ReaderDbConfig"
  , "ReaderId"
  , "ReaderMqConfig"
  , "ReaderPostgreSql"
  , "ReaderPSql"
  , "ReaderRabbitMq"
  , "ReaderRMq"
  , "ReaderSignalRef"
  , "Right"
  , "RMq"
  , "Role"
  , "Root"
  , "Section"
  , "SectionDescription"
  , "Selected"
  , "SelectedSeminar"
  , "Seminars"
  , "Separators"
  , "Speaker"
  , "Stage"
  , "Tag"
  , "Test"
  , "TestId"
  , "Section"
  , "SectionDescription"
  , "Timeline"
  , "TimelinePortraits"
  , "Title"
  , "Tooltip"
  , "Type"
  , "UserAlreadyRegistered"
  , "UserId"
  , "UserNotRegistered"
  , "UserUnregistered"
  , "Value"
  , "Values"
  , "Vault"
  , "VideoRecord"
  , "VideoUrl"
  , "When"
  , "Width"
  , "With"
  , "Year"
  , "YoutubeVideo"
  ]

run :: Options -> CodeGenM Ɩ
run _ = do
  info "Generating lexicon..."
  templateContent <- readTemplateContent
  for_ words (generateFile templateContent)
  success "Lexicon generated!"

generateFile :: String -> String -> CodeGenM Ɩ
generateFile templateContent capitalizedWord = do
  let
    word = lowerCaseFirst capitalizedWord

    filePath =
      replace
        (Pattern "_/CodeGen.template")
        (Replacement capitalizedWord)
        getTemplatePath

    content = generateContent templateContent word capitalizedWord
  ʌ $ writeTextFile UTF8 filePath content

generateContent :: String -> String -> String -> String
generateContent templateContent word capitalizedWord =
  withHeader fullModuleName
    templateContent
    -- Protect the x of the lexicon word
    # replaceAll (Pattern lexicon) (Replacement lexiconSubstitute)
    -- Do the replacements
    # replaceAll (Pattern "x") (Replacement word)
    # replaceAll (Pattern "X") (Replacement capitalizedWord)
    -- Restore the lexicon word
    # replaceAll (Pattern lexiconSubstitute) (Replacement lexicon)
  where
  lexicon = "exicon"
  lexiconSubstitute = "e*icon"

readTemplateContent :: CodeGenM String
readTemplateContent = ʌ $ readTextFile UTF8 getTemplatePath

getTemplatePath :: FilePath
getTemplatePath =
  srcDirAbsolutePath
    <>
      ( X.fullModuleName
          # replaceAll (Pattern ".") (Replacement "/")
          # replace (Pattern "/X") (Replacement "/_/CodeGen.template")
      )
    <> ".purs"

parser :: Parser Options
parser = η {}

description :: String
description = "Generate lexicon code"

type Options = {}
