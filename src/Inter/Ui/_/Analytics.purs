module Inter.Ui.Analytics (trackPageView) where

import Proem

import Effect (Effect)

foreign import _trackPageView :: Effect Ɩ

-- | Reports the current page to Google Analytics.
-- |
-- | The tracker deduplicates page views by pathname on the JavaScript side and
-- | debounces them until the page metadata has settled, so it is safe to call
-- | it on every metadata update.
trackPageView :: Effect Ɩ
trackPageView = _trackPageView
