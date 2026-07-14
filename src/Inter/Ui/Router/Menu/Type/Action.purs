module Inter.Ui.Router.Menu.Type.Action where

import Inter.Ui.Mod.Input.Type.Output as InputOutput
import Inter.Ui.Mod.Link.Type as Link
import Inter.Ui.Router.Menu.Type.Input (InnerInput)
import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Year (Year)
import Web.UIEvent.MouseEvent (MouseEvent)
import Core.Mod.Newsletter.Id.Id (NewsletterId)

import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Data.Maybe (Maybe)


data Action
  = Open
  | Close
  | HandleSearchInputOutput InputOutput.Output
  | HandleLinkOutput Link.Output
  | FetchResults
  | RemoveAuthorFilter
  | CloseSearch
  | CloseActivePanel
  | OpenSearch
  | OpenNewsletter
  | CloseNewsletter
  | GoToNewsletterMonths Year
  | GoToNewsletterArticles Year Month (Maybe NewsletterId) Boolean
  | OpenMagazine
  | CloseMagazine
  | GoToMagazineCovers Year
  | GoToMagazineArticles Year Slug
  | DoNothing
  | Receive InnerInput
  | Initialize
  | HandleDocMouseMove MouseEvent
  | HandleDocClick MouseEvent
  | Logout
  | OpenLoginModal
