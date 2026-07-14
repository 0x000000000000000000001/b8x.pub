module Inter.Ui.Router.PrettyBackground.Firefly.HandleAction.Initialize (initialize) where

import Proem

import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Halogen (getHTMLElementRef, modify_)
import Inter.Ui.Router.PrettyBackground.Firefly.Style.Style (varXName, varYName)
import Inter.Ui.Router.PrettyBackground.Firefly.Style.Satellite as Satellite
import Inter.Ui.Router.PrettyBackground.Firefly.Type (FireflyM)
import Inter.Ui.Router.PrettyBackground.Firefly.Util (ref, initFirefly)

initialize :: FireflyM Ɩ
initialize = do
  mElement <- getHTMLElementRef ref

  for_ mElement \element -> do
    cleanupEffect <-
      ʌ $ initFirefly
        varXName
        varYName
        Satellite.varXName
        Satellite.varYName
        Satellite.staticClass
        element

    modify_ \st -> st { cleanup = Just cleanupEffect }
