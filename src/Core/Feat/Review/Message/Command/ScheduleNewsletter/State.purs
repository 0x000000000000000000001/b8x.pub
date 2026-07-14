module Core.Feat.Review.Message.Command.ScheduleNewsletter.State where

import Proem

import Core.Feat.Review.Message.Command.ScheduleNewsletter.Payload as ScheduleNewsletter
import Core.Mod.Newsletter.State as Newsletter

type State = Newsletter.State Ɩ

initialState :: ScheduleNewsletter.Payload -> State
initialState _ = Newsletter.initialState
