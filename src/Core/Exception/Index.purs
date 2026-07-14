module Core.Exception.Index where

import Proem

import Core.Feat.Exception.Index (FeatExceptionRow)
import Core.Mod.Exception.Index (ModExceptionRow)
import Data.Either (Either)
import Data.Newtype (class Newtype)
import Data.Variant (Variant)
import Run (Run)
import Run.Except (Except, runExceptAt)
import Util.I18n (class Translate, translate)
import Type.Row (type (+))

type LogicExceptionRow =
  FeatExceptionRow LogicException
    + ModExceptionRow
    + ()

newtype LogicException = LogicException (Variant LogicExceptionRow)

derive instance Newtype LogicException _

instance Translate LogicException where
  translate l (LogicException v) = translate l v

type EXCEPT_LOGIC :: Row (Type -> Type) -> Row (Type -> Type)
type EXCEPT_LOGIC fx = (exceptLogic :: Except LogicException | fx)

exceptLogic' = π :: Π "exceptLogic"

runLogicExcept :: ∀ fx a. Run (EXCEPT_LOGIC fx) a -> Run fx (Either LogicException a)
runLogicExcept = runExceptAt exceptLogic'
