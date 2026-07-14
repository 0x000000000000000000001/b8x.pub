module Inter.Ui.Router.Type where

import Inter.Ui.Page.Home.Type as PageHome
import Inter.Ui.Page.Article.Type as PageArticle
import Inter.Ui.Page.Donate.Type as PageDonate
import Inter.Ui.Router.PrettyBackground.Firefly.Type as Firefly

import Inter.Ui.Router.Menu.Type.Output as MenuOutput
import Inter.Ui.Router.Menu.Type.Query as MenuQuery
import Inter.Ui.Type.Output (NoOutput)
import Inter.Ui.Type.Slot (NoSlotAddressIndex)
import Inter.Ui.Mod.LoginModal.Type as LoginModal
import Inter.Ui.UiM (UiM)
import Inter.Ui.Capability.Navigate.Navigate (Route)
import Data.Maybe (Maybe)
import Effect.Ref (Ref)
import Halogen (HalogenM, Slot)
import Halogen.Query (ForkId)
import Inter.Ui.Mod.Link.Type as Link
import Inter.Ui.Mod.Toast.Type as ToastType
import Inter.Ui.Type.Toast (Toast)
import Inter.Ui.Type.ModalEvent (ModalEvent)
import Halogen.Subscription as HS

type Slots =
  (home :: Slot PageHome.Query PageHome.Output NoSlotAddressIndex
  , article :: Slot PageArticle.Query PageArticle.Output NoSlotAddressIndex
  , donate :: Slot PageDonate.Query PageDonate.Output NoSlotAddressIndex
  , firefly :: Slot Firefly.Query Firefly.Output NoSlotAddressIndex
  , menu :: Slot MenuQuery.Query MenuOutput.Output NoSlotAddressIndex
  , link :: Slot Link.Query Link.Output NoSlotAddressIndex
  , toast :: Slot ToastType.Query ToastType.Output NoSlotAddressIndex
  , loginModal :: Slot LoginModal.Query NoOutput NoSlotAddressIndex
  )

type Input = { toastEmitter :: HS.Emitter Toast, modalEmitter :: HS.Emitter ModalEvent }

type Output = NoOutput

type State =
  { route :: Maybe Route
  , isUrlLoaded :: Boolean
  , scrollFork :: Maybe (Ref (Maybe ForkId))
  , toastEmitter :: HS.Emitter Toast
  , modalEmitter :: HS.Emitter ModalEvent
  }

data Action
  = Initialize
  | HandleModalEvent ModalEvent
  | HandleDocScroll
  | HandleDocScrollEnd
  | HandleMenuOutput MenuOutput.Output
  | HandleLinkOutput Link.Output
  | HandleArticleOutput PageArticle.Output

data Query a = Navigate Route a

type RouteM a = HalogenM State Action Slots Output UiM a
