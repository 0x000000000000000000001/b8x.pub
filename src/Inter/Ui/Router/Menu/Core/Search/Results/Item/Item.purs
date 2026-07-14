module Inter.Ui.Router.Menu.Core.Search.Results.Item.Item where

import Proem

import CSS (flex)
import Core.Message.Query.Result (Return(..))
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Mod.Link.Component (link_)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Core (core)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Style (class', staticClass)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Thumb (thumb)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Type (Thumb)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Type.InstanceId (InstanceId)
import Inter.Ui.UiM (UiM)
import Util.Type.String.ToString (toString)

item :: InstanceId -> Maybe Thumb -> { excerptSearches :: Array String, articleAuthorTokens :: Array String, bookAuthorTokens :: Array String } -> Article -> ComponentHTML Action Slots UiM
item id thumb' normSearches article =
  link_ @"searchResults"
    { route: case article.slug of
        Given s -> Just $ Article s { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }
        _ -> Nothing
    , classes: Just [ staticClass, class' id ]
    , display: flex
    , children:
        (case thumb' of
            Just t -> [ thumb t ]
            Nothing -> []
        ) <> [ core normSearches article ]
    }
    HandleLinkOutput
    ("search:" <>
        (case article.slug of
            Given s -> toString s
            _ -> ""
        )
    )
