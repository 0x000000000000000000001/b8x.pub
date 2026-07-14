module Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Projection.Projection (Editor(..), findEditorsByName)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Result (Result)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Exception.EditorAlreadyReferenced (EditorAlreadyReferenced(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (any)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.String.String (normalizeForTextSearch)
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyEditorUniqueness = VerifyEditorUniqueness Payload

derive instance Newtype VerifyEditorUniqueness _
derive instance Generic VerifyEditorUniqueness _
derive newtype instance Random VerifyEditorUniqueness
derive newtype instance WriteForeign VerifyEditorUniqueness
derive newtype instance ReadForeign VerifyEditorUniqueness

instance Reflect VerifyEditorUniqueness where
  reflectName = reflectConstructorName @VerifyEditorUniqueness

instance IsQuery VerifyEditorUniqueness State Fields Payload Result where
  description = "Verify editor uniqueness"

  cacheStrategy _ = do
    hash <- getReadModelHash @Editor Nothing
    η $ defaultCached hash

  handle (VerifyEditorUniqueness payload) = do
    editors <- findEditorsByName payload.name

    let
      isDuplicate (Editor editor) =
        normalizeForTextSearch (toString editor.name) == normalizeForTextSearch (toString payload.name)

    when
      (any isDuplicate editors)
      (throw EditorAlreadyReferenced)

    η {}
