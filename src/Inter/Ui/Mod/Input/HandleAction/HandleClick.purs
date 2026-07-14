module Inter.Ui.Mod.Input.HandleAction.HandleClick (handleClick) where

import Proem

import Data.Traversable (for_)
import Halogen (getHTMLElementRef)
import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Inter.Ui.Mod.Input.Util (ref)
import Web.HTML.HTMLElement (focus)

handleClick :: InputM Ɩ
handleClick = do
  maybeElement <- getHTMLElementRef ref

  for_ maybeElement \element ->
    ʌ $ focus element
