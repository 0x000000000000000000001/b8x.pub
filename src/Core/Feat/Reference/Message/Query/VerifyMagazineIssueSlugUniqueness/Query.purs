module Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Query where

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Projection.Projection (MagazineIssue, findMagazineIssueBySlug)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Result (Result)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Exception.MagazineIssueSlugAlreadyTaken (MagazineIssueSlugAlreadyTaken(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyMagazineIssueSlugUniqueness = VerifyMagazineIssueSlugUniqueness Payload

derive instance Newtype VerifyMagazineIssueSlugUniqueness _
derive instance Generic VerifyMagazineIssueSlugUniqueness _
derive newtype instance Random VerifyMagazineIssueSlugUniqueness
derive newtype instance WriteForeign VerifyMagazineIssueSlugUniqueness
derive newtype instance ReadForeign VerifyMagazineIssueSlugUniqueness

instance Reflect VerifyMagazineIssueSlugUniqueness where
  reflectName = reflectConstructorName @VerifyMagazineIssueSlugUniqueness

instance IsQuery VerifyMagazineIssueSlugUniqueness State Fields Payload Result where
  description = "Verify magazine issue slug uniqueness"

  cacheStrategy _ = do
    hash <- getReadModelHash @MagazineIssue Nothing
    η $ defaultCached hash

  handle (VerifyMagazineIssueSlugUniqueness { slug: newSlug }) = do
    mMagazineIssue <- findMagazineIssueBySlug newSlug
    case mMagazineIssue of
      Just _ -> throw $ MagazineIssueSlugAlreadyTaken newSlug
      Nothing -> η {}
