module Core.Message.Command.Handle.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

type CommandHandleExceptionRow r =
  ("Core.Message.Command.Handle.Exception" ∷ TooMuchConcurrency
  | r
  )

data TooMuchConcurrency = TooMuchConcurrency

instance Reflect TooMuchConcurrency where
  reflectName = "TooMuchConcurrency"

instance IsLogicException TooMuchConcurrency (CommandHandleExceptionRow r) where
  inj = Variant.inj (π @"Core.Message.Command.Handle.Exception")

instance Translate TooMuchConcurrency where
  translate En _ = "Too many concurrent requests, maximum retries exceeded"
  translate Fr _ = "Trop de requêtes concurrentes, nombre maximum de tentatives dépassé"
