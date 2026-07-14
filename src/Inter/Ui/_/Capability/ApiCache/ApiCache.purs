module Inter.Ui.Capability.ApiCache.ApiCache where

import Proem

import Data.Array as Array
import Data.Maybe (Maybe(..))
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Foreign.Object (Object)
import Foreign.Object as Object
import Run (EFFECT, Run)
import Run as Run
import Type.Row (type (+))
import Foreign (Foreign)

type ApiCacheEntry =
  { etag :: String
  , data :: Foreign
  }

type CacheState =
  { queue :: Array String
  , map :: Object ApiCacheEntry
  }

data ApiCache a
  = GetApiCache String (Maybe ApiCacheEntry -> a)
  | PutApiCache String ApiCacheEntry a

derive instance Functor ApiCache

type API_CACHE fx = (apiCache :: ApiCache | fx)

apiCache' = π :: Π "apiCache"

getApiCache_ :: ∀ fx. String -> Run (API_CACHE + fx) (Maybe ApiCacheEntry)
getApiCache_ key = Run.lift apiCache' (GetApiCache key identity)

putApiCache_ :: ∀ fx. String -> ApiCacheEntry -> Run (API_CACHE + fx) Ɩ
putApiCache_ key entry = Run.lift apiCache' (PutApiCache key entry unit)

interpretApiCache :: ∀ fx. Ref CacheState -> Run (API_CACHE + EFFECT + fx) ~> Run (EFFECT + fx)
interpretApiCache ref = Run.interpret (Run.on apiCache' handle Run.send)
  where
  handle :: ∀ a fx'. ApiCache a -> Run (EFFECT + fx') a
  handle = case _ of
    GetApiCache key next -> do
      state <- ʌ $ Ref.read ref
      η $ next (Object.lookup key state.map)

    PutApiCache key entry next -> do
      ʌ $ Ref.modify_
        ( \state ->
            let
              newMap = Object.insert key entry state.map
              newQueue = Array.snoc (Array.filter (_ /= key) state.queue) key
            in
              if Array.length newQueue > 200 then case Array.uncons newQueue of
                Just { head, tail } -> { queue: tail, map: Object.delete head newMap }
                Nothing -> { queue: newQueue, map: newMap }
              else
                { queue: newQueue, map: newMap }
        )
        ref
      η next
