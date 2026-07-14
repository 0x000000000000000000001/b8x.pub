module Util.Style.Selector where

import Proem hiding (bottom, top)

import CSS (App(..), CSS, Rule(..), rule, runS) as CSS
import CSS (Refinement, Selector, fromString, select, selector, star)
import Util.Style.Classname (stripDotPrefixFromClassName)

any :: Selector
any = star

all :: Selector
all = star

svg :: Selector
svg = fromString "svg"

focus :: Refinement
focus = fromString ":focus"

disabled :: Refinement
disabled = fromString ":disabled"

after :: Refinement
after = fromString "::after"

before :: Refinement
before = fromString "::before"

placeholder :: Refinement
placeholder = fromString "::placeholder"

has :: Selector -> Refinement
has sel = fromString $ ":has(" <> selector sel <> ")"

firstLetter :: Refinement
firstLetter = fromString "::first-letter"

div :: Selector
div = fromString "div"

infixr 5 select as :?
infixr 0 select as :*

classSelect :: String -> CSS.CSS -> CSS.CSS
classSelect sel rs = select (fromString $ "." <> stripDotPrefixFromClassName sel) rs

infixr 0 classSelect as .*
infixr 5 classSelect as .?

rawSelect :: String -> CSS.CSS -> CSS.CSS
rawSelect sel rs = select (fromString sel) rs

infixr 5 rawSelect as ¨?
infixr 0 rawSelect as ¨*

childBlock :: Selector -> CSS.CSS -> CSS.CSS
childBlock c block = CSS.rule $ CSS.Nested (CSS.Child c) (CSS.runS block)

infixr 0 childBlock as :<

classChildBlock :: String -> CSS.CSS -> CSS.CSS
classChildBlock c block = childBlock (fromString $ "." <> stripDotPrefixFromClassName c) block

infixr 0 classChildBlock as .<

rawChildBlock :: String -> CSS.CSS -> CSS.CSS
rawChildBlock c block = childBlock (fromString c) block

infixr 0 rawChildBlock as ¨<

refineBlock :: Refinement -> CSS.CSS -> CSS.CSS
refineBlock r block = CSS.rule $ CSS.Nested (CSS.Self r) (CSS.runS block)

infixr 0 refineBlock as :&

classRefineBlock :: String -> CSS.CSS -> CSS.CSS
classRefineBlock c block = refineBlock (fromString $ "." <> stripDotPrefixFromClassName c) block

infixr 0 classRefineBlock as .&

rawRefineBlock :: String -> CSS.CSS -> CSS.CSS
rawRefineBlock c block = refineBlock (fromString c) block

infixr 0 rawRefineBlock as ¨&
