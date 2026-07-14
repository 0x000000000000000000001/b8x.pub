module Core.Mod.Article.Content.Excerpt.CutStrategy
  ( CutStrategy(..)
  , Suffix(..)
  , SuffixValue(..)
  , defaultSuffixValue
  ) where

import Proem

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Effect.Random (randomBool)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random, random)
import Yoga.JSON (class ReadForeign, class WriteForeign)

data SuffixValue = Default | Custom String

defaultSuffixValue :: String
defaultSuffixValue = " [...]"

derive instance Eq SuffixValue
derive instance Ord SuffixValue
derive instance Generic SuffixValue _

instance Show SuffixValue where
  show = genericShow

instance WriteForeign SuffixValue where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign SuffixValue where
  readImpl = genericReadImplWithDefaultOpt

data Suffix = Always SuffixValue | OnlyOnHardSentenceCut SuffixValue | None

derive instance Eq Suffix
derive instance Ord Suffix
derive instance Generic Suffix _

instance Show Suffix where
  show = genericShow

instance WriteForeign Suffix where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign Suffix where
  readImpl = genericReadImplWithDefaultOpt

data CutStrategy
  = Strict { limit :: Int, suffix :: Suffix }
  | OnSentenceEnd { min :: Int, max :: Int, suffix :: Suffix }

derive instance Eq CutStrategy
derive instance Ord CutStrategy
derive instance Generic CutStrategy _

instance Show CutStrategy where
  show = genericShow

instance WriteForeign CutStrategy where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign CutStrategy where
  readImpl = genericReadImplWithDefaultOpt

instance Random SuffixValue where
  random = do
    b <- ʌ randomBool
    if b then pure Default else Custom <$> random

instance Random Suffix where
  random = do
    i <- random
    case i `mod` 3 of
      0 -> Always <$> random
      1 -> OnlyOnHardSentenceCut <$> random
      _ -> pure None

instance Random CutStrategy where
  random = do
    b <- ʌ randomBool
    if b then do
      limit <- random
      suffix <- random
      η $ Strict { limit, suffix }
    else do
      min <- random
      max <- random
      suffix <- random
      η $ OnSentenceEnd { min, max, suffix }

