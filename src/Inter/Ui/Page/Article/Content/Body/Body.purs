module Inter.Ui.Page.Article.Content.Body.Body
  ( body
  ) where


import Proem

import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiArticle)
import Inter.Ui.Type.InstanceId (InstanceId)
import Halogen.HTML (text)
import Halogen.HTML as HH
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..), render)
import Inter.Ui.Page.Article.Content.Body.Style as Style
import Halogen (ComponentHTML)
import Inter.Ui.Page.Article.Type (Action(..), Slots)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.AdPlaceholder.AdPlaceholder as AdPlaceholder
import Inter.Ui.Mod.StopPub.Type (defaultStopPubPlacement)
import Util.Style.Size as Size
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.String.Pattern (Pattern(..))
import Data.Array as Array

processHtml :: String -> Array String
processHtml html =
  let
    pieces = String.split (Pattern "</p>") html
    len = Array.length pieces
    formatPiece idx p =
      if idx == len - 1 then p
      else p <> "</p>"
  in Array.mapWithIndex formatPiece pieces

type Acc =
  { currentChunk :: String
  , currentLen :: Int
  , chunks :: Array String
  }

groupChunks :: Int -> Array String -> Array String
groupChunks threshold pieces =
  let
    initial :: Acc
    initial = { currentChunk: "", currentLen: 0, chunks: [] }

    foldFn :: Acc -> String -> Acc
    foldFn acc p =
      let pLen = String.length p
      in
        if acc.currentLen >= threshold then
          { currentChunk: p
          , currentLen: pLen
          , chunks: Array.snoc acc.chunks acc.currentChunk
          }
        else
          { currentChunk: acc.currentChunk <> p
          , currentLen: acc.currentLen + pLen
          , chunks: acc.chunks
          }

    final = Array.foldl foldFn initial pieces
  in
    let
      finalChunks =
        if String.length final.currentChunk > 0
        then Array.snoc final.chunks final.currentChunk
        else final.chunks
    in
    case Array.unsnoc finalChunks of
      Just { init, last } ->
        if String.length last < 300 then
          case Array.unsnoc init of
            Just { init: init2, last: prev } ->
              Array.snoc init2 (prev <> last)
            Nothing -> finalChunks
        else finalChunks
      Nothing -> finalChunks

body :: ∀ r. { id :: InstanceId | r } -> UiArticle -> ComponentHTML Action Slots UiM
body state articleData =
  case articleData.content of
    Given (SanitizedHtmlString str) ->
      let
        articleLen = String.length str
        threshold = max 800 (articleLen / 11)
        chunks = groupChunks threshold (processHtml str)

        renderChunk idx chunkStr =
          let
            htmlChunk = render (SanitizedHtmlString chunkStr)
            adId = "incontent_" <> show (idx + 1)
            ad = HH.slot (π @"adPlaceholder") adId AdPlaceholder.component { width: Size.Pct 100.0, height: Size.Auto, name: adId, stopPubPlacement: defaultStopPubPlacement, wrapperClass: Just "incontent-ad-wrapper", wrapperStyle: Nothing } HandleAdLinkOutput
          in
            if idx == Array.length chunks - 1 then
              [ htmlChunk ]
            else
              [ htmlChunk, ad ]
      in
        Style.body_ state.id (Array.concat (Array.mapWithIndex renderChunk chunks))
    _ ->
      Style.body_ state.id [ text "" ]
