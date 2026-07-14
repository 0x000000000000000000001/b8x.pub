module Inter.Ui.Type.Query where

import Data.Const (Const)
import Proem

type NoQuery :: ∀ k. k -> Type
type NoQuery = Const Void
