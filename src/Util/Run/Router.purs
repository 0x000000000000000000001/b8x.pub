module Util.Run.Router
  ( RouterBuilder
  , empty
  , on
  , build
  ) where

import Proem

import Data.Functor.Variant (VariantF)
import Data.Symbol (class IsSymbol)
import Run (Run)

foreign import data RouterBuilder :: Row (Type -> Type) -> Type -> Type

foreign import empty :: ∀ fx a. RouterBuilder fx a

foreign import _on :: ∀ f fx a. String -> (f a -> Run fx a) -> RouterBuilder fx a -> RouterBuilder fx a

on :: ∀ @sym f fx a. IsSymbol sym => (f a -> Run fx a) -> RouterBuilder fx a -> RouterBuilder fx a
on handler builder = _on (ᴠ @sym) handler builder

foreign import build :: ∀ fx fx' fx'' a. RouterBuilder fx'' a -> (VariantF fx a -> Run fx'' a) -> VariantF fx' a -> Run fx'' a
