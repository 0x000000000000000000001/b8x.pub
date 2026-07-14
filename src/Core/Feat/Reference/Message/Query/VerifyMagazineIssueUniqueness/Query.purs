module Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Projection.Projection (MagazineIssue(..), findMagazineIssuesByNumberSpecialAndComplement)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Result (Result)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.MagazineIssue.Exception.MagazineIssueAlreadyReferenced (MagazineIssueAlreadyReferenced(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (any)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyMagazineIssueUniqueness = VerifyMagazineIssueUniqueness Payload

derive instance Newtype VerifyMagazineIssueUniqueness _
derive instance Generic VerifyMagazineIssueUniqueness _
derive newtype instance Random VerifyMagazineIssueUniqueness
derive newtype instance WriteForeign VerifyMagazineIssueUniqueness
derive newtype instance ReadForeign VerifyMagazineIssueUniqueness

instance Reflect VerifyMagazineIssueUniqueness where
  reflectName = reflectConstructorName @VerifyMagazineIssueUniqueness

instance IsQuery VerifyMagazineIssueUniqueness State Fields Payload Result where
  description = "Verify magazine issue uniqueness"

  cacheStrategy _ = do
    hash <- getReadModelHash @MagazineIssue Nothing
    η $ defaultCached hash

  handle (VerifyMagazineIssueUniqueness { number: newNumber, special: newSpecial, complement: newComplement }) = do
    issues <- findMagazineIssuesByNumberSpecialAndComplement newNumber newSpecial newComplement

    let
      isDuplicate (MagazineIssue i) =
        i.number == newNumber && i.special == newSpecial && i.complement == newComplement

    when
      (any isDuplicate issues)
      (throw MagazineIssueAlreadyReferenced)

    η {}
