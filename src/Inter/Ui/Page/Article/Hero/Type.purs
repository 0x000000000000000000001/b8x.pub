module Inter.Ui.Page.Article.Hero.Type where

import Proem

import Data.Generic.Rep (class Generic)

data IllustrationLayout = Side | CentralShifted | TextOnly

derive instance Eq IllustrationLayout
derive instance Ord IllustrationLayout
derive instance Generic IllustrationLayout _
