module Inter.Ui.Mod.AdPlaceholder.Style.Style where

import Proem hiding (div)

import CSS (absolute, alignItems, color, display, flex, height, justifyContent, pct, position, relative, width, zIndex, boxSizing, borderBox)
import CSS.Common (center)
import CSS.Overflow (overflow, hidden)
import Color (rgba)
import Data.Maybe (Maybe(..))
import Halogen.HTML (HTML, div)
import Halogen.HTML as HH
import Halogen.HTML.CSS (style)
import Halogen.HTML.Properties as HP
import Util.Style.Base (raw)
import Util.Style.Effect (defaultLoadingOpt, loading)
import Util.Style.Size (Size(..))
import Util.Style.Size as Size

adPlaceholder_ :: ∀ p i. String -> String -> Size -> Size -> Maybe String -> Maybe String -> Boolean -> Array (HTML p i) -> HTML p i
adPlaceholder_ idName dimStr w h wrapperClass wrapperStyle loaded children =
  let
    innerProps =
      [ style do
          display flex
          alignItems center
          justifyContent center
          color (rgba 0 0 0 0.3)
          boxSizing borderBox
          when (not loaded) do
            loading defaultLoadingOpt
              { opacity = 0.08
              , shimmerOpacity = 0.2
              }
          case w of
            Auto -> pure unit
            _ -> Size.applyToSize width w
          case h of
            Auto -> pure unit
            _ -> Size.applyToSize height h
          position relative
          raw "transition" "all 0s"
      ]

    wrapperProps =
      ( case wrapperClass of
          Just cls -> [ HP.class_ (HH.ClassName cls) ]
          Nothing -> []
      )
      <>
      ( case wrapperStyle of
          Just s -> [ HP.style s ]
          Nothing -> []
      )
  in
    HH.div wrapperProps
      [ div innerProps
          ( [ HH.div
                [ style do
                    position absolute
                    zIndex 0
                ]
                [ HH.text dimStr ]
            , div
                [ HP.id idName
                , HP.class_ (HH.ClassName "b8x-ad-container")
                , style do
                    position relative
                    zIndex 1
                    width (pct 100.0)
                    height (pct 100.0)
                    overflow hidden
                ]
                []
            ] <> children
          )
      ]
