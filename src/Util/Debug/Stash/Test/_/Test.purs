module Util.Debug.Stash.Stash.Test.Test where

import Proem

import Effect.Aff (Aff)
import Util.Debug.Stash.Stash.Test.UnsafeClearStash as UnsafeClearStash
import Util.Debug.Stash.Stash.Test.UnsafeDidStash as UnsafeDidStash
import Util.Debug.Stash.Stash.Test.UnsafeDropStash as UnsafeDropStash
import Util.Debug.Stash.Stash.Test.UnsafeGetStashAndDrop as UnsafeGetStashAndDrop
import Util.Debug.Stash.Stash.Test.UnsafeGetStashWithDefault as UnsafeGetStashWithDefault
import Util.Debug.Stash.Stash.Test.UnsafeIncrementStash as UnsafeIncrementStash
import Util.Debug.Stash.Stash.Test.UnsafePushToStash as UnsafePushToStash
import Util.Debug.Stash.Stash.Test.UnsafeStash as UnsafeStash
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  UnsafeStash.spec
  UnsafeGetStashWithDefault.spec
  UnsafeDidStash.spec
  UnsafeDropStash.spec
  UnsafeGetStashAndDrop.spec
  UnsafePushToStash.spec
  UnsafeIncrementStash.spec
  UnsafeClearStash.spec
