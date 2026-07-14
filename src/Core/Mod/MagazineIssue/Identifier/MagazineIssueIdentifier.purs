module Core.Mod.MagazineIssue.Identifier.MagazineIssueIdentifier where

import Proem

import Control.Monad.Except as Control.Monad.Except
import Core.Exception.Exception (inj)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Identifier.Exception (IdentifierExceptionRow, InvalidMagazineIssueIdentifier(..))
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random, random)
import Yoga.JSON as Yoga.JSON

data MagazineIssueIdentifier
  = Id MagazineIssueId
  | Slug Slug

derive instance Eq MagazineIssueIdentifier
derive instance Generic MagazineIssueIdentifier _

instance Show MagazineIssueIdentifier where
  show (Id id) = "Id " <> show id
  show (Slug slug) = "Slug " <> show slug

instance Random MagazineIssueIdentifier where
  random = do
    b <- random
    if b then Id <$> random
    else Slug <$> random

instance IsRefinedType MagazineIssueIdentifier (IdentifierExceptionRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json) of
    Right val -> Right val
    Left _ -> Left $ inj $ InvalidMagazineIssueIdentifier $ Yoga.JSON.writeJSON json

instance Yoga.JSON.WriteForeign MagazineIssueIdentifier where
  writeImpl = genericWriteImplWithDefaultOpt

instance Yoga.JSON.ReadForeign MagazineIssueIdentifier where
  readImpl = genericReadImplWithDefaultOpt
