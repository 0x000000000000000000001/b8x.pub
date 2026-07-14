-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Job where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Job"

type Job_ = "job"

job' = π :: Π Job_
job_ = ᴠ @Job_ :: String
_job = prop job' :: ∀ a r. Lens' { job :: a | r } a
