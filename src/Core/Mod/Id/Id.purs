module Core.Mod.Id.Id
  ( Id
  , make
  , make_
  , generate
  , unsafeGenerate
  , unsafeFromString
  , unsafeFromUlid
  ) where

import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON as Yoga.JSON
import Proem

import Core.Exception.Exception (inj, throw')
import Core.Mod.Id.Exception (IdExceptionRow, InvalidId(..))
import Core.Mod.Projection.SearchIndex (class IsScalar)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.String (trim)
import Data.Variant (Variant)
import Effect.Class (class MonadEffect)
import Effect.Unsafe (unsafePerformEffect)
import Partial.Unsafe (unsafeCrashWith)
import Run (Run)
import Run.Except (Except)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (class FromString, class ToString, toString)
import Util.Type.Ulid (Ulid, generateUlid, parseUlid)

newtype Id (a :: Type) = Id Ulid

make_ :: ∀ a. String -> Either (Variant (IdExceptionRow ())) (Id a)
make_ str = do
  let str' = trim str

  case parseUlid str' of
    Just ulid -> Right $ Id ulid
    Nothing -> Left $ inj $ InvalidId str

make
  :: ∀ r n fx a
   . Newtype n (Variant (IdExceptionRow r))
  => String
  -> Run (exceptLogic ∷ Except n | fx) (Id a)
make str = case make_ str of
  Left e -> throw' e
  Right id -> η id

generate :: ∀ m a. MonadEffect m => m (Id a)
generate = Id <$> ʌ generateUlid

unsafeGenerate :: ∀ a. Ɩ -> Id a
unsafeGenerate _ = unsafePerformEffect (Id <$> generateUlid)

unsafeFromString
  :: ∀ a
   . String
  -> Id a
unsafeFromString str =
  case parseUlid str of
    Just ulid -> Id ulid
    Nothing -> unsafeCrashWith "Invalid ULID"

unsafeFromUlid
  :: ∀ a
   . Ulid
  -> Id a
unsafeFromUlid ulid = Id ulid

instance ToString (Id a) where
  toString (Id ulid) = toString ulid

instance FromString (Id a) where
  fromString str = case parseUlid str of
    Just ulid -> Just (Id ulid)
    Nothing -> Nothing

derive instance Eq (Id a)
derive instance Ord (Id a)
derive newtype instance Show (Id a)
derive newtype instance Yoga.JSON.ReadForeign (Id a)

instance IsRefinedType (Id a) (IdExceptionRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json) of
    Left _ -> Left $ inj $ InvalidId $ Yoga.JSON.writeJSON json
    Right str -> make_ str

instance Random (Id a) where
  random = do
    ulid <- ʌ generateUlid
    η $ Id ulid

instance IsScalar (Id a)



instance Yoga.JSON.WriteForeign (Id a) where
  writeImpl (Id u) = Yoga.JSON.writeImpl u
