module Core.Feat.Reference.Message.Command.CorrectAuthor.Decide where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Payload (Payload)
import Core.Feat.Reference.Message.Command.CorrectAuthor.State (State)
import Core.Message.Command.Corrected (Corrected(..))
import Core.Message.Command.Handle.Download (DOWNLOAD)
import Core.Message.Command.Handle.Download as Download
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Command.Handle.Upload as Upload
import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Exception.AuthorNotReferenced (AuthorNotReferenced(..))
import Core.Mod.Author.State as Author
import Core.Mod.Html.Html as Html
import Core.Mod.Url.Url (Url)
import Data.Maybe (Maybe(..), isNothing)
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide
  { author }
  { id, biography: biographyCorrection } = checkAuthor
  where
  checkAuthor :: Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
  checkAuthor = case author of
    Author.Referenced currentBiography -> evaluate currentBiography
    _ -> throw $ AuthorNotReferenced id

  evaluate :: Biography -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
  evaluate currentBiography = case biographyCorrection of
    AsIs -> η []
    Corrected Nothing ->
      η $ isNothing currentBiography ? [] ↔ [ AuthorBiographyCorrected { author: id, biography: Nothing } ]
    Corrected (Just url) -> do
      biography <- Just <$> fetchBiography url
      η $ currentBiography == biography ? [] ↔ [ AuthorBiographyCorrected { author: id, biography } ]

  fetchBiography :: Url -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) Html.NonEmptyHtml
  fetchBiography url = do
    fetchedStr <- Download.downloadHtml url
    Html.unsafeFromString <$> Upload.uploadHtmlImages true fetchedStr
