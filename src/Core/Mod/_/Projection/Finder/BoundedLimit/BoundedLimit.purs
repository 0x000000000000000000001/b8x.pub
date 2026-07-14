module Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit where

import Proem

import Core.Exception.Exception (inj)
import Core.Mod.Int.Exception (IntExceptionRow, NotAnInt(..))
import Core.Mod.Projection.Finder.Filter as Filter
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Effect.Random (randomInt)
import Util.Type.Random (class Random)

newtype BoundedLimit = BoundedLimit Int

derive instance Newtype BoundedLimit _
derive newtype instance Eq BoundedLimit
derive newtype instance Show BoundedLimit
derive newtype instance WriteForeign BoundedLimit
derive newtype instance ReadForeign BoundedLimit

minLimit_ :: Int
minLimit_ = 0

minLimit :: BoundedLimit
minLimit = make minLimit_

maxLimit_ :: Int
maxLimit_ = 1024

maxLimit :: BoundedLimit
maxLimit = make maxLimit_

defaultLimit_ :: Int
defaultLimit_ = Filter.defaultLimit_

defaultLimit :: BoundedLimit
defaultLimit = make defaultLimit_

make :: Int -> BoundedLimit
make limit = BoundedLimit $ max minLimit_ $ min maxLimit_ limit

instance IsRefinedType BoundedLimit (IntExceptionRow ()) where
  makeFromJson _ json = case runExcept (readImpl @Int json) of
    Right i -> Right $ make i
    Left _ -> case runExcept (readImpl @String json) of
      Left _ -> Left $ inj NotAnInt
      Right str -> case Int.fromString str of
        Nothing -> Left $ inj NotAnInt
        Just i -> Right $ make i

instance Random BoundedLimit where
  random = do
    i <- ʌ $ randomInt minLimit_ maxLimit_
    η $ make i

