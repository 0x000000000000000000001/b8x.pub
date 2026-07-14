module Core.Feat.Effect.Newsletter
  ( NEWSLETTER
  , Newsletter(..)
  , PrefillArticle
  , newsletter'
  , addSubscriber
  , prefillCampaign
  , interpretNewsletterWithMock
  ) where

import Proem

import Core.Mod.Email.Email (Email)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Data.Maybe (Maybe)
import Run (Run, interpret, lift, on, send)
import Type.Row (type (+))

type PrefillArticle =
  { title :: String
  , lead :: String
  , extract :: String
  , authorName :: String
  , bookNames :: Array String
  , bookAuthors :: Array String
  , bookEditors :: Array String
  , bookYears :: Array String
  , bookPrefix :: String
  , link :: String
  , keywords :: Array String
  , illustrationUrl :: String
  , bookCoverUrl :: String
  }

data Newsletter a
  = AddSubscriber Email (Ɩ -> a)
  | PrefillCampaign NewsletterId String String (Maybe String) (Array PrefillArticle) (Ɩ -> a)

derive instance Functor Newsletter

type NEWSLETTER fx = (newsletter :: Newsletter | fx)

newsletter' = π :: Π "newsletter"

addSubscriber :: ∀ fx. Email -> Run (NEWSLETTER + fx) Ɩ
addSubscriber email = lift newsletter' (AddSubscriber email identity)

prefillCampaign :: ∀ fx. NewsletterId -> String -> String -> Maybe String -> Array PrefillArticle -> Run (NEWSLETTER + fx) Ɩ
prefillCampaign id campaignName subject schedule articles = lift newsletter' (PrefillCampaign id campaignName subject schedule articles identity)

interpretNewsletterWithMock :: ∀ fx a. Run (NEWSLETTER + fx) a -> Run fx a
interpretNewsletterWithMock = interpret (on newsletter' handle send)
  where
  handle :: ∀ fx' a'. Newsletter a' -> Run fx' a'
  handle (AddSubscriber _ next) = η $ next ι
  handle (PrefillCampaign _ _ _ _ _ next) = η $ next ι
