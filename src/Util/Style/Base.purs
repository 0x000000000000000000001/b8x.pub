module Util.Style.Base where

import Proem

import CSS (class Val, CSS, Key(..), fromString, prefixed)
import CSS as CSS
import CSS.Common (browsers)

raw_ :: ∀ a. (Val a) => String -> a -> CSS
raw_ key = CSS.key (Key $ fromString key)

-- With multi-browser prefixes.
raw :: ∀ a. (Val a) => String -> a -> CSS
raw key value = prefixed (browsers <> fromString key) value

noCss :: CSS
noCss = ηι
