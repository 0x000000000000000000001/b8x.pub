module Inter.Ui.Mod.ArticleCard.Type
  (Action(..)
  , Input
  , Article
  , Lead
  , Illustration
  , Output(..)
  , ArticleCardM
  , Query
  , Slots
  , State
  ) where

import Halogen (HalogenM, Slot)
import Data.Maybe (Maybe)
import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.Link.Type as Link
import Inter.Ui.Type.State (WithId)
import Core.Mod.Article.Slug.Slug (Slug)
import Util.Html.Clean.Render.Render (SanitizedHtmlString)

type Illustration =
  { src :: String
  , dimensions ::
      Maybe
        { width :: Int
        , height :: Int
        }
  , caption :: Maybe SanitizedHtmlString
  , isFallback :: Boolean
  }

type Lead =
  { lead :: Maybe SanitizedHtmlString
  , isFallback :: Boolean
  }

type Article =
  { slug :: Slug
  , title :: SanitizedHtmlString
  , lead :: Lead
  , bookAuthors :: Array SanitizedHtmlString
  , author :: Maybe { id :: String, name :: SanitizedHtmlString }
  , illustration :: Maybe Illustration
  }

type Input =
  { loading :: Boolean
  , scale :: Number
  , hiddenIllustration :: Boolean
  , maxChars :: Maybe Int
  , article :: Article
  , popOnHover :: Boolean
  , baseShadow :: Boolean
  }

data Output = ClickedLink Link.Output

type Slots =
  (link :: Slot Link.Query Link.Output String
  )

type State = WithId
  (input :: Input
  )

data Action
  = Initialize
  | Receive Input
  | HandleLinkOutput Link.Output

type Query :: ∀ k. k -> Type
type Query = NoQuery

type ArticleCardM a = HalogenM State Action Slots Output UiM a
