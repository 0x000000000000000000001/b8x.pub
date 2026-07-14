module Inter.Cli.CodeGen.CodeGenM
  (CODE_GEN
  , CodeGenM
  , runCodeGenM
  ) where

import Proem

import Inter.Cli.Util.Aff (runCliAff)
import Effect (Effect)
import Run (Run, AFF, EFFECT, runBaseAff')
import Type.Row (type (+))

type CODE_GEN =
  AFF
    + EFFECT
    + ()

type CodeGenM = Run CODE_GEN

runCodeGenM :: CodeGenM Ɩ -> Effect Ɩ
runCodeGenM ma = runCliAff do
  ma
    # runBaseAff'
