module Core.Mod.Time.Inter.Cli where

import Proem
import Core.Mod.Message.Field.Inter.Cli.Type (CustomCliAct, CustomCliActResult(..))
import Inter.Cli.Util.Prefix as Prefix
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Core.Mod.Time.Instant (parseParisTime)

askParisTime :: ∀ fx. CustomCliAct fx
askParisTime logPrefix = loop
  where
  loop = do
    let p = if logPrefix == "" then "" else logPrefix <> " "
    
    let
      askInt prompt = do
        str <- Prefix.ask prompt
        case Int.fromString str of
          Just i -> η i
          Nothing -> do
            Prefix.log "Please enter a valid number."
            askInt prompt
            
    Prefix.log $ "Let's define the " <> p <> "time (Europe/Paris timezone):"
    
    year <- askInt "Year (e.g. 2026):"
    month <- askInt "Month (1-12):"
    day <- askInt "Day (1-31):"
    hour <- askInt "Hour (0-23):"
    minute <- askInt "Minute (0-59):"
    
    case parseParisTime year month day hour minute of
      Just isoStr -> do
        Prefix.log $ "Parsed as ISO: " <> isoStr
        η $ UserInput isoStr
      Nothing -> do
        Prefix.log "Invalid date/time. Let's try again."
        loop
