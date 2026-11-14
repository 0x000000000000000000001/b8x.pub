module Inter.Ui.Mod.StopPub.Style
  ( imageClass
  , staticStyle
  , wrapperClass
  ) where

import Proem

import CSS as CSS
import Util.Style.Classname (generateStaticClass, refineClass')
import Util.Style.Selector ((.?))
import Util.Style.Base (raw)
import Util.Style.MediaQuery (onMobileLte)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.StopPub.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

imageClass :: String
imageClass = refineClass' staticClass "image"

wrapperClass :: String
wrapperClass = refineClass' staticClass "wrapper"

staticStyle :: CSS.CSS
staticStyle = do
  wrapperClass .? do
    raw "transform" "translate(var(--stop-pub-dt-x), var(--stop-pub-dt-y))"
    onMobileLte do
      raw "transform" "translate(var(--stop-pub-mb-x), var(--stop-pub-mb-y))"

  imageClass .? do
    raw "width" "3.0rem !important"
    raw "height" "auto !important"

    onMobileLte do
      raw "width" "2.0rem !important"
