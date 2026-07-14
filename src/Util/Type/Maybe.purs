module Util.Type.Maybe
  ((??⇒)
  , (??)
  , (⇔)
  , fromMaybe
  , maybe
  ) where

import Data.Function (apply, flip)
import Data.Maybe (Maybe)
import Data.Maybe as Maybe

fromMaybe :: ∀ a. Maybe a -> a -> a
fromMaybe = flip Maybe.fromMaybe

infixl 6 fromMaybe as ??⇒

maybe :: ∀ a b. Maybe a -> (a -> b) -> b -> b
maybe m f def = Maybe.maybe def f m

infixl 1 maybe as ??

infixr 0 apply as ⇔