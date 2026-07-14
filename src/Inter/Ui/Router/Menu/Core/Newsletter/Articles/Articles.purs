module Inter.Ui.Router.Menu.Core.Newsletter.Articles.Articles where

import Proem hiding (div)
import Halogen (ComponentHTML)
import Halogen.HTML (div, text, h3, HTML)
import Halogen.HTML.Properties (class_, classes)
import Halogen.HTML.Core (ClassName(..))
import Inter.Ui.Router.Menu.Core.Newsletter.BackButton.BackButton (backButton)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..), fromMaybe)
import Network.RemoteData (RemoteData(..))
import Core.Mod.Time.Year (Year)
import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Instant (Instant(..))
import Data.DateTime.Instant (toDateTime)
import Data.DateTime (date)
import Data.Date (weekday, day)
import Data.Date.Component (Weekday(..))
import Data.Enum (fromEnum)
import Util.Type.String.ToString (toString)
import Data.Array as Array
import Inter.Ui.Router.Menu.Core.Newsletter.Articles.Item.Item as Item
import Inter.Ui.Router.Menu.Core.Newsletter.Style.Style as Style
import Data.Tuple (Tuple(..))
import Core.Message.Query.Result (Return(..))
import Halogen.HTML.CSS (style)
import Util.Style.Effect (defaultLoading)
import CSS (width, height, pct, rem, marginBottom)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Style as ItemStyle
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Style as ThumbStyle
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Style as CoreStyle
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Style as TitleStyle
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Style as ContentStyle

translateWeekday :: Weekday -> String
translateWeekday = case _ of
  Monday -> "lundi"
  Tuesday -> "mardi"
  Wednesday -> "mercredi"
  Thursday -> "jeudi"
  Friday -> "vendredi"
  Saturday -> "samedi"
  Sunday -> "dimanche"

formatInstant :: Instant -> String
formatInstant (Instant i) =
  let
    d = date (toDateTime i)

    wd = translateWeekday (weekday d)

    dayNum =
      let
        n = fromEnum (day d)
      in
        if n < 10 then "0" <> toString n else toString n
  in
    wd <> " " <> dayNum

groupArticlesByDay :: Boolean -> Year -> Month -> Array _ -> Array (Tuple String (Array _))
groupArticlesByDay fromShortcut targetYear targetMonth items =
  let
    findNewsletters na = 
      if fromShortcut then
        case Array.last (Array.sortBy (\a b -> compare a.scheduledFor.instant b.scheduledFor.instant) na) of
          Just n -> [n]
          Nothing -> []
      else
        Array.filter (\n -> n.scheduledFor.month == targetMonth && n.scheduledFor.year == targetYear) na

    explodedItems =
      Array.concatMap
        ( \a -> case a.newsletters of
            Given na -> case findNewsletters na of
              [] -> [ Tuple Nothing a ]
              ns -> ns <#> \n -> Tuple (Just n) a
            _ -> [ Tuple Nothing a ]
        )
        items

    getGroup (Tuple (Just { scheduledFor: { instant } }) _) = formatInstant instant
    getGroup _ = "Inconnu"

    sortedItems =
      Array.sortBy
        ( \(Tuple mn1 _) (Tuple mn2 _) -> case mn1, mn2 of
            Just n1, Just n2 -> case compare n2.scheduledFor.instant n1.scheduledFor.instant of
              EQ -> compare (n1.index :: Int) (n2.index :: Int)
              other -> other
            Just _, Nothing -> LT
            Nothing, Just _ -> GT
            Nothing, Nothing -> EQ
        )
        explodedItems
  in
    Array.foldl
      ( \acc tuplea@(Tuple _ a) ->
          let
            g = getGroup tuplea
          in
            case Array.last acc of
              Just (Tuple lastGroup arts)
                | lastGroup == g -> fromMaybe acc (Array.updateAt (Array.length acc - 1) (Tuple g (Array.snoc arts a)) acc)
              _ -> Array.snoc acc (Tuple g [ a ])
      )
      []
      sortedItems

skeletonItem :: ∀ w i. State -> HTML w i
skeletonItem state =
  div [ classes [ ClassName ItemStyle.staticClass, ClassName (ItemStyle.class' state.id) ] ]
    [ div
        [ classes [ ClassName ThumbStyle.staticClass, ClassName ThumbStyle.staticClassWhenSquare ]
        , style defaultLoading
        ]
        []
    , CoreStyle.core_
        [ TitleStyle.title
            [ style do
                defaultLoading
                width (pct 40.0)
            ]
            [ text "This is a mock title" ]
        , ContentStyle.content
            [ style do
                defaultLoading
                width (pct 60.0)
                marginBottom (rem 0.3)
            ]
            [ text "Mock authors and books." ]
        , ContentStyle.content
            [ style do
                defaultLoading
                width (pct 100.0)
            ]
            [ text "This is a mock lead that takes one line. More than one line, in fact. Maybe several. More than one. Yes. Repeat after me. More than one. More than one. More than one. More than one. More than one. More than one. More than one. More than one." ]
        ]
    ]

skeletonDay :: ∀ w i. HTML w i
skeletonDay =
  h3
    [ classes [ ClassName "newsletter-day-title" ]
    ]
    [ div
        [ style do
            defaultLoading
            width (rem 10.0)
            height (rem 1.6)
        ]
        []
    ]

articles :: State -> Year -> Month -> Boolean -> Array (ComponentHTML Action Slots UiM)
articles state year month fromShortcut =
  [ if fromShortcut then
      backButton state OpenNewsletter "← Revenir aux années"
    else
      backButton state (GoToNewsletterMonths year) "← Revenir aux mois"
  , Style.items_ state.id itemsHtml
  ]
  where
  itemsHtml = case state.newsletter.articles of
    Success result ->
      let
        groups = groupArticlesByDay fromShortcut year month result.articles
      in
        Array.concatMap
          ( \(Tuple dayName arts) ->
              [ h3 [ classes [ ClassName "newsletter-day-title" ] ] [ text dayName ]
              , div [ class_ (ClassName "newsletter-day-articles") ]
                  (Array.mapWithIndex (\idx a -> Item.item (dayName <> "-" <> toString idx) a) arts)
              ]
          )
          groups
    _ ->
      Array.concatMap
        ( \_ ->
            [ skeletonDay
            , div [ class_ (ClassName "newsletter-day-articles") ]
                [ skeletonItem state
                , skeletonItem state
                , skeletonItem state
                ]
            ]
        )
        [ 1, 2 ]
