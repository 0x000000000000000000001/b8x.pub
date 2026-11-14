module Util.Timer where

import Proem

import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, runEffectFn1, runEffectFn2)

foreign import data IntervalId :: Type

foreign import setIntervalImpl :: EffectFn2 Int (Effect Ɩ) IntervalId

foreign import clearIntervalImpl :: EffectFn1 IntervalId Ɩ

_setInterval :: Int -> Effect Ɩ -> Effect IntervalId
_setInterval = runEffectFn2 setIntervalImpl

_clearInterval :: IntervalId -> Effect Ɩ
_clearInterval = runEffectFn1 clearIntervalImpl
