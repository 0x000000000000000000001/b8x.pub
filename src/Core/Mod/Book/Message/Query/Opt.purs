module Core.Mod.Book.Message.Query.Opt where

import Proem

import Core.Message.Query.Payload (Fold, Need)
import Core.Mod.Book.Cover.Message.Query.Opt (CoverOpt, CoverInnerNeeds)

type BookOpt = Fold BookOpt_

type BookOpt_ = Ɩ

type BookInnerNeeds = Fold BookInnerNeeds_

type BookInnerNeeds_ =
  { id :: Need Ɩ Ɩ
  , name :: Need Ɩ Ɩ
  , year :: Need Ɩ Ɩ
  , cover :: Need CoverOpt CoverInnerNeeds
  , authors :: Need Ɩ Ɩ
  , editor :: Need Ɩ Ɩ
  }
