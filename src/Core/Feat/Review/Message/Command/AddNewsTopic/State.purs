module Core.Feat.Review.Message.Command.AddNewsTopic.State where

import Proem

import Core.Feat.Review.Message.Command.AddNewsTopic.Payload as AddNewsTopic
import Core.Mod.NewsTopic.State as NewsTopic


type State = NewsTopic.State Ɩ

initialState :: AddNewsTopic.Payload -> State
initialState _ = NewsTopic.initialState

