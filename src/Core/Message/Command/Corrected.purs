module Core.Message.Command.Corrected where

import Proem
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Yoga.JSON.Generics (defaultOptions, genericReadForeignTaggedSum, genericWriteForeignTaggedSum)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Util.Type.Random (class Random, random)
import Effect.Random (randomInt)
import Core.Util.Validation (class IsRefinedType, makeFromJson)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Exception.Exception (inj)
import Foreign as Foreign
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Prim.Row (class Union)
import Type.Row (type (+))
import Data.Variant (expand)

data Corrected a = AsIs | Corrected a

derive instance Eq a => Eq (Corrected a)
derive instance Generic (Corrected a) _
instance ReadForeign a => ReadForeign (Corrected a) where
  readImpl = genericReadForeignTaggedSum defaultOptions

instance WriteForeign a => WriteForeign (Corrected a) where
  writeImpl = genericWriteForeignTaggedSum defaultOptions

instance Show a => Show (Corrected a) where
  show = genericShow

instance Random a => Random (Corrected a) where
  random = do
    i <- ʌ $ randomInt 0 1
    if i == 0 then η AsIs else Corrected <$> random

instance (IsRefinedType a r, Union r rx (MalformedPayloadValueRow + r)) => IsRefinedType (Corrected a) (MalformedPayloadValueRow + r) where
  makeFromJson sanitize json =
    case runExcept (readImpl json :: Foreign.F (Corrected Foreign.Foreign)) of
      Right AsIs -> Right AsIs
      Right (Corrected innerJson) -> case makeFromJson sanitize innerJson of
        Right inner -> Right (Corrected inner)
        Left err -> Left (expand err)
      Left err -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error: err }

