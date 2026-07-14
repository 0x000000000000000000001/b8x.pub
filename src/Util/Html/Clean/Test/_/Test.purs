module Util.Html.Clean.Test.Test where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT)
import Util.Html.Clean.Test.CleanAttributesInTag as CleanAttributesInTag
import Util.Html.Clean.Test.CleanAttributesInTags as CleanAttributesInTags
import Util.Html.Clean.Test.FindUnescapedQuote as FindUnescapedQuote
import Util.Html.Clean.Test.RemoveAttribute as RemoveAttribute
import Util.Html.Clean.Test.RemoveComments as RemoveComments
import Util.Html.Clean.Test.RemoveDataAttributes as RemoveDataAttributes
import Util.Html.Clean.Test.Untag as Untag
import Util.Html.Clean.Test.UntagExcept as UntagExcept 
import Util.Html.Clean.Test.UntagOnly as UntagOnly

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  CleanAttributesInTag.spec
  CleanAttributesInTags.spec
  FindUnescapedQuote.spec
  RemoveAttribute.spec
  RemoveComments.spec
  RemoveDataAttributes.spec
  Untag.spec
  UntagExcept.spec
  UntagOnly.spec