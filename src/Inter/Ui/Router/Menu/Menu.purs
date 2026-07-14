module Inter.Ui.Router.Menu.Menu where

import Proem hiding (top, div)

import Data.Maybe (isJust, Maybe(..))
import Halogen (ComponentHTML)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Router.Menu.Component as Component
import Inter.Ui.Router.Type (Action(..))
import Inter.Ui.Router.Type as Router
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Type.ControlledProp (ControlledProp(..))
import Inter.Ui.UiM (UiM)

menu
  :: Router.State
  -> ComponentHTML Router.Action Router.Slots UiM
menu { route, isUrlLoaded } =
  let
    openWith = case route of
      Just (Home { consumeMagicLoginToken: _, menu: { search: { openWith: ow } } }) -> ow
      Just (Theme _ { consumeMagicLoginToken: _, menu: { search: { openWith: ow } } }) -> ow
      Just (Article _ { consumeMagicLoginToken: _, menu: { search: { openWith: ow } } }) -> ow
      Just (Donate { consumeMagicLoginToken: _, menu: { search: { openWith: ow } } }) -> ow
      Just NotFound -> Nothing
      Nothing -> Nothing

    withAuthorFilter = case route of
      Just (Home { consumeMagicLoginToken: _, menu: { search: { withAuthorFilter: wf } } }) -> wf
      Just (Theme _ { consumeMagicLoginToken: _, menu: { search: { withAuthorFilter: wf } } }) -> wf
      Just (Article _ { consumeMagicLoginToken: _, menu: { search: { withAuthorFilter: wf } } }) -> wf
      Just (Donate { consumeMagicLoginToken: _, menu: { search: { withAuthorFilter: wf } } }) -> wf
      Just NotFound -> Nothing
      Nothing -> Nothing

    magazineIssueOpen = case route of
      Just (Home { consumeMagicLoginToken: _, menu: { magazineIssueOpen: m } }) -> m
      Just (Theme _ { consumeMagicLoginToken: _, menu: { magazineIssueOpen: m } }) -> m
      Just (Article _ { consumeMagicLoginToken: _, menu: { magazineIssueOpen: m } }) -> m
      Just (Donate { consumeMagicLoginToken: _, menu: { magazineIssueOpen: m } }) -> m
      Just NotFound -> Nothing
      Nothing -> Nothing
  in
    Component.menu
      { open:
          let
            open = isJust openWith || isJust withAuthorFilter || isJust magazineIssueOpen
          in
            isUrlLoaded
              ? (Uncontrolled open)
              ↔ Controlled open
      , activePanel:
          let
            active =
              if isJust magazineIssueOpen then Magazines
              else if isJust openWith || isJust withAuthorFilter then Search
              else None
          in
            isUrlLoaded
              ? Uncontrolled active
              ↔ Controlled active
      , search:
          let
            rec =
              { query: openWith ??⇒ ""
              , withAuthorFilter
              }
          in
            isUrlLoaded
              ? Uncontrolled rec
              ↔ Controlled rec
      , magazineIssueOpen:
          isUrlLoaded
            ? Uncontrolled magazineIssueOpen
            ↔ Controlled magazineIssueOpen
      }
      HandleMenuOutput
