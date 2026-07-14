module Inter.Ui.Router.PrettyBackground.Firefly.Util where

import Proem

import Effect (Effect)
import Halogen (RefLabel(..))
import Web.HTML (HTMLElement)

fullModuleName :: String
fullModuleName = "Inter.Ui.Router.PrettyBackground.Firefly.Util"

ref :: RefLabel
ref = RefLabel fullModuleName

type SatelliteClass = String
type SatelliteVarXName = String
type SatelliteVarYName = String
type VarXName = String
type VarYName = String

foreign import initFirefly
  :: VarXName
  -> VarYName
  -> SatelliteVarXName
  -> SatelliteVarYName
  -> SatelliteClass
  -> HTMLElement
  -> Effect Cancel

type Cancel = Effect Ɩ
