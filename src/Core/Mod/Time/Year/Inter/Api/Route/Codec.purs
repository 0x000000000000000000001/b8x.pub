module Core.Mod.Time.Year.Inter.Api.Route.Codec where

import Proem

import Core.Mod.Time.Year (Year, unsafeFromInt)
import Data.Either (Either(..))
import Data.Enum (fromEnum)
import Data.Int as Int
import Data.Newtype (unwrap)
import Data.String (Pattern(..), Replacement(..))
import Data.String as String
import Routing.Duplex (RouteDuplex', as, segment)

yearCodec :: String -> RouteDuplex' Year
yearCodec suffix =
  as
    (\y -> show (fromEnum $ unwrap y) <> suffix)
    ( \s ->
        Int.fromString (String.replace (Pattern suffix) (Replacement "") s)
          ?? (Right ◁ unsafeFromInt)
          ⇔ (Left "Expected Int")
    )
    segment
