module Util.Style.Transform where

import Proem hiding (bottom, top)
import CSS (CSS) as CSS
import CSS (Transformation, pct, rem, transform, translate)

translatePct :: Number -> Number -> Transformation
translatePct x y = translate (pct x) (pct y)

translateRem :: Number -> Number -> Transformation
translateRem x y = translate (rem x) (rem y)

transformTranslatePct :: Number -> Number -> CSS.CSS
transformTranslatePct x y = transform $ translatePct x y

transformTranslateRem :: Number -> Number -> CSS.CSS
transformTranslateRem x y = transform $ translateRem x y
