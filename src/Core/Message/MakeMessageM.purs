module Core.Message.MakeMessageM
  ( MakeMessageM
  , unMakeMessageM
  , liftMakeMessageM
  , generateUlid
  ) where

import Prelude

import Control.Monad.Error.Class (class MonadThrow)
import Control.Monad.Except (ExceptT, runExceptT)
import Core.Exception.Index (LogicException, exceptLogic', EXCEPT_LOGIC)
import Data.Either (Either(..))
import Effect (Effect)
import Proem (ʌ, η)
import Run (Run, EFFECT)
import Run.Except (throwAt)
import Type.Row (type (+))
import Util.Type.Ulid as Ulid

newtype MakeMessageM a = MakeMessageM (ExceptT LogicException Effect a)

derive newtype instance Functor MakeMessageM
derive newtype instance Apply MakeMessageM
derive newtype instance Applicative MakeMessageM
derive newtype instance Bind MakeMessageM
derive newtype instance Monad MakeMessageM
derive newtype instance MonadThrow LogicException MakeMessageM

unMakeMessageM :: ∀ a. MakeMessageM a -> ExceptT LogicException Effect a
unMakeMessageM (MakeMessageM m) = m

liftMakeMessageM :: ∀ a fx. MakeMessageM a -> Run (EXCEPT_LOGIC + EFFECT + fx) a
liftMakeMessageM m = do
  res <- ʌ $ runExceptT $ unMakeMessageM m
  case res of
    Left e -> throwAt exceptLogic' e
    Right a -> η a

generateUlid :: MakeMessageM String
generateUlid = MakeMessageM $ ʌ $ (Ulid.toString <$> Ulid.generateUlid)
