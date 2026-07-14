module Core.Exception.Exception where

import Proem

import Data.Newtype (class Newtype, wrap)
import Data.Variant (Variant, expand)
import Prim.Row (class Union)
import Run (Run)
import Run.Except (Except, throwAt)
import Util.I18n (class Translate)
import Util.Lexicon.ExceptLogic (exceptLogic')
import Util.Type.Type (class Reflect)

class (Translate e, Reflect e) <= IsLogicException e (r :: Row Type) | e -> r where
  inj :: e -> Variant r

throw
  :: ∀ e n r fx a
   . IsLogicException e r
  => Newtype n (Variant r)
  => e
  -> Run (exceptLogic :: Except n | fx) a
throw = throwAt exceptLogic' ◁ wrap ◁ inj

throw'
  ∷ ∀ lt r gt n fx a
   . Union lt r gt
  => Newtype n (Variant gt)
  => Variant lt
  -> Run (exceptLogic :: Except n | fx) a
throw' = throwAt exceptLogic' ◁ wrap ◁ expand

throw''
  ∷ ∀ lt r gt e n fx a
   . Union lt r gt
  => IsLogicException e lt
  => Newtype n (Variant gt)
  => e
  -> Run (exceptLogic :: Except n | fx) a
throw'' = throwAt exceptLogic' ◁ wrap ◁ expand ◁ inj
