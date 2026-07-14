module Core.Feat.Effect.Generate
  ( GENERATE
  , Generate(..)
  , generate'
  , generateUuid
  , generateUlidString
  , generateId
  , now
  , hash
  , randomInt
  , interpretGenerate
  ) where

import Proem

import Core.Mod.Id.Id (Id, unsafeFromString)
import Data.UUID (UUID, genUUID)
import Run (Run, lift, interpret, on, send, AFF, EFFECT)
import Type.Row (type (+))
import Util.Type.Ulid (generateUlid, toString)
import Effect.Now (now) as Now
import Effect.Random (randomInt) as Random
import Data.DateTime.Instant (unInstant)
import Data.Newtype (unwrap)
import Util.Crypto.Hash as Hash

data Generate a
  = GenerateUuid (UUID -> a)
  | GenerateUlidString (String -> a)
  | GenerateNow (Number -> a)
  | GenerateHash String (String -> a)
  | GenerateRandomInt Int Int (Int -> a)

derive instance Functor Generate

type GENERATE fx = (generate :: Generate | fx)

generate' = π :: Π "generate"

generateUuid :: ∀ fx. Run (GENERATE + fx) UUID
generateUuid = lift generate' (GenerateUuid identity)

generateUlidString :: ∀ fx. Run (GENERATE + fx) String
generateUlidString = lift generate' (GenerateUlidString identity)

generateId :: ∀ a fx. Run (GENERATE + fx) (Id a)
generateId = do
  str <- generateUlidString
  η $ unsafeFromString str

now :: ∀ fx. Run (GENERATE + fx) Number
now = lift generate' (GenerateNow identity)

hash :: ∀ fx. String -> Run (GENERATE + fx) String
hash str = lift generate' (GenerateHash str identity)

randomInt :: ∀ fx. Int -> Int -> Run (GENERATE + fx) Int
randomInt min max = lift generate' (GenerateRandomInt min max identity)

interpretGenerate :: ∀ fx a. Run (GENERATE + EFFECT + AFF + fx) a -> Run (EFFECT + AFF + fx) a
interpretGenerate = interpret (on generate' handle send)
  where
  handle :: ∀ fx' a'. Generate a' -> Run (EFFECT + AFF + fx') a'
  handle (GenerateUuid next) = do
    uuid <- ʌ genUUID
    η $ next uuid
  handle (GenerateUlidString next) = do
    ulid <- ʌ generateUlid
    η $ next (toString ulid)
  handle (GenerateNow next) = do
    inst <- ʌ Now.now
    let n = unwrap (unInstant inst)
    η $ next n
  handle (GenerateHash str next) = do
    h <- ʌ' (Hash.xxhash64 str)
    η $ next h
  handle (GenerateRandomInt min max next) = do
    i <- ʌ (Random.randomInt min max)
    η $ next i
