module Inter.Ui.Router.Core.Core where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Data.Maybe (Maybe(..))
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Page.Article.NotFound.NotFound (notFound)
import Inter.Ui.Page.Article.Article (article)
import Inter.Ui.Page.Home.Home (home)
import Inter.Ui.Page.Donate.Donate (donate)
import Inter.Ui.Router.Core.Style (core_)
import Inter.Ui.Router.Type (Action, Slots)
import Inter.Ui.UiM (UiM)

core :: Maybe Route -> ComponentHTML Action Slots UiM
core = case _ of
  Just route -> core_
    [ case route of
        Home _ -> home route
        Theme _ _ -> home route
        Article _ _ -> article route
        Donate _ -> donate route
        NotFound -> notFound
    ]
  Nothing -> core_ []
