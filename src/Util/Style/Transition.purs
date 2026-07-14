module Util.Style.Transition
  (Transition(..)
  , all
  , bottom
  , height
  , left
  , margin
  , marginBottom
  , marginLeft
  , marginRight
  , marginTop
  , opacity
  , right
  , top
  , transform
  , transition
  , color
  , transitionHeight
  , transitionNone
  , transitions
  , visibility
  )
  where

import Prelude

import CSS (CSS)
import CSS.Property (class Val, value, (!))
import CSS.Time (Time)
import CSS.Transition (TimingFunction)
import Data.Array (null)
import Util.Style.Base (raw)

data Transition = Transition String Time TimingFunction Time

derive instance Eq Transition
derive instance Ord Transition

instance Val Transition where
  value (Transition p d f e) = value (p ! d ! f ! e)

transitions :: Array Transition -> CSS
transitions ts
  | null ts = transitionNone
  | otherwise = raw "transition" (value ts)

transition :: Transition -> CSS
transition = raw "transition"

transitionNone :: CSS
transitionNone = raw "transition" "none"

transitionHeight :: Time -> TimingFunction -> Time -> CSS
transitionHeight d f e = transition $ Transition "height" d f e

all :: Time -> TimingFunction -> Time -> Transition
all = Transition "all"

height :: Time -> TimingFunction -> Time -> Transition
height = Transition "height"

opacity :: Time -> TimingFunction -> Time -> Transition
opacity = Transition "opacity"

visibility :: Time -> TimingFunction -> Time -> Transition
visibility = Transition "visibility"

transform :: Time -> TimingFunction -> Time -> Transition
transform = Transition "transform"

color :: Time -> TimingFunction -> Time -> Transition
color = Transition "color"

margin :: Time -> TimingFunction -> Time -> Transition
margin = Transition "margin-bottom"

marginBottom :: Time -> TimingFunction -> Time -> Transition
marginBottom = Transition "margin-bottom"

marginTop :: Time -> TimingFunction -> Time -> Transition
marginTop = Transition "margin-top"

marginLeft :: Time -> TimingFunction -> Time -> Transition
marginLeft = Transition "margin-left"

marginRight :: Time -> TimingFunction -> Time -> Transition
marginRight = Transition "margin-right"

left :: Time -> TimingFunction -> Time -> Transition
left = Transition "left"

right :: Time -> TimingFunction -> Time -> Transition
right = Transition "right"

top :: Time -> TimingFunction -> Time -> Transition
top = Transition "top"

bottom :: Time -> TimingFunction -> Time -> Transition
bottom = Transition "bottom"
