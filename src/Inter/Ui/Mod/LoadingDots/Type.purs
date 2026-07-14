module Inter.Ui.Mod.LoadingDots.Type
  ( Input
  , Color(..)
  ) where

data Color = Black | White

type Input =
  { opacity :: Number
  , color :: Color
  , sizeRem :: Number
  }
