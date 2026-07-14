module Core.Mod.Article.Illustrations.Inputs.Inputs where

import Core.Mod.Article.Illustrations.Illustrations (Illustration')
import Core.Mod.Url.Url (Url)

type Input = Illustration' Url

type Inputs = Array Input
