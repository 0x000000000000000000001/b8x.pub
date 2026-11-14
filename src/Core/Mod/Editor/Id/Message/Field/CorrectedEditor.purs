module Core.Mod.Editor.Id.Message.Field.CorrectedEditor where

import Proem
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Control.Monad.Except (runExcept)
import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultShouldSanitizeInner)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Message.Command.Corrected (Corrected(AsIs))
import Core.Message.Command.Corrected (Corrected(..)) as Util
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Newtype (class Newtype)
import Foreign as Foreign

type CorrectedEditor = Util.Corrected (Maybe EditorId)

newtype CorrectedEditorField = CorrectedEditorField CorrectedEditor

instance IsField CorrectedEditorField CorrectedEditor () where
  name = "CorrectedEditor"

  description = "Editor"

  presence = Optional (η AsIs) "No change"

  sanitize json =
    if Foreign.isNull json then Corrected (Util.Corrected Nothing)
    else case runExcept (readImpl json) of
      Left _ -> Intact
      Right (eId :: EditorId) -> Corrected (Util.Corrected (Just eId))

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: "Editor"
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype CorrectedEditorField _
derive newtype instance ReadForeign CorrectedEditorField
derive newtype instance WriteForeign CorrectedEditorField
derive newtype instance Eq CorrectedEditorField
derive newtype instance Show CorrectedEditorField

