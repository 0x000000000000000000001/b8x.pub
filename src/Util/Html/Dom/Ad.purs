module Util.Html.Dom.Ad
  ( ensureAds
  , setAdFree
  , getAdFree
  ) where

import Proem

import Effect (Effect)
import Effect.Class (class MonadEffect)

foreign import _ensureAds :: Effect Ɩ

-- | Refreshes the ad slots by notifying the AnyManager SDK of a page change (SPA navigation).
ensureAds :: ∀ m. MonadEffect m => m Ɩ
ensureAds = ʌ _ensureAds

foreign import _setAdFree :: Boolean -> Effect Ɩ

setAdFree :: ∀ m. MonadEffect m => Boolean -> m Ɩ
setAdFree = ʌ ◁ _setAdFree

foreign import _getAdFree :: Effect Boolean

getAdFree :: ∀ m. MonadEffect m => m Boolean
getAdFree = ʌ _getAdFree
