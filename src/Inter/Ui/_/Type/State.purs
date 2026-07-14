module Inter.Ui.Type.State where

import Proem

import Effect.Unsafe (unsafePerformEffect)
import Inter.Ui.Type.InstanceId (InstanceId, generateInstanceId)
import Prim.Row (class Lacks)
import Record (insert)
import Util.Lexicon.Id (id')

type State r = { id :: InstanceId | r }
type WithId r = State r
type BaseState = WithId ()
type NoState = {}

baseState :: BaseState
baseState = { id: unsafePerformEffect generateInstanceId }

noState :: NoState
noState = {}

noState' :: ∀ a. a -> NoState
noState' = κ noState

withId :: ∀ i r. Lacks "id" r => (i -> { | r }) -> (i -> State r)
withId f i = insert id' (unsafePerformEffect generateInstanceId) (f i)
