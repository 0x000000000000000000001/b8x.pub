module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Decide where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Command.Handle.Upload as Upload
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.State (State)
import Core.Mod.MagazineIssue.Exception.MagazineIssueAlreadyReferenced (MagazineIssueAlreadyReferenced(..))
import Core.Mod.MagazineIssue.State as MagazineIssue
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

import Core.Mod.MagazineIssue.Slug.Slug (make_)
import Core.Mod.MagazineIssue.Slug.Exception (InvalidSlug(..))
import Util.Type.String.ToString (toString)
import Data.Either (Either(..))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide
  { magazineIssue }
  { id, name, legacyId, special, complement, number, cover: coverUrl, releasedAt, slug } = case magazineIssue of
  MagazineIssue.Referenced _ -> throw MagazineIssueAlreadyReferenced
  _ -> do
    slug' <- case slug of
      Just providedSlug -> η providedSlug
      Nothing -> case make_ true (toString name) of
        Right generated -> η generated
        Left _ -> throw $ InvalidSlug (toString name)

    cover <- case coverUrl of
      Just url -> Just <$> Upload.uploadImage false true url
      Nothing -> η Nothing
    η [ MagazineIssueReferenced { id, name, legacyId, special, complement, number, cover, releasedAt, slug: slug' } ]
