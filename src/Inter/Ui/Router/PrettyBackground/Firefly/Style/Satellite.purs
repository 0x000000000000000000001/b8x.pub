module Inter.Ui.Router.PrettyBackground.Firefly.Style.Satellite where

import Proem hiding (div)

import CSS as CSS
import CSS (fromString, key, rgba)
import CSS.Property (Key, Value, value)
import Data.String (Pattern(..), Replacement(..), replace, replaceAll)
import Inter.Ui.Router.PrettyBackground.Firefly.Style.Style as Firefly
import Util.Style.Base (raw)
import Util.Style.Classname (generateStaticClass)
import Util.Power (isPowerful)
import Util.Style.Selector ((.?))

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.PrettyBackground.Firefly.Style.Satellite"

staticClass :: String
staticClass = generateStaticClass fullModuleName # replace (Pattern "Satellite") (Replacement "FireflySatellite")

varXName :: String
varXName = "--firefly-satellite-x"

varYName :: String
varYName = "--firefly-satellite-y"

shadowValue :: Value
shadowValue =
  let
    -- We may open this params to the outside, in the future
    color = rgba 97 17 15 0.22
    amp = 0.04
    blurRem = if isPowerful then 0.7 else 0.3
  in
    (fromString
        $
          """
          calc((var(${satelliteVarXName}, 50vw) - var(${varXName}, 50vw)) * ${amp})
          calc((var(${satelliteVarYName}, 50vh) - var(${varYName}, 50vh)) * ${amp})
          ${blurRem}rem
          """
        # replaceAll (Pattern "${varXName}") (Replacement Firefly.varXName)
        # replaceAll (Pattern "${varYName}") (Replacement Firefly.varYName)
        # replaceAll (Pattern "${satelliteVarXName}") (Replacement varXName)
        # replaceAll (Pattern "${satelliteVarYName}") (Replacement varYName)
        # replaceAll (Pattern "${amp}") (Replacement $ show amp)
        # replaceAll (Pattern "${blurRem}") (Replacement $ show blurRem)
    ) <> value color

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    raw "transition" "none"
    key (fromString "box-shadow" :: Key Value) shadowValue
