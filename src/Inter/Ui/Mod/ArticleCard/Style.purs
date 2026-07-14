module Inter.Ui.Mod.ArticleCard.Style
  ( fullModuleName
  , staticClass
  , staticStyle
  , articleCard
  , articleCard_
  , style
  , sheet
  , illustration
  , illustration_
  , illustrationWrapper
  , illustrationBlur
  , illustrationContain
  , title
  , title_
  , linkClass
  , leadClass
  , textOnlyClass
  , lead
  , lead_
  , author
  , author_
  , popOnHoverClass
  , baseShadowClass
  ) where

import Proem hiding (div)

import CSS (backgroundColor, borderBox, borderColor, boxSizing, color, column, flexDirection, height, hover, margin, opacity, rgba, solid, textTransform, white, width)
import CSS as CSS
import CSS.Overflow (overflow, hidden)
import CSS.Size (px, pct)
import CSS.Text.Transform (uppercase)
import CSS.Transform (transforms, translateY, scale)
import DOM.HTML.Indexed (HTMLdiv, HTMLh3, HTMLh4, HTMLimg, HTMLp)
import Halogen.HTML (HTML, Leaf, Node, div, h3, h4, img, p)
import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Power (isPowerful)
import Util.Style.Base (raw)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Effect (borderRadiusRem1, borderStyle, borderWidth1, boxShadow, cursorPointer, defaultLoadingOpt, loading)
import Util.Style.Image (cover, objectFit, contain)
import Util.Style.Layout (displayFlex, padding1, visibilityHidden, widthPct, widthPct100)
import Util.Style.Position (positionAbsolute, positionRelative)
import Util.Style.Selector ((.?), (.*), (:&), (.&))
import Util.Style.Typography (fontWeightBold, secondaryFont)

fullModuleName :: String
fullModuleName = "Inter.Ui.Mod.ArticleCard.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

textOnlyClass :: String
textOnlyClass = refineClass' staticClass "text-only"

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

illustrationClass :: String
illustrationClass = refineClass' staticClass "illustration"

illustrationWrapperClass :: String
illustrationWrapperClass = refineClass' staticClass "illustrationWrapper"

illustrationBlurClass :: String
illustrationBlurClass = refineClass' staticClass "illustrationBlur"

illustrationContainClass :: String
illustrationContainClass = refineClass' staticClass "illustrationContain"

linkClass :: String
linkClass = refineClass' staticClass "link"

popOnHoverClass :: String
popOnHoverClass = refineClass' staticClass "popOnHover"

baseShadowClass :: String
baseShadowClass = refineClass' staticClass "baseShadow"

titleClass :: String
titleClass = refineClass' staticClass "title"

leadClass :: String
leadClass = refineClass' staticClass "lead"

authorClass :: String
authorClass = refineClass' staticClass "author"

illustrationLoadingClass :: String
illustrationLoadingClass = refineClass' illustrationClass "loading"

authorLoadingClass :: String
authorLoadingClass = refineClass' authorClass "loading"

titleLoadingClass :: String
titleLoadingClass = refineClass' titleClass "loading"

leadLoadingClass :: String
leadLoadingClass = refineClass' leadClass "loading"

illustrationHiddenClass :: String
illustrationHiddenClass = refineClass' illustrationClass "hidden"

illustrationWrapperHiddenClass :: String
illustrationWrapperHiddenClass = refineClass' illustrationWrapperClass "hidden"

style :: InstanceId -> Number -> CSS.CSS
style id scale = class' id .? do
  illustrationClass .* do
    raw "aspect-ratio" $ "16.0 / " <> show (9.0 * (scale + 1.0) / 2.0)
    raw "margin-bottom" $ show (0.7 * scale) <> "rem"

  illustrationWrapperClass .* do
    raw "aspect-ratio" $ "16.0 / " <> show (9.0 * (scale + 1.0) / 2.0)
    raw "margin-bottom" $ show (0.7 * scale) <> "rem"

  authorClass .* do
    raw "font-size" $ show (0.9 * scale) <> "rem"
    raw "letter-spacing" $ show (0.05 * scale) <> "rem"
    raw "margin-bottom" $ show (0.7 * scale) <> "rem"

  titleClass .* do
    raw "font-size" $ show (1.5 * scale) <> "rem"
    raw "line-height" $ show (1.8 * scale) <> "rem"

  leadClass .* do
    raw "font-size" $ show (1.1 * scale) <> "rem"
    raw "line-height" $ show (1.6 * scale) <> "rem"
    raw "margin-top" $ show (0.7 * scale) <> "rem"

  leadLoadingClass .* do
    raw "height" $ show (12.0 * scale) <> "rem"

sheet :: ∀ w i. InstanceId -> Number -> HTML w i
sheet id scale = stylesheet do
  style id scale

staticStyle :: CSS.CSS
staticStyle = do
  staticClass .? do
    backgroundColor $ rgba 255 255 255 0.7
    padding1 1.2
    displayFlex
    flexDirection column
    borderRadiusRem1 1.0
    color $ rgba 51 51 51 1.0
    cursorPointer

    raw "transition" "transform 0.3s ease, box-shadow 0.3s ease"
    overflow hidden
    height (pct 100.0)
    boxSizing borderBox
    borderColor white
    borderStyle solid
    borderWidth1 0.2

    hover :& do
      illustrationClass .* do
        when isPowerful $ transforms [ scale 1.05 1.05 ]

      illustrationContainClass .* do
        when isPowerful $ transforms [ scale 1.05 1.05 ]

  linkClass .? do
    height (pct 100.0)
    raw "text-decoration" "none"
    displayFlex
    flexDirection column
    positionRelative

    popOnHoverClass .& do
      hover :& do
        raw "z-index" "2"

    baseShadowClass .& do
      staticClass .* do
        boxShadow 0.0 2.0 8.0 $ rgba 0 0 0 0.05

    hover :& do
      staticClass .* do
        when isPowerful $ transforms [ translateY (px (-6.0)) ]
        boxShadow 0.0 1.5 2.0 $ rgba 0 0 0 0.066

  illustrationClass .? do
    widthPct100
    height (pct 100.0)
    objectFit cover
    raw "transition" "transform 0.3s ease"

  illustrationWrapperClass .? do
    raw "width" "calc(100% + 2.4rem)"
    positionRelative
    overflow hidden
    raw "border-radius" "1rem 1rem 0 0"
    displayFlex
    padding1 0.0
    raw "margin" "-1.2rem -1.2rem 0 -1.2rem"
    raw "flex" "none"

  illustrationBlurClass .? do
    positionAbsolute
    widthPct100
    height (pct 100.0)
    objectFit cover
    if isPowerful then
      raw "filter" "blur(0.6rem)"
    else do
      raw "filter" "blur(0.3rem)"
      opacity 0.8
    transforms [ scale 1.1 1.1 ]
    raw "z-index" "0"

  illustrationContainClass .? do
    positionRelative
    widthPct100
    height (pct 100.0)
    objectFit contain
    raw "z-index" "1"
    raw "transition" "transform 0.3s ease"

  illustrationLoadingClass .? do
    loading $ defaultLoadingOpt { opacity = 0.12 }

  illustrationHiddenClass .? do
    positionAbsolute
    visibilityHidden
    width (px 0.0)
    height (px 0.0)

  illustrationWrapperHiddenClass .? do
    positionAbsolute
    visibilityHidden
    width (px 0.0)
    height (px 0.0)

  authorClass .? do
    color $ rgba 210 84 49 1.0 -- Rust/Orange author color
    fontWeightBold
    textTransform uppercase
    margin (px 0.0) (px 0.0) (px 0.0) (px 0.0)

  authorLoadingClass .? do
    loading $ defaultLoadingOpt { opacity = 0.12 }
    widthPct 60.0

  titleClass .? do
    secondaryFont
    fontWeightBold
    margin (px 0.0) (px 0.0) (px 0.0) (px 0.0)

  titleLoadingClass .? do
    loading $ defaultLoadingOpt { opacity = 0.12 }
    widthPct 80.0

  leadClass .? do
    color $ rgba 100 100 100 1.0
    margin (px 0.0) (px 0.0) (px 0.0) (px 0.0)
    CSS.minHeight (px 0.0)
    overflow hidden

  leadLoadingClass .? do
    loading $ defaultLoadingOpt { opacity = 0.12 }

articleCard :: ∀ w i. InstanceId -> Number -> Boolean -> Node HTMLdiv w i
articleCard id _ isTextOnly props = div ([ classes [ staticClass, class' id, isTextOnly ? textOnlyClass ↔ "" ] ] <> props)

articleCard_ :: ∀ w i. InstanceId -> Number -> Boolean -> Array (HTML w i) -> HTML w i
articleCard_ id scale isTextOnly = articleCard id scale isTextOnly []

illustration :: ∀ w i. Boolean -> Boolean -> Leaf HTMLimg w i
illustration isLoading isHidden props =
  img ([ classes [ illustrationClass, isLoading ? illustrationLoadingClass ↔ "", isHidden ? illustrationHiddenClass ↔ "" ] ] <> props)

illustration_ :: ∀ w i. Boolean -> Boolean -> HTML w i
illustration_ isLoading isHidden = illustration isLoading isHidden []

illustrationWrapper :: ∀ w i. Boolean -> Node HTMLdiv w i
illustrationWrapper isHidden props =
  div ([ classes [ illustrationWrapperClass, isHidden ? illustrationWrapperHiddenClass ↔ "" ] ] <> props)

illustrationBlur :: ∀ w i. Leaf HTMLimg w i
illustrationBlur props = img ([ classes [ illustrationBlurClass ] ] <> props)

illustrationContain :: ∀ w i. Leaf HTMLimg w i
illustrationContain props = img ([ classes [ illustrationContainClass ] ] <> props)

author :: ∀ w i. Boolean -> Node HTMLh4 w i
author isLoading props = h4 ([ classes [ authorClass, isLoading ? authorLoadingClass ↔ "" ] ] <> props)

author_ :: ∀ w i. Boolean -> Array (HTML w i) -> HTML w i
author_ isLoading = author isLoading []

title :: ∀ w i. Boolean -> Node HTMLh3 w i
title isLoading props = h3 ([ classes [ titleClass, isLoading ? titleLoadingClass ↔ "" ] ] <> props)

title_ :: ∀ w i. Boolean -> Array (HTML w i) -> HTML w i
title_ isLoading = title isLoading []

lead :: ∀ w i. Boolean -> Node HTMLp w i
lead isLoading props = p ([ classes [ leadClass, isLoading ? leadLoadingClass ↔ "" ] ] <> props)

lead_ :: ∀ w i. Boolean -> Array (HTML w i) -> HTML w i
lead_ isLoading = lead isLoading []
