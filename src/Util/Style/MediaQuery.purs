module Util.Style.MediaQuery where

import Proem
import Data.Maybe (Maybe(..))
import Data.NonEmpty (singleton)
import CSS (CSS)
import CSS.Stylesheet (query, Feature(..))
import CSS.Media (screen, maxWidth)
import CSS.Size (Size, px)
import CSS.Property (value)

minWidth :: ∀ a. Size a -> Feature
minWidth = Feature "min-width" ◁ Just ◁ value

onMobileLte :: CSS -> CSS
onMobileLte css = query screen (singleton (maxWidth (px 768.0))) css

onTabletLte :: CSS -> CSS
onTabletLte css = query screen (singleton (maxWidth (px 1024.0))) css

onDesktopGte :: CSS -> CSS
onDesktopGte css = query screen (singleton (minWidth (px 1025.0))) css
