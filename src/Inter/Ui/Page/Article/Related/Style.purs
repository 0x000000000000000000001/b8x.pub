module Inter.Ui.Page.Article.Related.Style
  (wrapper_
  , wrapperC
  , staticStyle
  ) where

import Proem hiding (div)

import CSS (em, marginTop)
import CSS as CSS
import Halogen.HTML (HTML, div)
import Util.Style.Classname (classes, generateStaticClass, refineClass')
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Related.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

c :: String -> String
c name = refineClass' staticClass name

wrapperC :: String
wrapperC = c "wrapper"

staticStyle :: CSS.CSS
staticStyle = do
  wrapperC .? do
    marginTop (em 2.0)

wrapper_ :: ∀ w i. Array (HTML w i) -> HTML w i
wrapper_ children = div [ classes [ wrapperC ] ] children
