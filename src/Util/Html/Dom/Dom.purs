module Util.Html.Dom.Dom
  (dataAttr
  , dataAttrPrefixed
  , dataAttrQuerySelector
  , getHalfScreenHeight
  , getScreenCenterY
  , getScreenHeight
  , getScrollY
  , isVisible
  , placeElementInScreenYCenter
  , sanitize
  , scroll
  , scrollElementToTopByClass
  , scrollTopAll
  , scrollTo
  , setMetaContent
  , setMetaRobotsDefault
  , setMetaRobotsNoIndex
  , setWindowLocationHref
  ) where

import Proem

import Data.Array (mapMaybe)
import Data.Int (round, toNumber)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Halogen (AttrName(..))
import Halogen.HTML (attr)
import Halogen.HTML.Properties (IProp)
import Type.Prelude (class IsSymbol)
import Web.DOM (Element)
import Web.DOM.Element (fromNode, getBoundingClientRect, setScrollTop)
import Web.DOM.NodeList (toArray)
import Web.DOM.ParentNode (QuerySelector(..), querySelector, querySelectorAll)
import Web.Event.Event (EventType(..))
import Web.HTML (window)
import Web.HTML.HTMLDocument (toParentNode)
import Web.HTML.Window (document, innerHeight, scrollY)
import Web.HTML.Window as Window

foreign import _sanitize :: String -> String

-- | N.b. This is designed for browser usage. 
-- | For Node.js usage, see https://github.com/cure53/DOMPurify?tab=readme-ov-file#running-dompurify-on-the-server
sanitize :: String -> String
sanitize = _sanitize

foreign import _setMetaContent :: String -> String -> Effect Ɩ

setMetaContent :: ∀ m. MonadEffect m => String -> String -> m Ɩ
setMetaContent name content = ʌ $ _setMetaContent name content

foreign import _setMetaRobotsNoIndex :: Effect Ɩ

setMetaRobotsNoIndex :: ∀ m. MonadEffect m => m Ɩ
setMetaRobotsNoIndex = ʌ _setMetaRobotsNoIndex

foreign import _setMetaRobotsDefault :: Effect Ɩ

setMetaRobotsDefault :: ∀ m. MonadEffect m => m Ɩ
setMetaRobotsDefault = ʌ _setMetaRobotsDefault

dataAttrPrefix :: String
dataAttrPrefix = "data-"

dataAttrPrefixed :: ∀ @name. IsSymbol name => String
dataAttrPrefixed = dataAttrPrefix <> ᴠ @name

dataAttr :: ∀ @name r i. IsSymbol name => String -> IProp r i
dataAttr value = attr (AttrName $ dataAttrPrefixed @name) value

dataAttrQuerySelector :: ∀ @name. IsSymbol name => Maybe String -> QuerySelector
dataAttrQuerySelector value =
  QuerySelector
    $ "["
    <> dataAttrPrefixed @name
    <> (value ?? (\v -> "=\"" <> v <> "\"") ⇔ "")
    <> "]"

isVisible :: ∀ m. MonadEffect m => QuerySelector -> m Boolean
isVisible sel = ʌ do
  win <- window
  doc <- document win
  screenHeight <- toNumber <$> innerHeight win

  nodeList <- querySelectorAll sel (toParentNode doc)
  nodes <- toArray nodeList
  let elements = nodes # mapMaybe fromNode

  case elements of
    [] -> η false
    [ element ] -> do
      rect <- getBoundingClientRect element
      η $ rect.top >= 0.0 && rect.bottom <= screenHeight
    _ -> η false

scroll :: EventType
scroll = EventType "scroll"

scrollTo :: ∀ m. MonadEffect m => Int -> Int -> m Ɩ
scrollTo x y = ʌ do
  win <- window
  Window.scroll x y win

getScrollY :: ∀ m. MonadEffect m => m Int
getScrollY = ʌ do
  y <- scrollY =<< window
  η $ round y

scrollElementToTop :: ∀ m. MonadEffect m => String -> m Ɩ
scrollElementToTop selector = ʌ do
  win <- window
  doc <- document win
  mElement <- querySelector (QuerySelector selector) (toParentNode doc)
  case mElement of
    Just element -> setScrollTop 0.0 element
    Nothing -> ηι

foreign import _scrollTopAll :: Element -> Effect Ɩ

scrollTopAll :: ∀ m. MonadEffect m => Element -> m Ɩ
scrollTopAll = ʌ ◁ _scrollTopAll

scrollElementToTopByClass :: ∀ m. MonadEffect m => String -> m Ɩ
scrollElementToTopByClass className = scrollElementToTop ("." <> className)

placeElementInScreenYCenter :: ∀ m. MonadEffect m => Element -> m Ɩ
placeElementInScreenYCenter element = ʌ do
  win <- window
  rect <- getBoundingClientRect element

  screenHeight <- toNumber <$> innerHeight win

  let targetY = round $ rect.top + (rect.height / 2.0) - (screenHeight / 2.0)

  scrollTo 0 targetY

getScreenHeight :: ∀ m. MonadEffect m => m Number
getScreenHeight = ʌ do
  screenHeight <- innerHeight =<< window
  η $ toNumber screenHeight

getHalfScreenHeight :: ∀ m. MonadEffect m => m Number
getHalfScreenHeight = getScreenHeight >>= η ◁ (_ / 2.0)

getScreenCenterY :: ∀ m. MonadEffect m => m Number
getScreenCenterY = do
  scrollY <- toNumber <$> getScrollY
  halfScreenHeight <- getHalfScreenHeight
  η $ scrollY + halfScreenHeight

foreign import _setWindowLocationHref :: String -> Effect Ɩ

setWindowLocationHref :: ∀ m. MonadEffect m => String -> m Ɩ
setWindowLocationHref href = ʌ $ _setWindowLocationHref href