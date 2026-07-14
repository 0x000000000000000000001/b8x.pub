module Core.Feat.Effect.Sleep
  ( Sleep
  , SLEEP
  , sleep'
  , sleep
  , interpretSleep
  , interpretSleepWithMock
  ) where

import Proem

import Run (EFFECT, AFF, Run, interpret, lift, on, send)
import Type.Proxy (Proxy(..))
import Type.Row (type (+))
import Effect.Aff (delay, Milliseconds(..))
import Data.Int (toNumber)

data Sleep a = Sleep Int (Unit -> a)

derive instance Functor Sleep

type SLEEP fx = (sleep :: Sleep | fx)

sleep' = Proxy :: Proxy "sleep"

sleep :: ∀ fx. Int -> Run (SLEEP + fx) Unit
sleep ms = lift sleep' (Sleep ms identity)

interpretSleep :: ∀ fx a. Run (SLEEP + EFFECT + AFF + fx) a -> Run (EFFECT + AFF + fx) a
interpretSleep = interpret (on sleep' handle send)
  where
  handle :: ∀ fx' a'. Sleep a' -> Run (EFFECT + AFF + fx') a'
  handle (Sleep ms next) = do
    _ <- ʌ' (delay (Milliseconds (toNumber ms)))
    pure (next unit)

interpretSleepWithMock :: ∀ fx a. Run (SLEEP + fx) a -> Run fx a
interpretSleepWithMock = interpret (on sleep' handle send)
  where
  handle :: ∀ fx' a'. Sleep a' -> Run fx' a'
  handle (Sleep _ next) = pure (next unit)
