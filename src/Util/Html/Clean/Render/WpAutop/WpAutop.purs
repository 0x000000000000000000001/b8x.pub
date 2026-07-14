module Util.Html.Clean.Render.WpAutop.WpAutop
  ( wpAutop
  ) where

foreign import _wpAutop :: Boolean -> String -> String

-- | Port of WordPress wpautop functionality using the wpautop npm package.
-- | Converts double newlines to paragraphs and optionally single newlines to <br>.
wpAutop :: Boolean -> String -> String
wpAutop = _wpAutop
