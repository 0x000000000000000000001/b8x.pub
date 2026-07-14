module Util.Type.Random where

import Proem

import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Effect.Class (class MonadEffect)
import Effect.Random (randomInt)
import Prim.Row as Row
import Prim.RowList (class RowToList, Cons, Nil, RowList)
import Record.Builder (Builder)
import Record.Builder as Builder

class Random a where
  random :: ∀ m. MonadEffect m => m a

instance Random Ɩ where
  random = η ι

instance Random Int where
  random = ʌ $ randomInt (-1000) 1000

instance Random Number where
  random = ʌ $ toNumber <$> randomInt (-1000) 1000

instance (Random a) => Random (Maybe a) where
  random = do
    i <- ʌ $ randomInt 0 1
    i == 0 ? (η Nothing) ↔ (Just <$> random)

instance Random a => Random (Array a) where
  random = do
    val1 <- random
    val2 <- random
    η [ val1, val2 ]

instance Random String where
  random = do
    i <- ʌ $ randomInt 0 1_000_000
    η $ show i

instance Random Boolean where
  random = do
    i <- ʌ $ randomInt 0 1
    η $ i == 0

instance
  (RowToList r rl
  , RandomFromRowList rl r
  ) =>
  Random (Record r) where
  random = do
    builder <- randomFromRowList @rl
    η $ Builder.build builder {}

class RandomFromRowList (rl :: RowList Type) (r :: Row Type) | rl -> r where
  randomFromRowList :: ∀ m. MonadEffect m => m (Builder {} (Record r))

instance
  (IsSymbol key
  , Random val
  , RandomFromRowList tail rowListTail
  , Row.Cons key val rowListTail r
  , Row.Lacks key rowListTail
  ) =>
  RandomFromRowList (Cons key val tail) r where
  randomFromRowList = do
    val <- random
    tail <- randomFromRowList @tail
    η $ Builder.insert (π :: Π key) val ◁ tail

instance RandomFromRowList Nil () where
  randomFromRowList = η identity
