module Core.Mod.Article.MagazineIssue.MagazineIssue where

import Proem
import Data.List.NonEmpty as NonEmpty
import Foreign as Foreign

import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Mod.Article.PageNumber.PageNumber (PageNumber)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Section.Section (Section)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Control.Monad.Except (runExcept)
import Data.Bifunctor (lmap)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Util.Type.Random (class Random)


newtype MagazineIssue = MagazineIssue
  { issue :: MagazineIssueId
  , section :: Maybe Section
  , pageNumber :: PageNumber
  , onCover :: Boolean
  }

derive instance Eq MagazineIssue
derive instance Ord MagazineIssue
derive instance Generic MagazineIssue _
derive instance Newtype MagazineIssue _
derive newtype instance Random MagazineIssue
derive newtype instance ReadForeign MagazineIssue
derive newtype instance WriteForeign MagazineIssue

instance Show MagazineIssue where
  show = genericShow

instance IsRefinedType MagazineIssue (MalformedPayloadValueRow ()) where
  makeFromJson _ json =
    lmap (\_ -> inj $ MalformedPayloadValue { innerPath: Nothing, error: NonEmpty.singleton (Foreign.ForeignError "Expected MagazineIssue") })
      (runExcept (readImpl json))
