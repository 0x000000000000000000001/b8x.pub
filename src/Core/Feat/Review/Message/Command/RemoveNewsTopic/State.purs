module Core.Feat.Review.Message.Command.RemoveNewsTopic.State where

import Proem

import Core.Feat.Review.Message.Command.RemoveNewsTopic.Payload as RemoveNewsTopic
import Core.Mod.NewsTopic.State as NewsTopic

type State = NewsTopic.State Ɩ

initialState :: RemoveNewsTopic.Payload -> State
initialState _ = NewsTopic.initialState
