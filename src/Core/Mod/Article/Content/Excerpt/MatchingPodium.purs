module Core.Mod.Article.Content.Excerpt.MatchingPodium (podiumExcerpt) where

import Proem

import Core.Mod.Article.Content.Excerpt.CutStrategy (defaultSuffixValue)
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Content.Excerpt.Excerpt (cleanHtml_, defaultCutStrategy_, healHtml)
import Core.Mod.Html.Html (unsafeFromString)
import Data.Array as Array
import Data.List as List
import Data.CatQueue as CatQueue
import Data.Set as Set
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.String.CodeUnits as StringCU
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.String.Regex as Regex
import Data.String.Regex.Flags (noFlags)
import Util.Html.Clean.Clean (UntagOpt)
import Util.Type.String.String (Token(..), removeAccents, tokenize)
import Util.Type.String.ToString (toString)

maxSearchZoneLength :: Int
maxSearchZoneLength = 10_000

baseWindowSize :: Int
baseWindowSize = defaultCutStrategy_ / 3

normalizeWord :: String -> String
normalizeWord = String.toLower ◁ removeAccents

isClose :: String -> Array String -> Boolean
isClose word normSearchWords =
  let
    normWord = normalizeWord word
    matches s = s /= "" && s == normWord
  in
    Array.any matches normSearchWords

findSpaceBefore :: Int -> String -> Int
findSpaceBefore idx str = go idx
  where
  go i | i <= 0 = 0
  go i = case StringCU.charAt i str of
    Just ' ' -> i + 1
    _ -> go (i - 1)

findSpaceAfter :: Int -> String -> Int
findSpaceAfter idx str = go idx
  where
  len = StringCU.length str
  go i | i >= len = len
  go i = case StringCU.charAt i str of
    Just ' ' -> i
    _ -> go (i + 1)

podiumExcerpt :: Array String -> Content -> UntagOpt -> Maybe String -> Maybe Content
podiumExcerpt searchWords content opts newlineReplacement =
  let
    contentZone = String.take maxSearchZoneLength $ cleanHtml_ opts newlineReplacement (toString content)
    tokens = tokenize contentZone
    normSearchWords = searchWords <#> normalizeWord

    go i currentPos acc = case Array.index tokens i of
      Just token ->
        let
          t = toString token
          len = StringCU.length t
          nextPos = currentPos + len
          isMatch = case token of
            Word _ -> isClose t normSearchWords
            Separator _ -> false
          nextAcc = isMatch ? (CatQueue.snoc acc { pos: currentPos, match: normalizeWord t }) ↔ acc
        in
          go (i + 1) nextPos nextAcc
      Nothing -> acc

    matchesWithPos = Array.fromFoldable $ go 0 0 CatQueue.empty
  in
    if Array.null matchesWithPos then Nothing
    else
      let
        windowSize = baseWindowSize
        contentZoneLength = StringCU.length contentZone

        -- Create ranges [start, end, matches]
        ranges = matchesWithPos <#> \{ pos, match } ->
          { start: findSpaceBefore (pos - windowSize / 2) contentZone
          , end: findSpaceAfter (pos + windowSize / 2) contentZone
          , matches: [ match ]
          }

        -- Merge overlapping ranges
        merge List.Nil = List.Nil
        merge (List.Cons r1 List.Nil) = List.Cons r1 List.Nil
        merge (List.Cons r1 (List.Cons r2 r2s)) =
          let
            mergedEnd = max r1.end r2.end
          -- Prevent data exfiltration: limit maximum length of a merged range 
          -- to avoid an attacker forcing overlaps to read the entire article content.
          in
            if r1.end >= r2.start && (mergedEnd - r1.start) <= (3 * defaultCutStrategy_) then
              merge (List.Cons { start: r1.start, end: mergedEnd, matches: Array.fromFoldable $ Set.fromFoldable (r1.matches <> r2.matches) } r2s)
            else
              List.Cons r1 (merge (List.Cons r2 r2s))

        mergedRanges = Array.fromFoldable $ merge (List.fromFoldable ranges)

        -- Sort by density (number of distinct matches inside the range) descending, then chronologically
        sortedRanges = Array.sortBy
          ( \a b ->
              case compare (Array.length b.matches) (Array.length a.matches) of
                EQ -> compare a.start b.start
                other -> other
          )
          mergedRanges

        -- Take top 3 best ranges, and sort them back chronologically
        topRanges = Array.take 3 sortedRanges
          # Array.sortBy (\a b -> compare a.start b.start)

        -- Expand snippets so their combined length approaches defaultCutStrategy_
        finalRanges =
          let
            count = Array.length topRanges
            targetPerSnippet = defaultCutStrategy_ / count
          in
            topRanges <#> \r ->
              let
                currentLen = r.end - r.start
                missing = max 0 (targetPerSnippet - currentLen)
                halfMissing = missing / 2
              in
                { start: findSpaceBefore (r.start - halfMissing) contentZone
                , end: findSpaceAfter (r.end + halfMissing) contentZone
                }

        snippets = finalRanges <#> \r ->
          StringCU.slice r.start r.end contentZone
            # cleanSnippetBorders
            # healHtml

        prefix = case Array.head finalRanges of
          Just r | r.start > 0 -> "..."
          _ -> ""

        suffix = case Array.last finalRanges of
          Just r | r.end < contentZoneLength -> "..."
          _ -> ""

        finalStr = prefix <> String.joinWith (defaultSuffixValue <> " ") snippets <> suffix
      in
        Just (unsafeFromString finalStr)

cleanSnippetBorders :: String -> String
cleanSnippetBorders str =
  let
    regStart = unsafeRegex "^[^<]*?>" noFlags
    regEnd = unsafeRegex "<[^>]*?$" noFlags
    s1 = Regex.replace' regStart (\_ _ -> "") str
    s2 = Regex.replace' regEnd (\_ _ -> "") s1
  in
    s2
