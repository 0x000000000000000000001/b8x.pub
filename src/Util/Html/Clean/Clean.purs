module Util.Html.Clean.Clean
  ( clean
  , cleanAttributesInTag
  , cleanAttributesInTags
  , findUnescapedQuote
  , removeAttribute
  , removeComments
  , removeDataAttributes
  , untag
  , untagAll
  , untagExcept
  , untagOnly
  , TagList(..)
  , UntagOpt
  ) where

import Proem

import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), drop, indexOf, split, take, trim)
import Data.String.Regex (Regex, regex)
import Data.String.Regex (replace') as Regex
import Data.String.Regex.Flags (global, noFlags)
import Data.String.Regex.Unsafe (unsafeRegex)
import Util.Html.Encode.Encode (decodeHtmlEntities)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random)
import Yoga.JSON (class ReadForeign, class WriteForeign)

-- | Remove a specific attribute from an HTML tag string.
-- |
-- | Examples:
-- | ```purescript
-- | >>> removeAttribute "style" "<div style=\"color:red;\" class=\"my-class\">"
-- | "<div class=\"my-class\">"
-- | ```
removeAttribute :: String -> String -> String
removeAttribute attrName tag =
  let
    pattern = Pattern (" " <> attrName <> "=\"")
    parts = split pattern tag
  in
    case parts of
      [ before, after ] ->
        findUnescapedQuote after 0
          ??
            ( \endQuote ->
                let
                  afterAttr = drop (endQuote + 1) after
                  cleanAfter = case take 1 afterAttr of
                    " " -> afterAttr
                    _ -> afterAttr
                in
                  before <> cleanAfter
            )
          ⇔ tag
      _ -> tag

-- | Remove all attributes starting with "data-" from an HTML tag string.
-- |
-- | Examples:
-- | ```purescript
-- | >>> removeDataAttributes "<div data-id=\"123\" data-value=\"test\" class=\"my-class\">"
-- | "<div class=\"my-class\">"
-- | ```
removeDataAttributes :: String -> String
removeDataAttributes str =
  indexOf (Pattern " data-") str
    ??
      ( \dataStart ->
          let
            beforeData = take dataStart str
            afterDataStart = drop dataStart str
          in
            indexOf (Pattern "=\"") afterDataStart
              ??
                ( \eqStart ->
                    let
                      valueStart = drop (eqStart + 2) afterDataStart
                    in
                      findUnescapedQuote valueStart 0
                        ??
                          ( \endQuote ->
                              let
                                afterDataAttr = drop (endQuote + 1) valueStart
                              in
                                removeDataAttributes (beforeData <> afterDataAttr)
                          )
                        ⇔ str
                )
              ⇔ str
      )
    ⇔ str

-- | Helper function to find the position of the next unescaped quote in a string.
-- | Returns `Nothing` if no unescaped quote is found.
-- | 
-- | Examples:
-- | ```purescript
-- | >>> findUnescapedQuote "value with \\\"escaped quote\\\" and \" end" 0
-- | Just 36
-- |
-- | >>> findUnescapedQuote "no quotes here" 0
-- | Nothing  
-- | ```
findUnescapedQuote :: String -> Int -> Maybe Int
findUnescapedQuote str pos = do
  quotePos <- indexOf (Pattern "\"") (drop pos str)

  let absolutePos = pos + quotePos

  absolutePos > 0 && take 1 (drop (absolutePos - 1) str) == "\\"
    ? findUnescapedQuote str (absolutePos + 1)
    ↔ Just absolutePos

-- | Cleans specified attributes from a single HTML tag string.
-- | If `dataOnesToo` is true, it also removes all `data-*` attributes.
-- |
-- | Examples:
-- | ```purescript
-- | >>> cleanAttributesInTag "<div style=\"color:red;\" class=\"my-class\" id=\"test\" data-test=\"yes\">" ["style", "class"] true
-- | "<div id=\"test\">"
-- | ```
cleanAttributesInTag :: String -> Array String -> Boolean -> String
cleanAttributesInTag tag attr dataOnesToo =
  Array.foldl (\t a -> removeAttribute a t) tag attr
    # (dataOnesToo ? removeDataAttributes ↔ identity)

tagRegex :: Regex
tagRegex = regex "<[^>]*>" global
  ?! identity
  ⇿ (\_ -> unsafeRegex "^$" noFlags)

-- | Cleans specified attributes from all HTML tags in a string.
-- | If `dataOnesToo` is true, it also removes all `data-*` attributes.
-- | Examples:
-- | ```purescript
-- | >>> cleanAttributesInTags "<div style=\"color:red;\" class=\"my-class\">Content</div><p class=\"paragraph\" id=\"para\">Text</p>" ["style", "class"] false
-- | "<div>Content</div><p id=\"para\">Text</p>"
-- | ```
cleanAttributesInTags :: String -> Array String -> Boolean -> String
cleanAttributesInTags str attr dataOnesToo =
  Regex.replace' tagRegex (\match _ -> cleanAttributesInTag match attr dataOnesToo) str

-- | Removes HTML comments from a string.
-- |
-- | Examples:
-- | ```purescript
-- | >>> removeComments "<div>Hello <strong>World</strong>!</div><!-- This is a comment -->"
-- | "<div>Hello <strong>World</strong>!</div>"
-- |
-- | >>> removeComments "<!-- comment -->Text<!-- another -->"
-- | "Text"
-- | ```
removeComments :: String -> String
removeComments str =
  indexOf (Pattern "<!--") str
    ??
      ( \startIdx ->
          let
            beforeComment = take startIdx str
            afterStartTag = drop (startIdx + 4) str
          in
            indexOf (Pattern "-->") afterStartTag
              ??
                ( \endIdx ->
                    let
                      afterComment = drop (endIdx + 3) afterStartTag
                      result = beforeComment <> afterComment
                    in
                      removeComments result
                )
              ⇔ str
      )
    ⇔ str

data TagList = All | Tags (Array String)

derive instance Eq TagList
derive instance Generic TagList _
instance Show TagList where
  show All = "All"
  show (Tags arr) = "(Tags " <> show arr <> ")"

instance WriteForeign TagList where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign TagList where
  readImpl = genericReadImplWithDefaultOpt

instance Random TagList where
  random = η All

type UntagOpt =
  { whitelist :: TagList
  , blacklistInWhitelist :: TagList
  }

foreign import _untag :: Boolean -> Array String -> Boolean -> Array String -> Boolean -> String -> String

-- | Remove HTML tags from a string based on a whitelist and blacklist.
-- | A tag is kept if it is whitelisted and not blacklisted.
untag :: UntagOpt -> Boolean -> String -> String
untag
  { whitelist
  , blacklistInWhitelist
  }
  replaceWithSpace
  str =
  let
    isWAll = case whitelist of
      All -> true
      Tags _ -> false
    wTags = case whitelist of
      All -> []
      Tags allowed -> allowed

    isBAll = case blacklistInWhitelist of
      All -> true
      Tags _ -> false
    bTags = case blacklistInWhitelist of
      All -> []
      Tags forbidden -> forbidden
  in
    _untag isWAll wTags isBAll bTags replaceWithSpace str

-- | Remove HTML tags from a string, except for the allowed tags.
untagExcept :: Array String -> Boolean -> String -> String
untagExcept allowedTags = untag { whitelist: Tags allowedTags, blacklistInWhitelist: Tags [] }

-- | Remove only the specified HTML tags from a string.
untagOnly :: Array String -> Boolean -> String -> String
untagOnly forbiddenTags = untag { whitelist: All, blacklistInWhitelist: Tags forbiddenTags }

-- | Remove all HTML tags from a string.
untagAll :: Boolean -> String -> String
untagAll = untag { whitelist: Tags [], blacklistInWhitelist: Tags [] }

-- | Clean HTML by removing comments, tags, decoding entities, and trimming.
-- | The `replaceWithSpace` boolean determines if removed tags become spaces.
-- |
-- | Examples:
-- | ```purescript
-- | >>> clean false "<div>Hello <strong>World</strong>!</div><!-- comment -->"
-- | "Hello World!"
-- |
-- | >>> clean true "<div>Hello</div><div>World</div>"
-- | "Hello  World"
-- | ```
clean :: Boolean -> String -> String
clean replaceWithSpace =
  removeComments
    ▷ (untagAll replaceWithSpace)
    ▷ decodeHtmlEntities
    ▷ trim
