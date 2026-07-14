module Inter.Cli.CodeGen.Config
  ( Options
  , description
  , parser
  , run
  , shortModuleName
  ) where

import Proem

import Config.InternalConfig as InternalConfig
import Config.PublicConfig as PublicConfig
import Data.Array (mapMaybe, nub, sortBy)
import Data.Foldable (foldM)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), Replacement(..), replaceAll, split)
import Data.String.CodeUnits as String
import Inter.Cli.CodeGen.CodeGenM (CodeGenM)
import Util.Log.Info (info)
import Util.Log.Success (success)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile, writeTextFile)
import Node.Process (lookupEnv)
import Options.Applicative (Parser)
import Util.File.Path (metaDirAbsolutePath, outputDirAbsolutePath)

shortModuleName :: String
shortModuleName = "Config"

run :: Options -> CodeGenM Ɩ
run _ = do
  generateConfig PublicConfig.fullModuleName
  generateConfig InternalConfig.fullModuleName

generateConfig :: String -> CodeGenM Ɩ
generateConfig moduleName = do
  generateConfigFile moduleName "js"
  generateConfigFile moduleName "php"

generateConfigFile :: String -> String -> CodeGenM Ɩ
generateConfigFile moduleName ext = do
  let
    relativePath = moduleName <> "/foreign." <> ext
    absolutePath = outputDirAbsolutePath <> relativePath
    srcRelativePath = replaceAll (Pattern ".") (Replacement "/") moduleName
    srcAbsolutePath = metaDirAbsolutePath <> srcRelativePath <> "." <> ext

  info $ "Generating " <> relativePath <> "..."

  templateContent <- ʌ $ readTextFile UTF8 srcAbsolutePath

  let vars = extractVars templateContent

  content <- foldM replaceEnvVar templateContent vars

  ʌ $ writeTextFile UTF8 absolutePath content

  success "Generated!"

extractVars :: String -> Array String
extractVars content =
  split (Pattern "$") content
    # mapMaybe extractVarName
    # nub
    # sortBy (\a b -> compare (String.length b) (String.length a))
  where
  extractVarName :: String -> Maybe String
  extractVarName s =
    let
      varChars = String.takeWhile isVarChar s
    in
      ( String.length varChars > 0
          ? (Just varChars)
          ↔ Nothing
      )

  isVarChar :: Char -> Boolean
  isVarChar c = (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_'

replaceEnvVar :: String -> String -> CodeGenM String
replaceEnvVar content varName = do
  value <- ʌ $ lookupEnv varName

  value /= Nothing
    ? (η $ replaceAll (Pattern $ "$" <> varName) (Replacement $ value ??⇒ "") content)
    ↔ (η content)

parser :: Parser Options
parser = η {}

description :: String
description = "Generate config"

type Options = {}
