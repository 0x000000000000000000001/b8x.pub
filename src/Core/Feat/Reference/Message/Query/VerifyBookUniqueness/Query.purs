module Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Query where

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Projection.Projection (Book(..), findBooksByName)
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Result (Result)
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Book.Exception.BookAlreadyReferenced (BookAlreadyReferenced(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (any)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Set as Set
import Util.Type.Random (class Random)
import Util.Type.String.String (normalizeForTextSearch)
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyBookUniqueness = VerifyBookUniqueness Payload

derive instance Newtype VerifyBookUniqueness _
derive instance Generic VerifyBookUniqueness _
derive newtype instance Random VerifyBookUniqueness
derive newtype instance WriteForeign VerifyBookUniqueness
derive newtype instance ReadForeign VerifyBookUniqueness

instance Reflect VerifyBookUniqueness where
  reflectName = reflectConstructorName @VerifyBookUniqueness

instance IsQuery VerifyBookUniqueness State Fields Payload Result where
  description = "Verify book uniqueness"

  cacheStrategy _ = do
    hash <- getReadModelHash @Book Nothing
    η $ defaultCached hash

  handle (VerifyBookUniqueness payload) = do
    books <- findBooksByName payload.name

    let
      newAuthorsSet = Set.fromFoldable payload.authors
      isDuplicate (Book b) =
        (normalizeForTextSearch (toString b.name) == normalizeForTextSearch (toString payload.name))
          && (Set.fromFoldable b.authors == newAuthorsSet)
          && (b.editor == payload.editor)

    when
      (any isDuplicate books)
      (throw $ BookAlreadyReferenced (Just { name: payload.name, authors: payload.authors, editor: payload.editor }))

    η {}
