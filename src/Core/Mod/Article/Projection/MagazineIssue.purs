module Core.Mod.Article.Projection.MagazineIssue where

import Foreign as Foreign
import Proem
import Foreign.Index as Foreign.Index
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Section.Section (SectionF)
import Core.Mod.MagazineIssue.CustomSection.Id.Id (CustomSectionId)
import Core.Mod.MagazineIssue.CustomSection.Name.Name as CustomSectionName
import Core.Mod.Article.PageNumber.PageNumber (PageNumber)
import Core.Mod.MagazineIssue.Slug.Slug as MagazineIssueSlug
import Data.Maybe (Maybe(..))
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Foreign (Foreign)
import Data.Traversable (traverse)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Util.Type.Random (class Random)

newtype MagazineIssue = MagazineIssue
  { issue :: { id :: MagazineIssueId, slug :: MagazineIssueSlug.Slug }
  , section :: Maybe (SectionF { id :: CustomSectionId, name :: CustomSectionName.Name })
  , pageNumber :: PageNumber
  , onCover :: Boolean
  }

derive instance Newtype MagazineIssue _
derive instance Generic MagazineIssue _
derive instance Eq MagazineIssue
derive instance Ord MagazineIssue
derive newtype instance WriteForeign MagazineIssue
derive newtype instance Random MagazineIssue

instance ReadForeign MagazineIssue where
  readImpl json = do
    obj <- readImpl json
    issueJson <- (Foreign.Index.readProp "issue" obj >>= readImpl)
    issue <- decodeIssueJson issueJson
    sectionJson <- (Foreign.Index.readProp "section" obj >>= readImpl)
    section <- decodeSectionJson sectionJson
    pageNumber <- (Foreign.Index.readProp "pageNumber" obj >>= readImpl)
    onCover <- (Foreign.Index.readProp "onCover" obj >>= readImpl)
    η $ MagazineIssue { issue, section, pageNumber, onCover }

decodeIssueJson :: Foreign -> Foreign.F { id :: MagazineIssueId, slug :: MagazineIssueSlug.Slug }
decodeIssueJson json = do
  obj <- readImpl json
  id <- (Foreign.Index.readProp "id" obj >>= readImpl)
  slug <- (Foreign.Index.readProp "slug" obj >>= readImpl)
  pure { id, slug }

decodeSectionJson :: Foreign -> Foreign.F (Maybe (SectionF { id :: CustomSectionId, name :: CustomSectionName.Name }))
decodeSectionJson json = do
  mSection <- readImpl json
  case mSection of
    Nothing -> η Nothing
    Just (sectionF :: SectionF Foreign) -> do
      mapped <- traverse decodeCustomSectionJson sectionF
      η (Just mapped)

decodeCustomSectionJson :: Foreign -> Foreign.F { id :: CustomSectionId, name :: CustomSectionName.Name }
decodeCustomSectionJson json = do
  obj <- readImpl json
  id <- (Foreign.Index.readProp "id" obj >>= readImpl)
  name <- (Foreign.Index.readProp "name" obj >>= readImpl)
  η { id, name }

instance Show MagazineIssue where
  show = genericShow


