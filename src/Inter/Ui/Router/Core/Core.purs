module Inter.Ui.Router.Core.Core where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Data.Maybe (Maybe(..))
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Page.Article.NotFound.NotFound (notFound)
import Inter.Ui.Page.Article.Article (article)
import Inter.Ui.Page.Home.Home (home)
import Inter.Ui.Page.Donate.Donate (donate)
import Inter.Ui.Page.About.About (about)
import Inter.Ui.Page.Legal.Legal (legal)
import Inter.Ui.Page.Newsletter.Newsletter (newsletter)
import Inter.Ui.Router.Core.Style (core_)
import Inter.Ui.Router.Type (Action, Slots)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Type.Device (Device)
core :: Device -> Maybe Route -> ComponentHTML Action Slots UiM
core device = case _ of
  Just route -> core_
    [ case route of
        Home _ -> home device route
        Theme _ _ -> home device route
        Newsletter _ -> newsletter
        Article _ _ -> article device route
        Donate _ -> donate route
        About _ -> about route
        Legal _ -> legal route
        NotFound -> notFound
    ]
  Nothing -> core_ []
