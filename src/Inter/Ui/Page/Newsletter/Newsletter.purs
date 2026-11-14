module Inter.Ui.Page.Newsletter.Newsletter (newsletter) where

import Proem

import Halogen (ComponentHTML)
import Halogen.HTML (slot_)
import Inter.Ui.Mod.Newsletter.Component (component)
import Inter.Ui.Page.Newsletter.Style (newsletter_)
import Inter.Ui.Router.Type (Action, Slots)
import Inter.Ui.Type.Slot (noSlotAddressIndex)
import Inter.Ui.UiM (UiM)

newsletter :: ComponentHTML Action Slots UiM
newsletter = newsletter_
  [ slot_ (π @"newsletter") noSlotAddressIndex component ι
  ]
