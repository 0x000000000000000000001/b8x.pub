module Core.Mod.Image.Message.Query.Build where

import Proem

import Core.Message.Query.Handle (build)
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result (Return(..))
import Core.Mod.Image.Image (Image(..))
import Core.Mod.Image.Message.Query.Opt (ImageInnerNeedsRow)
import Core.Mod.Image.Message.Query.Result as Result

buildImage :: ∀ r. String -> Ɩ -> { | ImageInnerNeedsRow r } -> Image -> Result.Image
buildImage urlBase _opt innerNeeds (Image img) =
  { src: case innerNeeds.src of
      NotNeeded -> NotGivenBecauseNotNeeded
      Needed srcOpt _ -> Given $
        let
          path = img.src
        in
          srcOpt.absolute ? (urlBase <> path) ↔ path
  , dimensions: case innerNeeds.dimensions of
      NotNeeded -> NotGivenBecauseNotNeeded
      Needed _dimOpt dimInnerNeeds -> Given
        { width: build dimInnerNeeds.width img.dimensions.width
        , height: build dimInnerNeeds.height img.dimensions.height
        }
  }
