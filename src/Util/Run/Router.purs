module Util.Run.Router
  ( RouterBuilder
  , empty
  , on
  , build
  ) where

import Proem

import Data.Functor.Variant (UnvariantF(..), VariantF, unvariantF)
import Data.Symbol (class IsSymbol)
import Prim.Row as Row
import Run (Run)

foreign import data RouterBuilder :: Row (Type -> Type) -> Type -> Type

foreign import empty :: ∀ fx a. RouterBuilder fx a

foreign import _on :: ∀ f fx a. String -> (f a -> Run fx a) -> RouterBuilder fx a -> RouterBuilder fx a

on :: ∀ @sym f fx a. IsSymbol sym => (f a -> Run fx a) -> RouterBuilder fx a -> RouterBuilder fx a
on handler builder = _on (ᴠ @sym) handler builder

foreign import _build :: ∀ fx fx' fx'' a value. RouterBuilder fx'' a -> (VariantF fx a -> Run fx'' a) -> String -> value -> VariantF fx' a -> Run fx'' a

build :: ∀ fx fx' fx'' a. RouterBuilder fx'' a -> (VariantF fx a -> Run fx'' a) -> VariantF fx' a -> Run fx'' a
build builder fallback variant = case unvariantF variant of
  UnvariantF dispatch -> dispatch route
  where
  route :: ∀ sym f rest. IsSymbol sym => Row.Cons sym f rest fx' => Functor f => Π sym -> f a -> Run fx'' a
  route _ value = _build builder fallback (ᴠ @sym) value variant
