module Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Thumb
  (extractThumb
  , thumb
  ) where

import Proem
import Core.Message.Query.Result (Return(..))
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Data.Array as Array
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Halogen.HTML (HTML)
import Halogen.HTML.Core (AttrName(..))
import Halogen.HTML.Properties (src, attr)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Style as Style
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Style (Format(..))
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Type (Thumb)

thumb :: ∀ w i. Thumb -> HTML w i
thumb { format, src: src' } =
  Style.thumb
    format
    [ src src', attr (AttrName "loading") "lazy" ]

extractThumb :: Article -> Maybe Thumb
extractThumb { illustrations } = case illustrations of
  Given ills -> case Array.head ills of
    Just
      { image:
          Given
            { src: Given src
            , dimensions: Given { width: Given width, height: Given height }
            }
      } ->
      let
        ratio = Int.toNumber width / Int.toNumber height
        format =
          if ratio > 1.05 then Landscape
          else if ratio < 0.95 then Portrait
          else Square
      in
        Just { src, format }
    _ -> Nothing
  _ -> Nothing
