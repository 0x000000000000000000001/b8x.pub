module Core.Mod.Article.Content.Excerpt.Excerpt where

import Proem

import Core.Mod.Html.Html (unsafeFromString)
import Core.Mod.Article.Content.Content (Content)
import Data.Foldable (foldl)
import Util.Type.Limit (Limit(..))
import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..), defaultSuffixValue)
import Data.String (trim)
import Data.String as String
import Data.String.Pattern (Pattern(..))
import Data.Tuple (Tuple(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Util.Html.Clean.Clean (UntagOpt, TagList(..), removeComments, untag, untagAll)
import Util.Html.Encode.Encode (decodeHtmlEntities)
import Util.Type.String.ToString (toString)
import Util.Type.String.String (collapseSpaces, collapseSpacesWithAtLeastOneNewline)

findSentenceEnd :: Int -> Int -> String -> Tuple Int Boolean
findSentenceEnd minBound maxBound text =
  let
    searchSpace = String.take maxBound text
    lastDot = String.lastIndexOf (Pattern ". ") searchSpace
    lastBang = String.lastIndexOf (Pattern "! ") searchSpace
    lastQuestion = String.lastIndexOf (Pattern "? ") searchSpace
    -- Consider sentence ends at the very end of the text
    lastDotEnd = String.lastIndexOf (Pattern ".") searchSpace
    lastBangEnd = String.lastIndexOf (Pattern "!") searchSpace
    lastQuestionEnd = String.lastIndexOf (Pattern "?") searchSpace

    maxIdx = foldl (\acc idx -> max acc (fromMaybe (-1) idx)) (-1)
      [ lastDot, lastBang, lastQuestion, lastDotEnd, lastBangEnd, lastQuestionEnd ]
  in
    if maxIdx >= minBound then
      Tuple (maxIdx + 1) false
    else
      Tuple maxBound true

excerpt :: Content -> UntagOpt -> Maybe String -> CutStrategy -> Content
excerpt content opts newlineReplacement strategy =
  unsafeFromString $
    let
      htmlStr = cleanHtml_ opts newlineReplacement (toString content)

      Tuple limit isHardCut = case strategy of
        Strict { limit: l } -> Tuple l true
        OnSentenceEnd { min, max: m } ->
          let
            plainText = untagAll false htmlStr
            decodedPlainText = decodeHtmlEntities plainText
          in
            findSentenceEnd min m decodedPlainText

      suffix = case strategy of
        Strict { suffix: s } -> s
        OnSentenceEnd { suffix: s } -> s

      resolveSuffixValue = case _ of
        Default -> defaultSuffixValue
        Custom s -> s

      suffixStr = case suffix of
        Always v -> resolveSuffixValue v
        OnlyOnHardSentenceCut v -> if isHardCut then resolveSuffixValue v else ""
        None -> ""
    in
      truncateInnerTextThenHealOuterHtml (Finite limit) suffixStr htmlStr

defaultCutStrategy_ :: Int
defaultCutStrategy_ = 300

defaultCutStrategy :: CutStrategy
defaultCutStrategy = Strict { limit: defaultCutStrategy_, suffix: OnlyOnHardSentenceCut Default }

defaultUntagWhitelist :: TagList
defaultUntagWhitelist = Tags [ "em", "u", "strong", "b", "i", "mark", "code", "sup", "sub", "s", "strike", "span", "abbr", "cite", "q", "small", "del", "ins", "time", "kbd", "var", "samp" ]

cleanHtml_ :: UntagOpt -> Maybe String -> String -> String
cleanHtml_ opts newlineReplacement str =
  removeComments str
    # untag opts false
    # decodeHtmlEntities
    # trim
    #
      ( case newlineReplacement of
          Just rep -> collapseSpacesWithAtLeastOneNewline false rep ▷ collapseSpaces false
          Nothing -> collapseSpaces true
      )

cleanHtml :: UntagOpt -> Maybe String -> Content -> Content
cleanHtml opts newlineReplacement content =
  unsafeFromString $
    cleanHtml_
      opts
      newlineReplacement
      (toString content)

healHtml :: String -> String
healHtml htmlStr = truncateInnerTextThenHealOuterHtml Infinite "" htmlStr

foreign import _truncateInnerTextThenHealOuterHtml :: Int -> String -> String -> String

-- Truncate the inner text substance, keeping the tags.
-- It will not cut words in the middle.
truncateInnerTextThenHealOuterHtml :: Limit Int -> String -> String -> String
truncateInnerTextThenHealOuterHtml mLimit suffixStr htmlStr =
  let
    limitInt = case mLimit of
      Infinite -> -1
      Finite l -> l
  in
    _truncateInnerTextThenHealOuterHtml limitInt suffixStr htmlStr
