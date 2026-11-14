module Inter.Ui.Router.Menu.Core.Style.Style where

import Proem hiding (div, top)

import CSS (CSS, alignItems, background, borderColor, column, flexDirection, flexStart, hGradient, opacity, pct, rgba, solid, transform)
import CSS.Time (sec)
import CSS.Transform (translateX)
import CSS.Transition (ease)
import DOM.HTML.Indexed (HTMLnav)
import Halogen.HTML (HTML, IProp)
import Halogen.HTML.Elements (keyed)
import Halogen.HTML.Core (ElemName(..))
import Data.Tuple (Tuple)
import Inter.Ui.Router.Menu.Core.Search.QuitButton.Style as QuitButton
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Router.Menu.Type.State.Magazine as Inter.Ui.Router.Menu.Type.State.Magazine
import Inter.Ui.Router.Menu.Type.State.Newsletter as Inter.Ui.Router.Menu.Type.State.Newsletter
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Style.Style (defaultTransitionTime)
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Power (isPowerful)
import Util.Style.Position (positionFixed, left0, top0)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Effect (backdropFilter, borderRightWidth, borderStyle, boxShadow)
import Util.Style.Layout (boxSizingBorderBox, displayFlex, heightAuto, heightPct100, marginBottom, maxWidthPct100, overflowAuto, padding1, visibilityHidden, visibilityVisible, widthPct100, widthRem)
import Util.Style.MediaQuery (onTabletLte)
import Util.Style.Selector ((.?), (.*))
import Util.Style.Transition (transitions)
import Util.Style.Transition as Transition

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.Menu.Core.Style.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

staticClassWhenSearchIsOpen :: String
staticClassWhenSearchIsOpen = refineClass' staticClass "searchIsOpen"

staticClassWhenNewsletterIsOpen :: String
staticClassWhenNewsletterIsOpen = refineClass' staticClass "newsletterIsOpen"

staticClassWhenNewsletterArticlesIsOpen :: String
staticClassWhenNewsletterArticlesIsOpen = refineClass' staticClass "newsletterArticlesIsOpen"

staticClassWhenMagazineIsOpen :: String
staticClassWhenMagazineIsOpen = refineClass' staticClass "magazineIsOpen"

staticClassWhenMagazineCoversIsOpen :: String
staticClassWhenMagazineCoversIsOpen = refineClass' staticClass "magazineCoversIsOpen"

staticClassWhenMagazineArticlesIsOpen :: String
staticClassWhenMagazineArticlesIsOpen = refineClass' staticClass "magazineArticlesIsOpen"

staticClassWhenUnfolded :: String
staticClassWhenUnfolded = refineClass' staticClass "unfolded"

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

staticStyle :: CSS
staticStyle = do
  staticClass .? do
    heightPct100
    displayFlex
    flexDirection column
    alignItems flexStart
    boxSizingBorderBox
    if isPowerful then do
      background $ hGradient (rgba 255 255 255 0.70) (rgba 255 255 255 0.10)
      backdropFilter "blur(4rem)"
    else do
      background $ hGradient (rgba 255 255 255 0.98) (rgba 255 255 255 0.95)
    borderRightWidth 0.05
    borderStyle solid
    borderColor $ rgba 255 235 235 0.7
    boxShadow 2.0 0.0 5.0 $ rgba 0 0 0 0.12
    overflowAuto
    widthRem 34.0
    padding1 2.4
    maxWidthPct100

    transitions
      [ Transition.opacity defaultTransitionTime ease (sec 0.0)
      , Transition.visibility defaultTransitionTime ease (sec 0.0)
      , Transition.transform defaultTransitionTime ease (sec 0.0)
      ]

    positionFixed
    left0
    top0
    transform $ translateX (pct (-100.0))
    opacity 0.0
    visibilityHidden

    onTabletLte do
      widthPct100
      maxWidthPct100

  staticClassWhenUnfolded .? do
    transitions
      [ Transition.opacity defaultTransitionTime ease (sec 0.0)
      , Transition.visibility defaultTransitionTime ease (sec 0.0)
      , Transition.transform defaultTransitionTime ease (sec 0.0)
      ]

    opacity 1.0
    visibilityVisible
    transform $ translateX (pct 0.0)

  staticClassWhenSearchIsOpen .? do
    widthRem 70.0
    onTabletLte do
      widthPct100
      maxWidthPct100

    QuitButton.staticClass .* do
      heightAuto
      visibilityVisible
      marginBottom 1.6

  staticClassWhenNewsletterIsOpen .? do
    widthRem 34.0
    onTabletLte do
      widthPct100
      maxWidthPct100

    QuitButton.staticClass .* do
      heightAuto
      visibilityVisible
      marginBottom 1.6

  staticClassWhenNewsletterArticlesIsOpen .? do
    widthRem 60.0
    onTabletLte do
      widthPct100
      maxWidthPct100

  staticClassWhenMagazineIsOpen .? do
    widthRem 34.0
    onTabletLte do
      widthPct100
      maxWidthPct100
    QuitButton.staticClass .* do
      heightAuto
      visibilityVisible
      marginBottom 1.6

  staticClassWhenMagazineCoversIsOpen .? do
    widthRem 60.0
    onTabletLte do
      widthPct100
      maxWidthPct100

  staticClassWhenMagazineArticlesIsOpen .? do
    widthRem 60.0
    onTabletLte do
      widthPct100
      maxWidthPct100

core :: ∀ w i. State -> Array (IProp HTMLnav i) -> Array (Tuple String (HTML w i)) -> HTML w i
core state@{ id, activePanel, open: menuOpen' } props =
  let
    menuOpen =
      case menuOpen' of
        Controlled o -> o
        Uncontrolled o -> o
    activePanel' =
      case activePanel of
        Controlled a -> a
        Uncontrolled a -> a
    searchOpen = activePanel' == Search
  in
    keyed (ElemName "nav")
      ( [ classes
            $
              [ staticClass
              , class' id
              ]
            <> (searchOpen ? [ staticClassWhenSearchIsOpen ] ↔ [])
            <> (activePanel' == Newsletters ? [ staticClassWhenNewsletterIsOpen ] ↔ [])
            <> (isArticles ? [ staticClassWhenNewsletterArticlesIsOpen ] ↔ [])
            <> (activePanel' == Magazines ? [ staticClassWhenMagazineIsOpen ] ↔ [])
            <> (isCovers ? [ staticClassWhenMagazineCoversIsOpen ] ↔ [])
            <> (isMagazineArticles ? [ staticClassWhenMagazineArticlesIsOpen ] ↔ [])
            <> (menuOpen ? [ staticClassWhenUnfolded ] ↔ [])
        ] <> props
      )
  where
  isArticles = case state.newsletter.page of
    Inter.Ui.Router.Menu.Type.State.Newsletter.Articles _ -> true
    _ -> false

  isCovers = case state.magazine.page of
    Inter.Ui.Router.Menu.Type.State.Magazine.Covers _ -> true
    _ -> false

  isMagazineArticles = case state.magazine.page of
    Inter.Ui.Router.Menu.Type.State.Magazine.Articles _ -> true
    _ -> false
