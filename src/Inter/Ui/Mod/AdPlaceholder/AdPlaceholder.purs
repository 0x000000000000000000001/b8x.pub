module Inter.Ui.Mod.AdPlaceholder.AdPlaceholder
  ( component
  ) where

import Proem hiding (div, top, bottom)

import Effect (Effect)
import Halogen as H
import Halogen.Subscription as HS
import Config.PublicConfig (publicConfig)
import Halogen (ComponentHTML, Slot, Component)
import Halogen.HTML as HH
import Halogen.Store.Connect (connect, Connected)
import Halogen.Store.Select (selectEq)
import Inter.Ui.Mod.AdPlaceholder.Style.Style (adPlaceholder_)
import Inter.Ui.Mod.AdPlaceholder.Type (Input, Output, Query)
import Inter.Ui.Mod.Link.Type as Link
import Data.Maybe (Maybe(..))
import Inter.Ui.UiM (UiM)
import Util.Env (Env(..))
import Util.Style.Size as Size
import Util.Type.String.ToString (toString)
import Inter.Ui.Mod.StopPub.StopPub as StopPub
import Inter.Ui.Mod.StopPub.Type as StopPubType
import Type.Proxy (Proxy(..))

foreign import observeAdSizeImpl :: String -> (Number -> Number -> Effect Unit) -> Effect (Effect Unit)

type State =
  { width :: Size.Size
  , height :: Size.Size
  , name :: String
  , stopPubPlacement :: StopPubType.Placement
  , wrapperClass :: Maybe String
  , wrapperStyle :: Maybe String
  , unsubscribe :: Maybe (Effect Unit)
  , loaded :: Boolean
  , adFree :: Boolean
  }

data Action
  = Initialize
  | Receive (Connected Boolean Input)
  | Finalize
  | HandleLinkOutput Link.Output
  | UpdateSize Number Number

type Slots = (stopPub :: Slot StopPubType.Query StopPubType.Output String)

component :: Component Query Input Output UiM
component = connect (selectEq \s -> s.isAdFree) $ H.mkComponent
  { initialState: \({ context, input }) -> { adFree: context, width: input.width, height: input.height, name: input.name, stopPubPlacement: input.stopPubPlacement, wrapperClass: input.wrapperClass, wrapperStyle: input.wrapperStyle, unsubscribe: Nothing, loaded: false }
  , render
  , eval: H.mkEval H.defaultEval
      { handleAction = handleAction
      , initialize = Just Initialize
      , finalize = Just Finalize
      , receive = Just <<< Receive
      }
  }
  where
  render :: State -> ComponentHTML Action Slots UiM
  render st =
    if st.adFree then
      HH.text ""
    else
      let
        dimStr =
          if publicConfig.env == Dev then st.name <> " " <> toString st.width <> " x " <> toString st.height
          else ""
        children = [ HH.slot (Proxy @"stopPub") st.name StopPub.component { target: Nothing, placement: st.stopPubPlacement, name: st.name } HandleLinkOutput ]
        wrapperClass' = case st.wrapperClass of
          Just c -> Just (c <> if st.loaded then " loaded" else "")
          Nothing -> if st.loaded then Just "loaded" else Nothing
      in
        adPlaceholder_ st.name dimStr st.width st.height wrapperClass' st.wrapperStyle st.loaded children

  handleAction :: Action -> H.HalogenM State Action Slots Output UiM Unit
  handleAction = case _ of
    Initialize -> do
      st <- H.get
      unless st.adFree do
        { emitter, listener } <- H.liftEffect HS.create
        unsubscribe <- H.liftEffect $ observeAdSizeImpl st.name \w h -> HS.notify listener (UpdateSize w h)
        H.modify_ \s -> s { unsubscribe = Just unsubscribe }
        void $ H.subscribe emitter
    Receive { context, input } -> do
      st <- H.get
      when (not st.adFree && context) do
        case st.unsubscribe of
          Just unsub -> H.liftEffect unsub
          Nothing -> pure unit
      H.modify_ \s -> s
        { adFree = context
        , width = input.width
        , height = input.height
        , name = input.name
        , stopPubPlacement = input.stopPubPlacement
        , wrapperClass = input.wrapperClass
        , wrapperStyle = input.wrapperStyle
        , unsubscribe = if (not st.adFree && context) then Nothing else s.unsubscribe
        }
    Finalize -> do
      st <- H.get
      case st.unsubscribe of
        Just unsub -> H.liftEffect unsub
        Nothing -> pure unit
    HandleLinkOutput out -> H.raise out
    UpdateSize w h ->
      when
        (w > 10.0 || h > 10.0)
        (H.modify_ \s -> s { width = Size.Px w, height = Size.Px h, loaded = true })
