module Util.Html.Encode.Encode
  (decodeHtmlEntities
  , encodeHtmlEntities
  )
  where

-- | Decode HTML entities.
-- | 
-- | Examples:
-- | ```purescript
-- | >>> decodeHtmlEntities "&lt;div&gt;Hello &amp; world&lt;/div&gt;"
-- | "<div>Hello & world</div>"
-- | 
-- | >>> decodeHtmlEntities "&quot;Hello&quot; &amp; &#39;World&#39;"  
-- | "\"Hello\" & 'World'"
-- | ```
foreign import _decodeHtmlEntities :: String -> String

decodeHtmlEntities :: String -> String
decodeHtmlEntities = _decodeHtmlEntities

-- | Encode HTML entities.
-- | 
-- | Examples:
-- | ```purescript
-- | >>> encodeHtmlEntities "<div>Hello & world</div>"
-- | "&lt;div&gt;Hello &amp; world&lt;/div&gt;"
-- | ```
foreign import _encodeHtmlEntities :: String -> String

encodeHtmlEntities :: String -> String
encodeHtmlEntities = _encodeHtmlEntities


