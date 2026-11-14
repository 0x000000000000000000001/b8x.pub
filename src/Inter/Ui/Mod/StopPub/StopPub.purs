module Inter.Ui.Mod.StopPub.StopPub
  ( component
  ) where

import Proem hiding (div, top, bottom)

import Effect (Effect)
import Halogen as H
import Halogen.Subscription as HS
import Halogen.HTML as HH
import Halogen.HTML.CSS (style)
import Halogen.HTML.Properties as HP
import CSS (absolute, bottom, left, position, right, top, zIndex, fixed, width, height)
import CSS as CSS
import CSS.Display (inlineBlock)
import Data.Maybe (Maybe(..), isJust)
import Halogen (ComponentHTML, Slot, Component)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Mod.Link.Component (link_)
import Inter.Ui.Mod.Link.Type as Link
import Inter.Ui.Mod.StopPub.Type (Input, Output, Query, Corner(..), Placement)
import Inter.Ui.UiM (UiM)
import Util.Style.Layout (displayNone)
import Util.Style.Size as Size
import Util.Type.String.ToString (toString)
import Inter.Ui.Mod.Modal.Style.Style as Modal
import Inter.Ui.Router.Menu.Style.Style as Menu
import Inter.Ui.Mod.StopPub.Style as Style

foreign import observeTargetImpl :: String -> (Number -> Number -> Number -> Number -> Boolean -> Effect Unit) -> Effect (Effect Unit)

type State =
  { target :: Maybe String
  , placement :: Placement
  , name :: String
  , unsubscribe :: Maybe (Effect Unit)
  , targetVisible :: Boolean
  , targetCoords :: { top :: Number, left :: Number, width :: Number, height :: Number }
  }

data Action
  = Initialize
  | Finalize
  | HandleLinkOutput Link.Output
  | UpdateTarget { top :: Number, left :: Number, width :: Number, height :: Number, visible :: Boolean }

type Slots = (linkAd :: Slot Link.Query Link.Output String)

component :: Component Query Input Output UiM
component = H.mkComponent
  { initialState: \input -> 
      { target: input.target
      , placement: input.placement
      , name: input.name
      , unsubscribe: Nothing
      , targetVisible: false
      , targetCoords: { top: 0.0, left: 0.0, width: 0.0, height: 0.0 }
      }
  , render
  , eval: H.mkEval H.defaultEval
      { handleAction = handleAction
      , initialize = Just Initialize
      , finalize = Just Finalize
      }
  }
  where
  render :: State -> ComponentHTML Action Slots UiM
  render st =
    let 
      p = st.placement
      isFixed = isJust st.target
      isVisible = if isFixed then st.targetVisible else true
      
      innerButton =
        HH.div
          [ style do
              if not isVisible then displayNone
              else do
                position absolute
                zIndex ((min Menu.zIndex Modal.zIndex) - 1)
                CSS.key (CSS.fromString "pointer-events") "auto"
                case p.corner of
                  TopLeft -> do
                    Size.applyToSize top (Size.Px 0.0)
                    Size.applyToSize left (Size.Px 0.0)
                  TopRight -> do
                    Size.applyToSize top (Size.Px 0.0)
                    Size.applyToSize right (Size.Px 0.0)
                  BottomLeft -> do
                    Size.applyToSize bottom (Size.Px 0.0)
                    Size.applyToSize left (Size.Px 0.0)
                  BottomRight -> do
                    Size.applyToSize bottom (Size.Px 0.0)
                    Size.applyToSize right (Size.Px 0.0)
                
                CSS.key (CSS.fromString "--stop-pub-dt-x") (toString p.desktopTranslate.x)
                CSS.key (CSS.fromString "--stop-pub-dt-y") (toString p.desktopTranslate.y)
                CSS.key (CSS.fromString "--stop-pub-mb-x") (toString p.mobileTranslate.x)
                CSS.key (CSS.fromString "--stop-pub-mb-y") (toString p.mobileTranslate.y)
                CSS.key (CSS.fromString "transition") "all 0s"
          , HP.class_ (HH.ClassName Style.wrapperClass)
          ]
          [ link_ @"linkAd"
              { route: Just (Donate { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } })
              , classes: Nothing
              , display: inlineBlock
              , children:
                  [ HH.img
                      [ HP.src "/asset/image/stoppub.png"
                      , HP.alt "Stop Pub"
                      , HP.class_ (HH.ClassName Style.imageClass)
                      ]
                  ]
              }
              HandleLinkOutput
              st.name
          ]
    in
      if isFixed then
        HH.div
          [ style do
              if not isVisible then displayNone
              else do
                position fixed
                zIndex ((min Menu.zIndex Modal.zIndex) - 1)
                CSS.key (CSS.fromString "pointer-events") "none"
                CSS.key (CSS.fromString "transition") "all 0s"
                Size.applyToSize top (Size.Px st.targetCoords.top)
                Size.applyToSize left (Size.Px st.targetCoords.left)
                Size.applyToSize width (Size.Px st.targetCoords.width)
                Size.applyToSize height (Size.Px st.targetCoords.height)
          , HP.class_ (HH.ClassName Style.wrapperClass)
          ]
          [ innerButton ]
      else
        innerButton

  handleAction :: Action -> H.HalogenM State Action Slots Output UiM Unit
  handleAction = case _ of
    Initialize -> do
      st <- H.get
      case st.target of
        Just selector -> do
          { emitter, listener } <- H.liftEffect HS.create
          unsubscribe <- H.liftEffect $ observeTargetImpl selector \t l w h v -> 
            HS.notify listener (UpdateTarget { top: t, left: l, width: w, height: h, visible: v })
          H.modify_ \s -> s { unsubscribe = Just unsubscribe }
          void $ H.subscribe emitter
        Nothing -> pure unit
    Finalize -> do
      st <- H.get
      case st.unsubscribe of
        Just unsub -> H.liftEffect unsub
        Nothing -> pure unit
    HandleLinkOutput out -> H.raise out
    UpdateTarget coords -> do
      H.modify_ \s -> s { targetCoords = { top: coords.top, left: coords.left, width: coords.width, height: coords.height }, targetVisible = coords.visible }
