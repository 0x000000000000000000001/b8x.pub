module Util.Debug.Stash.Stash
  (clearStash
  , didStash
  , dropStash
  , getDropStash
  , getStash
  , getStashWithDefault
  , incrementStash
  , pushToStash
  , stash
  , unsafeClearStash
  , unsafeDidStash
  , unsafeDropStash
  , unsafeGetDropStash
  , unsafeGetStash
  , unsafeGetStashWithDefault
  , unsafeIncrementStash
  , unsafePushToStash
  , unsafeStash
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect)
import Effect.Ref (Ref, new, read, write, modify_)
import Effect.Unsafe (unsafePerformEffect)
import Foreign (Foreign)
import Foreign.Object (Object, delete, empty, insert, lookup, member)
import Unsafe.Coerce (unsafeCoerce)

_stash :: Ref (Object Foreign)
_stash = unsafePerformEffect (new empty)

-- | Store a value in the stash with a key
stash :: ∀ m a. MonadEffect m => String -> a -> m Ɩ
stash key value = ʌ $ modify_ (insert key (unsafeCoerce value)) _stash

-- | Store a value in the stash with a key
unsafeStash :: ∀ a. String -> a -> Ɩ
unsafeStash key value = unsafePerformEffect $ stash key value

-- | Get a value from the stash
getStash :: ∀ m a. MonadEffect m => String -> m (Maybe a)
getStash key = do
  current <- ʌ $ read _stash
  η $ unsafeCoerce <$> lookup key current

-- | Get a value from the stash
unsafeGetStash :: ∀ a. String -> Maybe a
unsafeGetStash key = unsafePerformEffect $ getStash key

-- | Get a value from the stash with a default
getStashWithDefault :: ∀ m a. MonadEffect m => String -> a -> m a
getStashWithDefault key default = do
  val <- getStash key
  η $ val ??⇒ default

-- | Get a value from the stash with a default
unsafeGetStashWithDefault :: ∀ a. String -> a -> a
unsafeGetStashWithDefault key default = unsafePerformEffect $ getStashWithDefault key default

-- | Get a value from the stash and drop it afterwards
getDropStash :: ∀ m a. MonadEffect m => String -> m (Maybe a)
getDropStash key = do
  val <- getStash key
  dropStash key
  η val

-- | Get a value from the stash and drop it afterwards
unsafeGetDropStash :: ∀ a. String -> Maybe a
unsafeGetDropStash key = unsafePerformEffect $ getDropStash key

-- | Check if a key exists in the stash
didStash :: ∀ m. MonadEffect m => String -> m Boolean
didStash key = do
  current <- ʌ $ read _stash
  η $ member key current

-- | Check if a key exists in the stash
unsafeDidStash :: String -> Boolean
unsafeDidStash key = unsafePerformEffect $ didStash key

-- | Remove a key from the stash
dropStash :: ∀ m. MonadEffect m => String -> m Ɩ
dropStash key = ʌ $ modify_ (delete key) _stash

-- | Remove a key from the stash
unsafeDropStash :: String -> Ɩ
unsafeDropStash key = unsafePerformEffect $ dropStash key

-- | Push a value to an array in the stash
pushToStash :: ∀ m a. MonadEffect m => String -> a -> m Ɩ
pushToStash key value = ʌ $
  modify_
    (\current ->
        let
          newVal = case lookup key current of
            Nothing -> [ value ]
            Just foreignArr ->
              let
                arr = unsafeCoerce foreignArr :: Array a
              in
                arr <> [ value ]
        in
          insert key (unsafeCoerce newVal) current
    )
    _stash

-- | Push a value to an array in the stash
unsafePushToStash :: ∀ a. String -> a -> Ɩ
unsafePushToStash key value = unsafePerformEffect $ pushToStash key value

-- | Increment a counter in the stash
incrementStash :: ∀ m. MonadEffect m => String -> m Ɩ
incrementStash key = ʌ $
  modify_
    (\current ->
        let
          newVal = case lookup key current of
            Nothing -> 1
            Just foreignN ->
              let
                n = unsafeCoerce foreignN :: Int
              in
                n + 1
        in
          insert key (unsafeCoerce newVal) current
    )
    _stash

-- | Increment a counter in the stash
unsafeIncrementStash :: String -> Ɩ
unsafeIncrementStash key = unsafePerformEffect $ incrementStash key

-- | Clear all entries in the stash
clearStash :: ∀ m. MonadEffect m => m Ɩ
clearStash = ʌ $ write empty _stash

-- | Clear all entries in the stash
unsafeClearStash :: Ɩ -> Ɩ
unsafeClearStash _ = unsafePerformEffect clearStash
