module Inter.Ui.Mod.Loader.Style.Style
  (loader
  , loader_
  , staticClass
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS as CSS
import DOM.HTML.Indexed (HTMLdiv)
import Halogen.HTML (HTML, Node, div)
import Util.Style.Classname (class_, generateStaticClass)
import Util.Style.Position (positionRelative)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.Loader.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

-- | This wrapper is useful when we want to position the loader
-- | without interfering with its animation.
staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    positionRelative -- For zIndex customization

loader :: ∀ w i. Node HTMLdiv w i
loader props = div ([ class_ staticClass ] <> props)

loader_ :: ∀ w i. Array (HTML w i) -> HTML w i
loader_ = loader []
