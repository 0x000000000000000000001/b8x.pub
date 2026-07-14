module Core.Mod.Image.Message.Query.Opt where

import Proem

import Core.Message.Query.Payload (Need)

type ImageOpt = Ɩ

type ImageInnerNeedsRow r =
  ( src :: Need SrcOpt SrcInnerNeeds
  , dimensions :: Need DimensionsOpt DimensionsInnerNeeds
  | r
  )

type ImageInnerNeeds = { | ImageInnerNeedsRow () }

type DimensionsOpt = Ɩ

type DimensionsInnerNeeds =
  { width :: Need Ɩ Ɩ
  , height :: Need Ɩ Ɩ
  }

type SrcOpt =
  { absolute :: Boolean
  }

type SrcInnerNeeds = Ɩ
