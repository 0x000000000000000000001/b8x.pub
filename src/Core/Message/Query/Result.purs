module Core.Message.Query.Result where

import Proem

import Control.Monad.Except (runExcept)
import Core.Util.Validation (class IsRefinedType, makeFromJson)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Foreign (Foreign)
import Unsafe.Coerce (unsafeCoerce)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random, random)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)

data Return value
  = Given value
  | NotGivenBecauseNotNeeded
  | NotGivenBecauseNotFound
  | NotGivenBecauseNotAuthorized

derive instance Generic (Return value) _
derive instance Functor Return

instance Show value => Show (Return value) where
  show = genericShow

instance Random value => Random (Return value) where
  random = do
    b <- random @Boolean
    b ? (Given <$> random) ↔ η NotGivenBecauseNotNeeded

instance WriteForeign value => WriteForeign (Return value) where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign value => ReadForeign (Return value) where
  readImpl = genericReadImplWithDefaultOpt

-- Fold 

data Fold folded unfolded = Folded folded | Unfolded unfolded

derive instance Functor (Fold folded)

derive instance Generic (Fold folded unfolded) _
derive instance (Eq folded, Eq unfolded) => Eq (Fold folded unfolded)

instance (Show folded, Show unfolded) => Show (Fold folded unfolded) where
  show = genericShow

instance (WriteForeign folded, WriteForeign unfolded) => WriteForeign (Fold folded unfolded) where
  writeImpl = genericWriteImplWithDefaultOpt

instance (ReadForeign folded, ReadForeign unfolded) => ReadForeign (Fold folded unfolded) where
  readImpl = genericReadImplWithDefaultOpt

instance (Random folded, Random unfolded) => Random (Fold folded unfolded) where
  random = do
    b <- random @Boolean
    b ? (Folded <$> random) ↔ (Unfolded <$> random)

instance (IsRefinedType folded r, IsRefinedType unfolded r) => IsRefinedType (Fold folded unfolded) r where
  makeFromJson sanitize json = case runExcept (readImpl @(Fold Foreign Foreign) json) of
    Right (Folded f) -> case makeFromJson sanitize f of
      Right f' -> Right (Folded f')
      Left err -> Left err
    Right (Unfolded u) -> case makeFromJson sanitize u of
      Right u' -> Right (Unfolded u')
      Left err -> Left err
    Left err -> Left (unsafeCoerce err)
