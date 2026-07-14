module Inter.Ui.Page.Home.FrontPage.FrontPage where

import Proem hiding (div)

import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiFrontPageResult)
import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Inter.Ui.Page.Home.Type (Action, Slots)
import Inter.Ui.Page.Home.FrontPage.Column.Column (column)
import Inter.Ui.Page.Home.FrontPage.Style.Style (frontPage_)
import Inter.Ui.Type.InstanceId (InstanceId)
import Inter.Ui.Type.Remote (Remote)
import Inter.Ui.UiM (UiM)
import Network.RemoteData (RemoteData(..))

frontPage :: InstanceId -> Remote UiFrontPageResult -> ComponentHTML Action Slots UiM
frontPage _ = case _ of
  Success res ->
    let
      ex = case _ of
        Given article -> Just article
        _ -> Nothing
    in
      frontPage_
        [ column 0 false [ ex res.topLeft, ex res.bottomLeft ]
        , column 1 true [ ex res.center ]
        , column 2 false [ ex res.topRight, ex res.bottomRight ]
        ]
  _ ->
    frontPage_
      [ column 0 false [ Nothing, Nothing ]
      , column 1 true [ Nothing ]
      , column 2 false [ Nothing, Nothing ]
      ]
