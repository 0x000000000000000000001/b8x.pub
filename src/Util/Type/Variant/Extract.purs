module Util.Type.Variant.Extract where

import Proem

import Data.Variant (Variant)
import Type.Proxy (Proxy(..))
import Prim.RowList as RowList
import Prim.RowList (class RowToList, Nil, RowList)
import Data.Symbol (class IsSymbol, reflectSymbol)
import Data.Maybe (Maybe(..))
import Unsafe.Coerce as Unsafe.Coerce

class ExtractVariantImpl (sym :: Symbol) (ty :: Type) (rl :: RowList Type) (r :: Row Type) | rl -> r where
  extractVariantImpl :: Proxy sym -> Proxy ty -> Proxy rl -> Variant r -> Maybe ty

instance ExtractVariantImpl sym ty Nil r where
  extractVariantImpl _ _ _ _ = Nothing

instance
  (ExtractVariantImpl sym ty tail r
  , IsSymbol sym
  ) => ExtractVariantImpl sym ty (RowList.Cons sym ty tail) r where
  extractVariantImpl pSym _ _ v =
    let
      vRec = Unsafe.Coerce.unsafeCoerce v :: { type :: String, value :: ty }
    in
      if vRec.type == reflectSymbol pSym then
        Just vRec.value
      else
        extractVariantImpl pSym (Proxy @ty) (Proxy @tail) v
else instance
  (ExtractVariantImpl sym ty tail r
  ) => ExtractVariantImpl sym ty (RowList.Cons oSym oTy tail) r where
  extractVariantImpl pSym pTy _ v = extractVariantImpl pSym pTy (Proxy @tail) v

extractVariant
  :: ∀ sym ty r rl
   . RowToList r rl
  => ExtractVariantImpl sym ty rl r
  => Proxy sym
  -> Proxy ty
  -> Variant r
  -> Maybe ty
extractVariant pSym pTy = extractVariantImpl pSym pTy (Proxy @rl)
