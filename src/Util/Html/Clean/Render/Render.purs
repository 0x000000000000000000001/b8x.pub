module Util.Html.Clean.Render.Render
  ( SanitizedHtmlString(..)
  , sanitizeHtml
  , render
  , renderArray
  ) where

import Prelude
import Data.Newtype (class Newtype)
import Halogen.HTML (HTML)
import Html.Renderer.Halogen (render_, renderToArray)

newtype SanitizedHtmlString = SanitizedHtmlString String

derive instance Newtype SanitizedHtmlString _
derive newtype instance Eq SanitizedHtmlString
derive newtype instance Show SanitizedHtmlString

foreign import _sanitizeHtml :: String -> String

sanitizeHtml :: String -> SanitizedHtmlString
sanitizeHtml str = SanitizedHtmlString (_sanitizeHtml str)

render :: ∀ w i. SanitizedHtmlString -> HTML w i
render (SanitizedHtmlString str) = render_ str

renderArray :: ∀ w i. SanitizedHtmlString -> Array (HTML w i)
renderArray (SanitizedHtmlString str) = renderToArray str
