module Util.Type.Quote where

import Prelude
import Effect (Effect)

-- | We emulate the Quote monad from Haskell.
-- | This is made to talk to the compiler.
-- | This is not something useful for the runtime.
-- | Whatever the monad: we just wanna bind stuff 
-- | (i.e., to group constraints in the same "do" block).
type Q
  = Effect

-- | Constraint is a reserved keyword.
type ConstraintPredicate
  = Unit

constraintPredicate :: ConstraintPredicate
constraintPredicate = unit
