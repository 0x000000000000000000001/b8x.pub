module Core.Feat.Reference.Message.Command.DereferenceBook.State where

import Proem

import Core.Mod.Book.State as Book
import Core.Feat.Reference.Message.Command.DereferenceBook.Payload as DereferenceBook

type State = Book.State Ɩ

initialState :: DereferenceBook.Payload -> State
initialState _ = Book.initialState
