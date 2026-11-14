module Inter.Ui.Store.Store where

import Proem

import Core.Mod.Email.Email (Email)
import Data.Maybe (Maybe(..))
import Inter.Ui.Type.Device (Device(..))

type Membership =
  { adFree :: Boolean
  , hasPaidLastYear :: Boolean
  }

type Me =
  { email :: Email
  , membership :: Membership
  }

type Store =
  { me :: Maybe Me
  , isAdFree :: Boolean
  , device :: Device
  }

initialStore :: Store
initialStore = { me: Nothing, isAdFree: false, device: Desktop }

data Action
  = Login Email Membership
  | Logout
  | SetMembershipStatus Membership
  | SetDevice Device

reduce :: Store -> Action -> Store
reduce store (Login email membership) = store { me = Just { email, membership }, isAdFree = membership.adFree }
reduce store Logout = store { me = Nothing, isAdFree = false }
reduce store (SetMembershipStatus membership) = store { me = (\me -> me { membership = membership }) <$> store.me, isAdFree = membership.adFree }
reduce store (SetDevice device) = store { device = device }
