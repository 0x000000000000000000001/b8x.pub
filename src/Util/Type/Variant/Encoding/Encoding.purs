module Util.Type.Variant.Encoding.Encoding where

import Proem
import Foreign.Index as Foreign.Index

import Foreign (F, Foreign)
import Foreign as Foreign
import Yoga.JSON as JSON

import Yoga.JSON (class ReadForeign, class WriteForeign)

import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap, wrap)
import Data.Symbol (class IsSymbol)
import Data.Variant (Variant, inj)
import Foreign.Object (Object, empty, insert)
import Foreign.Object as Object
import Heterogeneous.Folding (class Folding, class HFoldl, hfoldl)
import Prim.Row as Row
import Prim.RowList (Cons, class RowToList)
import Util.Type.Row.Registry (buildRegistry, buildRegistryFromRowList, class RegistryBuilder)
import Util.Type.String.String (Case(..), caseTo, caseToCamel)
import Util.Type.Type (reflectVariantKeyName)
import Type.Equality (class TypeEquals, to)

type Encoding =
  { tag ::
      { key :: String
      , case :: Case
      }
  , valueKey :: String
  }

defaultEncoding :: Encoding
defaultEncoding =
  { tag:
      { key: ᴠ' @"type" @WeakHeadVariantRow
      , case: Camel
      }
  , valueKey: ᴠ' @"value" @WeakHeadVariantRow
  }

type WeakHeadVariantRow =
  ( type :: String
  , value :: Foreign
  )

type WeakHeadVariant = { | WeakHeadVariantRow }

-- Encode

variantToWeakHead :: ∀ r. HFoldl WriteForeign Ɩ (Variant r) Foreign => Case -> Variant r -> WeakHeadVariant
variantToWeakHead tagCase v =
  let
    value = encodeValueJson v
    tag = caseTo tagCase $ reflectVariantKeyName v
  in
    { type: tag, value }

writeVariantImpl
  :: ∀ r
   . HFoldl WriteForeign Ɩ (Variant r) Foreign
  => Variant r
  -> Foreign
writeVariantImpl = encodeJsonWith defaultEncoding

writeVariantImpl'
  :: ∀ r t v
   . Newtype t v
  => HFoldl WriteForeign Ɩ (Variant r) Foreign
  => TypeEquals v (Variant r)
  => t
  -> Foreign
writeVariantImpl' = writeVariantImpl ◁ (to :: v -> Variant r) ◁ unwrap

encodeJsonWith
  :: ∀ r
   . HFoldl WriteForeign Ɩ (Variant r) Foreign
  => Encoding
  -> Variant r
  -> Foreign
encodeJsonWith { tag: { key: tagKey, case: tagCase }, valueKey } v =
  JSON.writeImpl
    $ insert tagKey (Foreign.unsafeToForeign $ caseTo tagCase $ reflectVariantKeyName v)
    $ insert valueKey (encodeValueJson v)
    $ empty

encodeJsonWith'
  :: ∀ r t v
   . Newtype t v
  => HFoldl WriteForeign Ɩ (Variant r) Foreign
  => TypeEquals v (Variant r)
  => Encoding
  -> t
  -> Foreign
encodeJsonWith' encoding = encodeJsonWith encoding ◁ (to :: v -> Variant r) ◁ unwrap

data WriteForeign = WriteForeign

instance (WriteForeign a) => Folding WriteForeign Ɩ a Foreign where
  folding _ _ item = JSON.writeImpl item

encodeValueJson
  :: ∀ r
   . HFoldl WriteForeign Ɩ (Variant r) Foreign
  => Variant r
  -> Foreign
encodeValueJson v = hfoldl WriteForeign ι v

encodeValueJson'
  :: ∀ r t v
   . Newtype t v
  => HFoldl WriteForeign Ɩ (Variant r) Foreign
  => TypeEquals v (Variant r)
  => t
  -> Foreign
encodeValueJson' = encodeValueJson ◁ (to :: v -> Variant r) ◁ unwrap

-- Decode

readImpl
  :: ∀ @v
   . HasValueDecoders v
  => Foreign
  -> F v
readImpl = decodeJsonWith defaultEncoding

readImpl'
  :: ∀ r t v
   . HasValueDecoders v
  => Newtype t v
  => TypeEquals v (Variant r)
  => Foreign
  -> F t
readImpl' json = wrap <$> decodeJsonWith @v defaultEncoding json

decodeJsonWith
  :: ∀ @v
   . HasValueDecoders v
  => Encoding
  -> Foreign
  -> F v
decodeJsonWith { tag: { key: tagKey }, valueKey } json = do
  obj <- JSON.readImpl json

  tag <- Foreign.Index.readProp tagKey obj >>= JSON.readImpl <#> caseToCamel
  value <- Foreign.Index.readProp valueKey obj

  let decoders = valueDecoders @v

  case Object.lookup tag decoders of
    Nothing -> Foreign.fail $ Foreign.ForeignError ("Unknown variant type: " <> tag)
    Just decode -> decode value

decodeJsonWith'
  :: ∀ r t v
   . HasValueDecoders v
  => Newtype t v
  => TypeEquals v (Variant r)
  => Encoding
  -> Foreign
  -> F t
decodeJsonWith' encoding json = wrap <$> decodeJsonWith @v encoding json

data ValueDecoders (variant :: Type)

type ValueDecoder variant = Foreign -> F variant

class HasValueDecoders variant where
  valueDecoders :: Object (ValueDecoder variant)

instance
  ( RowToList row rl
  , RegistryBuilder (ValueDecoders (Variant row)) rl (ValueDecoder (Variant row))
  ) =>
  HasValueDecoders (Variant row) where
  valueDecoders = buildRegistry @(ValueDecoders (Variant row)) @row @(ValueDecoder (Variant row))

else instance
  ( Newtype t (Variant row)
  , HasValueDecoders (Variant row)
  ) =>
  HasValueDecoders t where
  valueDecoders = valueDecoders @(Variant row) <#> \decode -> decode ▷ map wrap

instance
  ( IsSymbol key
  , ReadForeign value
  , RegistryBuilder (ValueDecoders (Variant row)) tail (ValueDecoder (Variant row))
  , Row.Cons key value variantTail row
  ) =>
  RegistryBuilder (ValueDecoders (Variant row)) (Cons key value tail) (ValueDecoder (Variant row)) where
  buildRegistryFromRowList =
    let
      tailDecoders = buildRegistryFromRowList @(ValueDecoders (Variant row)) @tail
      key = ᴠ @key

      decode json = JSON.readImpl @value json <#> inj (π :: Π key)
    in
      Object.insert key decode tailDecoders
