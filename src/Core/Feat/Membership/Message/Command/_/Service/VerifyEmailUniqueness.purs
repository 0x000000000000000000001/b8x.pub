module Core.Feat.Membership.Message.Command.Service.VerifyEmailUniqueness where

import Proem hiding ((||))

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.EventStore (EVENT_STORE, loadEvents)
import Core.Event.Filter (Filter(..), by)
import Core.Event.UserEmailChanged.UserEmailChanged (UserEmailChanged)
import Core.Event.UserRegistered.UserRegistered (UserRegistered)
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Filter (filter') as ChangeUserEmail
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Play (play) as ChangeUserEmail
import Core.Feat.Membership.Message.Command.Exception.EmailAlreadyTaken (EmailAlreadyTaken(..))
import Core.Mod.Email.Email (Email)
import Core.Mod.User.Id.Id (UserId)
import Core.Mod.User.State as User
import Data.Array (mapMaybe)
import Data.Foldable (foldl, foldM)
import Data.Maybe (Maybe(..))
import Data.Set (Set)
import Data.Set as Set
import Run (Run)
import Type.Row (type (+))

type IsEmailTaken = Maybe UserId

verifyEmailUniqueness
  :: ∀ fx
   . Email
  -> Run (EVENT_STORE + EXCEPT_LOGIC + fx) Ɩ
verifyEmailUniqueness email = do
  events <- loadEvents $ neededEventsFilter email

  verifyEmailUniqueness_ email events

verifyEmailUniqueness_
  :: ∀ fx
   . Email
  -> Array LoadedEvent
  -> Run (EVENT_STORE + EXCEPT_LOGIC + fx) Ɩ
verifyEmailUniqueness_ email loadedEvents = do
  let aggregateIds = Set.fromFoldable $ mapMaybe (getId ◁ _.event) loadedEvents

  taken <- checkIds aggregateIds

  case taken of
    Just existingUserId -> throw (EmailAlreadyTaken { existingUserId })
    Nothing -> ηι

  where
  getId :: Event -> Maybe UserId
  getId (UserRegistered p) = Just p.id
  getId (UserEmailChanged p) = Just p.user
  getId _ = Nothing

  checkIds :: Set UserId -> Run (EVENT_STORE + EXCEPT_LOGIC + fx) IsEmailTaken
  checkIds = foldM (\acc userId -> case acc of
    Just existing -> η (Just existing)
    Nothing -> checkId userId
  ) Nothing

  checkId :: UserId -> Run (EVENT_STORE + EXCEPT_LOGIC + fx) IsEmailTaken
  checkId id = do
    events <- loadEvents (ChangeUserEmail.filter' id)

    let finalState = foldl ChangeUserEmail.play User.NotRegisteredYet events

    η (if finalState == User.Registered email then Just id else Nothing)

neededEventsFilter :: Email -> Filter
neededEventsFilter email =
  Or (by @UserRegistered @"email" email)
    (by @UserEmailChanged @"email" email)
