module Util.Type.String.Test.Test where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT)
import Util.Type.String.Test.CaseTo as CaseTo
import Util.Type.String.Test.CaseToCamel as CaseToCamel
import Util.Type.String.Test.CaseToConstant as CaseToConstant
import Util.Type.String.Test.CaseToHeader as CaseToHeader
import Util.Type.String.Test.CaseToKebab as CaseToKebab
import Util.Type.String.Test.CaseToPascal as CaseToPascal
import Util.Type.String.Test.CaseToSnake as CaseToSnake
import Util.Type.String.Test.CaseToTrain as CaseToTrain
import Util.Type.String.Test.IsCamelCased as IsCamelCased
import Util.Type.String.Test.IsConstantCased as IsConstantCased
import Util.Type.String.Test.IsHeaderCased as IsHeaderCased
import Util.Type.String.Test.IsKebabCased as IsKebabCased
import Util.Type.String.Test.IsPascalCased as IsPascalCased
import Util.Type.String.Test.IsSnakeCased as IsSnakeCased
import Util.Type.String.Test.IsTrainCased as IsTrainCased
import Util.Type.String.Test.PadLeft as PadLeft
import Util.Type.String.Test.PadRight as PadRight
import Util.Type.String.Test.Slugify as Slugify

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  CaseTo.spec
  CaseToPascal.spec
  CaseToCamel.spec
  CaseToSnake.spec
  CaseToKebab.spec
  CaseToConstant.spec
  CaseToTrain.spec
  CaseToHeader.spec
  IsPascalCased.spec
  IsCamelCased.spec
  IsSnakeCased.spec
  IsKebabCased.spec
  IsConstantCased.spec
  IsTrainCased.spec
  IsHeaderCased.spec
  PadLeft.spec
  PadRight.spec
  Slugify.spec
