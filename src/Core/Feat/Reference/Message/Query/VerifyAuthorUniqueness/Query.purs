module Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Exception.Exception (throw)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Payload (Fields, Payload)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Result (Result)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.State (State)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Projection.Projection (Author(..), findAuthorsByName)
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Core.Mod.Author.Exception.AuthorAlreadyReferenced (AuthorAlreadyReferenced(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (any, intersect, length)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Util.Type.String.String (normalizeForTextSearch)
import Util.Type.String.ToString (toString)

newtype VerifyAuthorUniqueness = VerifyAuthorUniqueness Payload

derive instance Newtype VerifyAuthorUniqueness _
derive instance Generic VerifyAuthorUniqueness _
derive newtype instance Random VerifyAuthorUniqueness
derive newtype instance WriteForeign VerifyAuthorUniqueness
derive newtype instance ReadForeign VerifyAuthorUniqueness

instance Reflect VerifyAuthorUniqueness where
  reflectName = reflectConstructorName @VerifyAuthorUniqueness

instance IsQuery VerifyAuthorUniqueness State Fields Payload Result where
  description = "Verify that an author is unique (by name and legacy IDs)"

  cacheStrategy _ = do
    hash <- getReadModelHash @Author Nothing
    η $ defaultCached hash

  handle (VerifyAuthorUniqueness { name: newName, legacyIds: newLegacyIds }) = do
    authors <- findAuthorsByName newName

    let
      isDuplicate (Author b) =
        (normalizeForTextSearch (toString b.name) == normalizeForTextSearch (toString newName))
          && (length newLegacyIds > 0)
          && (length (intersect b.legacyIds newLegacyIds) > 0)

    when
      (any isDuplicate authors)
      (throw $ AuthorAlreadyReferenced { key: "name", value: toString newName })

    η {}
