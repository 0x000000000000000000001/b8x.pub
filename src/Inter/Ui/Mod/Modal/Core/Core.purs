module Inter.Ui.Mod.Modal.Core.Core
  (core
  ) where

import Proem

import Halogen (Component, ComponentHTML)
import Halogen.HTML (slot)
import Inter.Ui.Mod.Modal.Core.Close.Close as Close
import Inter.Ui.Mod.Modal.Core.Style.Style (core_)
import Inter.Ui.Mod.Modal.Type (Action(..), Slots, State)
import Inter.Ui.Type.Html (noHtml)
import Inter.Ui.Type.Slot (noSlotAddressIndex)
import Inter.Ui.UiM (UiM)
import Util.Lexicon.Inner (inner')

core
  :: ∀ q i o
   . State i
  -> Component q i o UiM
  -> ComponentHTML (Action i o) (Slots q o) UiM
core { input: { closable, background, widthRem, innerInput } } innerComponent =
  core_ background widthRem
    [ closable
        ? Close.close
        ↔ noHtml
    , slot
        inner'
        noSlotAddressIndex
        innerComponent
        innerInput
        RaiseInnerOutput
    ]
