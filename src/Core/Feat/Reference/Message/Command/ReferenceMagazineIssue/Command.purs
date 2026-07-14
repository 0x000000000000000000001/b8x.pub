module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Command
  ( ReferenceMagazineIssue(..)
  ) where

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Decide (decide)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Filter (filter)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Play (play)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.State (State, initialState)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.VerifyMagazineIssueSlugUniqueness (verifyMagazineIssueSlugUniqueness)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.VerifyMagazineIssueUniqueness (verifyMagazineIssueUniqueness)
import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Projection.Projection (findMagazineIssueBySlug)
import Core.Mod.MagazineIssue.Slug.Exception (InvalidSlug(..))
import Core.Mod.MagazineIssue.Slug.Slug (make_)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ReferenceMagazineIssue = ReferenceMagazineIssue Payload

derive instance Newtype ReferenceMagazineIssue _
derive instance Generic ReferenceMagazineIssue _
derive newtype instance Random ReferenceMagazineIssue
derive newtype instance WriteForeign ReferenceMagazineIssue
derive newtype instance ReadForeign ReferenceMagazineIssue

instance Reflect ReferenceMagazineIssue where
  reflectName = reflectConstructorName @ReferenceMagazineIssue

instance IsProtectedAgainstConcurrency ReferenceMagazineIssue where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    ReferenceMagazineIssue
    State
    Fields
    Payload
    Result
  where
  description = "Reference a magazine issue"

  handle payload = do
    _ <- verifyMagazineIssueUniqueness { number: payload.number, special: payload.special, complement: payload.complement }

    slug' <- case payload.slug of
      Just providedSlug -> η providedSlug
      Nothing -> case make_ true (toString payload.name) of
        Left _ -> throw $ InvalidSlug (toString payload.name)
        Right generated ->
          let
            findUnique iter = do
              let candidateStr = toString generated <> (iter == 1 ? "" ↔ "-" <> show iter)
              case make_ true candidateStr of
                Left _ -> throw $ InvalidSlug candidateStr
                Right candidate -> do
                  occupant <- findMagazineIssueBySlug candidate
                  case occupant of
                    Just _ -> findUnique (iter + 1)
                    Nothing -> η candidate
          in
            findUnique 1

    _ <- verifyMagazineIssueSlugUniqueness { slug: slug' }

    let payload' = payload { slug = Just slug' }

    defaultHandle @ReferenceMagazineIssue (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload'

  