module Inter.Ui.Store.Store where

import Proem

import Core.Mod.Email.Email (Email)
import Data.Maybe (Maybe(..))

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
  }

initialStore :: Store
initialStore = { me: Nothing }

data Action
  = Login Email Membership
  | Logout
  | SetMembershipStatus Membership

reduce :: Store -> Action -> Store
reduce store (Login email membership) = store { me = Just { email, membership } }
reduce store Logout = store { me = Nothing }
reduce store (SetMembershipStatus membership) = store { me = (\me -> me { membership = membership }) <$> store.me }
