module Util.Log
  (Level(..)
  , unsafeDebug
  , unsafeDebugShow
  , unsafeError
  , unsafeErrorShow
  , unsafeInfo
  , unsafeInfoShow
  , unsafeLog
  , unsafeLogShow
  , unsafeWarn
  , unsafeWarnShow
  ) where

import Proem

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Effect.Console as Console
import Effect.Unsafe (unsafePerformEffect)

data Level = Debug | Info | Warn | Error

derive instance Generic Level _

instance Show Level where
  show = genericShow

unsafeLog :: ∀ a. Show a => Level -> a -> Ɩ
unsafeLog level input = unsafePerformEffect $ do
  let message_ = show level <> ": " <> show input
  case level of
    Debug -> Console.debug message_
    Info -> Console.info message_
    Warn -> Console.warn message_
    Error -> Console.error message_

unsafeLogShow :: ∀ a. Show a => Level -> a -> Ɩ
unsafeLogShow level input = unsafeLog level $ show input

unsafeDebug :: ∀ a. Show a => a -> Ɩ
unsafeDebug = unsafeLog Debug

unsafeDebugShow :: ∀ a. Show a => a -> Ɩ
unsafeDebugShow = unsafeDebug ◁ show

unsafeInfo :: ∀ a. Show a => a -> Ɩ
unsafeInfo = unsafeLog Info

unsafeInfoShow :: ∀ a. Show a => a -> Ɩ
unsafeInfoShow = unsafeInfo ◁ show

unsafeWarn :: ∀ a. Show a => a -> Ɩ
unsafeWarn = unsafeLog Warn

unsafeWarnShow :: ∀ a. Show a => a -> Ɩ
unsafeWarnShow = unsafeWarn ◁ show

unsafeError :: ∀ a. Show a => a -> Ɩ
unsafeError = unsafeLog Error

unsafeErrorShow :: ∀ a. Show a => a -> Ɩ
unsafeErrorShow = unsafeError ◁ show