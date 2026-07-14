module Inter.Ui.Page.Article.Hero.Illustration.Style.Style
  (class'
  , illustration
  , illustration_
  , illustrationLoading_
  , staticClass
  , staticStyle
  ) where

import Proem

import CSS (alignItems, column, flexDirection, flexGrow, flexShrink, zIndex)
import CSS as CSS
import CSS.Common (center)
import DOM.HTML.Indexed (HTMLfigure)
import Halogen.HTML (HTML, Node, figure)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Effect (borderRadiusRem1)
import Util.Style.Layout (displayFlex, margin0, maxHeightRem, maxWidthRem, minHeightRem, minWidthRem)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Hero.Illustration.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticClassWhenLoadingPortrait :: String
staticClassWhenLoadingPortrait = refineClass' staticClass "loading-portrait"

staticClassWhenLoadingLandscape :: String
staticClassWhenLoadingLandscape = refineClass' staticClass "loading-landscape"

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    displayFlex
    flexDirection column
    alignItems center
    flexGrow 1.0
    flexShrink 1.0
    zIndex 100
    margin0

  staticClassWhenLoadingPortrait .? do
    borderRadiusRem1 1.0
    maxHeightRem 40.0
    minHeightRem 40.0
    minWidthRem 30.0

  staticClassWhenLoadingLandscape .? do
    borderRadiusRem1 1.0
    maxHeightRem 45.0
    maxWidthRem 60.0
    minHeightRem 40.0
    minWidthRem 60.0

illustration :: ∀ w i. InstanceId -> Node HTMLfigure w i
illustration id props = figure ([ classes [ staticClass, class' id ] ] <> props)

illustration_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
illustration_ id = illustration id []

illustrationLoading_ :: ∀ w i. InstanceId -> Boolean -> HTML w i
illustrationLoading_ id isPortrait =
  figure
    [ classes
        [ staticClass
        , class' id
        , if isPortrait then staticClassWhenLoadingPortrait else staticClassWhenLoadingLandscape
        ]
    ]
    []
