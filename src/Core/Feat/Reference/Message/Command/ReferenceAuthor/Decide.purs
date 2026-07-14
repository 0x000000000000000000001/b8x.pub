module Core.Feat.Reference.Message.Command.ReferenceAuthor.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Command.Handle.Upload as Upload
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.State (State)
import Core.Mod.Author.Exception.AuthorAlreadyReferenced (AuthorAlreadyReferenced(..))
import Core.Mod.Author.State as Author
import Util.Type.String.ToString (toString)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))
import Core.Mod.Html.Html as Html
import Data.Traversable (traverse)

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide state { id, name, biography, legacyIds, portrait: portraitUrl } = case state of
  Author.Referenced _ -> throw $ AuthorAlreadyReferenced { key: "id", value: toString id }
  _ -> do
    portrait <- case portraitUrl of
      Just url -> Just <$> Upload.uploadImage true true url
      Nothing -> η Nothing

    updatedBiography <- traverse (\h -> Html.unsafeFromString <$> Upload.uploadHtmlImages true (toString h)) biography

    η [ AuthorReferenced { id, name, biography: updatedBiography, legacyIds, portrait } ]
