module Util.Style.Typography where

import Proem hiding (bottom, top)

import CSS (CSS) as CSS
import CSS (bold, fontFamily, fontSize, fontWeight, pct, rem)
import Data.NonEmpty ((:|))
import CSS.Font (serif)
import CSS.TextAlign (textAlign, center)
import Util.Style.Base (raw, raw_)

textAlignCenter :: CSS.CSS
textAlignCenter = textAlign center

userSelectNone :: CSS.CSS
userSelectNone = raw "user-select" "none"

secondaryFont :: CSS.CSS
secondaryFont = fontFamily [ "Libre Baskerville" ] (serif :| [])

primaryFont :: CSS.CSS
primaryFont = fontFamily [ "Literata" ] (serif :| [])

fontSizePct :: Number -> CSS.CSS
fontSizePct p = fontSize (pct p)

fontSizeRem :: Number -> CSS.CSS
fontSizeRem r = fontSize (rem r)

lineHeight :: Number -> CSS.CSS
lineHeight r = raw "line-height" $ show r

lineHeightRem :: Number -> CSS.CSS
lineHeightRem r = raw "line-height" $ show r <> "rem"

letterSpacingRem :: Number -> CSS.CSS
letterSpacingRem r = raw "letter-spacing" $ show r <> "rem"

fontWeightBold :: CSS.CSS
fontWeightBold = fontWeight bold

content :: String -> CSS.CSS
content s = raw "content" $ "\"" <> s <> "\""

textStroke :: String -> CSS.CSS
textStroke t = raw "text-stroke" t

textShadowNone :: CSS.CSS
textShadowNone = raw_ "text-shadow" "none"

textDecorationInherit :: CSS.CSS
textDecorationInherit = raw_ "text-decoration" "inherit"

whiteSpacePreLine :: CSS.CSS
whiteSpacePreLine = raw_ "white-space" "pre-line"
