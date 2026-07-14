module Util.Type.Type
  (class Reflect
  , class ReflectGeneric
  , reflectConstructorName
  , reflectGenericConstructorName
  , reflectName
  , reflectTypeConstructorName
  , reflectTypeName
  , reflectVariantKeyName
  ) where

import Proem

import Data.Generic.Rep (class Generic, Constructor)
import Data.Newtype (class Newtype)
import Data.Show.Generic (class GenericShow, genericShow)
import Data.String (codePointFromChar, drop, takeWhile)
import Data.Symbol (class IsSymbol)
import Data.Variant (Variant)
import Unsafe.Coerce (unsafeCoerce)

class Reflect :: ∀ k. k -> Constraint
class Reflect t where
  reflectName :: String

reflectTypeName :: ∀ t. Reflect t => t -> String
reflectTypeName _ = reflectName @t

reflectTypeConstructorName :: ∀ a rep. Generic a rep => GenericShow rep => a -> String
reflectTypeConstructorName a =
  let
    shown = genericShow a
  in
    drop 1 $ takeWhile (\c -> c /= codePointFromChar ' ') shown

reflectConstructorName :: ∀ @a rep inner. Newtype a inner => Generic a rep => ReflectGeneric rep => String
reflectConstructorName = reflectGenericConstructorName (π @rep)

class ReflectGeneric :: ∀ k. k -> Constraint
class ReflectGeneric rep where
  reflectGenericConstructorName :: Π rep -> String

instance IsSymbol name => ReflectGeneric (Constructor name args) where
  reflectGenericConstructorName _ = ᴠ @name

reflectVariantKeyName :: ∀ r. Variant r -> String
reflectVariantKeyName v = (unsafeCoerce v :: { type :: String }).type
