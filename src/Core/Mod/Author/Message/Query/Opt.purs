module Core.Mod.Author.Message.Query.Opt where

import Proem

import Core.Message.Query.Payload (Need)
import Core.Mod.Image.Message.Query.Opt (ImageOpt, ImageInnerNeeds)

type AuthorOpt = Ɩ

type AuthorInnerNeeds =
  { id :: Need Ɩ Ɩ
  , name :: Need Ɩ Ɩ
  , biography :: Need Ɩ Ɩ
  , portrait :: Need ImageOpt ImageInnerNeeds
  }
