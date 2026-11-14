module Core.Mod.Newsletter.Inter.Cli where

import Proem

import Core.Feat.Effect.Generate (now)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Projection (Newsletter(..), NewsletterFilter(..), findNewsletters)
import Core.Mod.Message.Field.Inter.Cli.Type (BaseCliFx, CustomCliAct, CustomCliActResult(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt)
import Core.Mod.Projection.Finder.Sort as Sort
import Core.Mod.Time.Instant (Instant(..), toHumanParisDate)
import Data.Array as Array
import Data.DateTime.Instant as Base
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Data.Time.Duration (Milliseconds(..))
import Inter.Cli.Util.Prefix as Prefix
import Run (Run)
import Util.Type.String.ToString (toString)

maxNewslettersShown :: Int
maxNewslettersShown = 16

askNewsletter :: ∀ fx. CustomCliAct fx
askNewsletter logPrefix = loop
  where
  loop :: ∀ fx'. Run (BaseCliFx fx') CustomCliActResult
  loop = do
    nowMs <- now
    let
      currentInstant :: Instant
      currentInstant = case Base.instant (Milliseconds nowMs) of
        Just instant -> Instant instant
        Nothing -> bottom

      upcomingFilter :: NewsletterFilter
      upcomingFilter = NewsletterIsScheduledForBetween { start: currentInstant, end: top }

    { items: newsletters } <- findNewsletters
      ( defaultFindOpt
          { filter = Just upcomingFilter
          , limit = Finite maxNewslettersShown
          , sort = [ Sort.by @"scheduledFor" Sort.Asc ]
          }
      )

    if Array.length newsletters == 0 then do
      Prefix.log "No upcoming newsletter found."
      η $ UserInput ""
    else do
      let
        p = if logPrefix == "" then "" else logPrefix <> " "

        formatNewsletter :: Int -> Newsletter -> String
        formatNewsletter idx (Newsletter { scheduledFor, articles }) =
          "   - " <> show idx <> ": " <> toHumanParisDate scheduledFor <> " (" <> show (Array.length articles) <> " articles)"

        newslettersStr = joinWith "\n" (Array.mapWithIndex formatNewsletter newsletters)

      Prefix.log ("Upcoming " <> p <> "newsletters:")
      Prefix.log newslettersStr

      choiceStr <- Prefix.ask "Type the number of the chosen newsletter, or 'retry' to refresh the list:"

      if choiceStr == "retry" then do
        Prefix.log "Let's refresh the list."
        loop
      else case Int.fromString choiceStr of
        Nothing -> do
          Prefix.log "Invalid number. Let's refresh the list."
          loop
        Just idx -> case Array.index newsletters idx of
          Nothing -> do
            Prefix.log "This number is not in the list."
            loop
          Just (Newsletter { id, scheduledFor }) -> do
            Prefix.log ("Selected newsletter: " <> toHumanParisDate scheduledFor)
            η $ UserInput (toString id)
