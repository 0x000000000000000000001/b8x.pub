module Inter.Ui.Page.Article.Books.Style
  (booksContainer_
  , watermark_
  , sectionTitle_
  , booksList_
  , bookCard_
  , bookCover_
  , bookInfo_
  , bookTitle_
  , bookAuthors_
  , bookEditor_
  , bookYear_
  , staticStyle
  ) where

import Proem hiding (div, top)

import CSS (absolute, alignItems, bold, color, column, em, flexDirection, flexStart, fontSize, fontWeight, left, letterSpacing, margin, marginBottom, marginTop, padding, position, relative, rgba, row, textTransform, top, zIndex)
import CSS as CSS
import CSS.Overflow (overflow, hidden)
import CSS.Text.Transform (uppercase)
import Halogen.HTML (HTML, div)
import Inter.Ui.Type.InstanceId (InstanceId)
import Util.Style.Base (raw)
import Util.Style.Classname (classes, generateStaticClass, inferInstanceClass, refineClass')
import Util.Style.Layout (alignItemsCenter, displayFlex, heightPct, heightRem, justifyContentCenter, widthPct)
import Util.Style.Selector ((.?))
import Util.Style.Typography (fontSizePct)

fullModuleName :: String
fullModuleName = "Inter.Ui.Page.Article.Books.Style"

staticClass :: String
staticClass = generateStaticClass fullModuleName

class' :: InstanceId -> String
class' = inferInstanceClass staticClass

c :: String -> String
c name = refineClass' staticClass name

containerC :: String
containerC = c "container"

watermarkC :: String
watermarkC = c "watermark"

sectionTitleC :: String
sectionTitleC = c "sectionTitle"

listC :: String
listC = c "list"

cardC :: String
cardC = c "card"

coverC :: String
coverC = c "cover"

infoC :: String
infoC = c "info"

titleC :: String
titleC = c "title"

authorsC :: String
authorsC = c "authors"

editorC :: String
editorC = c "editor"

yearC :: String
yearC = c "year"

staticStyle :: CSS.CSS
staticStyle = do
  containerC .? do
    position relative
    marginTop (em 4.0)
    padding (em 7.0) (em 0.0) (em 2.0) (em 0.0)
    displayFlex
    flexDirection column
    alignItemsCenter
    overflow hidden

  watermarkC .? do
    position absolute
    top (em 0.0)
    left (em 0.0)
    widthPct 100.0
    heightPct 100.0
    displayFlex
    alignItems flexStart
    justifyContentCenter
    fontSize (em 6.0)
    fontWeight bold
    textTransform uppercase
    letterSpacing (em 0.2)
    color (rgba 0 0 0 0.04)
    zIndex 0
    raw "pointer-events" "none"
    raw "white-space" "nowrap"

  sectionTitleC .? do
    position absolute
    top (em 3.0)
    left (em 0.0)
    widthPct 100.0
    displayFlex
    justifyContentCenter
    fontSize (em 1.5)
    fontWeight bold
    textTransform uppercase
    letterSpacing (em 0.1)
    color (rgba 0 0 0 0.8)
    zIndex 1

  listC .? do
    displayFlex
    flexDirection column
    alignItemsCenter
    widthPct 100.0
    zIndex 1

  cardC .? do
    displayFlex
    flexDirection row
    alignItemsCenter
    justifyContentCenter
    marginTop (em 3.0)
    widthPct 100.0

  coverC .? do
    margin (em 0.0) (em 4.0) (em 0.0) (em 0.0)
    CSS.select (CSS.element "img") $ do
      heightRem 16.0
      raw "width" "auto"

  infoC .? do
    displayFlex
    flexDirection column
    CSS.maxWidth (em 20.0)

  titleC .? do
    fontSizePct 140.0
    fontWeight bold
    marginBottom (em 0.5)

  authorsC .? do
    fontSizePct 120.0
    color (rgba 80 80 80 1.0)
    CSS.select (CSS.fromString ".authorLink") $ do
      raw "cursor" "pointer"
      raw "text-decoration" "underline"

  editorC .? do
    fontSizePct 110.0
    color (rgba 120 120 120 1.0)
    marginTop (em 0.2)

  yearC .? do
    fontSizePct 110.0
    color (rgba 120 120 120 1.0)
    marginTop (em 0.2)

booksContainer_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
booksContainer_ id children = div [ classes [ containerC, class' id ] ] children

watermark_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
watermark_ id children = div [ classes [ watermarkC, class' id ] ] children

sectionTitle_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
sectionTitle_ id children = div [ classes [ sectionTitleC, class' id ] ] children

booksList_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
booksList_ id children = div [ classes [ listC, class' id ] ] children

bookCard_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
bookCard_ id children = div [ classes [ cardC, class' id ] ] children

bookCover_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
bookCover_ id children = div [ classes [ coverC, class' id ] ] children

bookInfo_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
bookInfo_ id children = div [ classes [ infoC, class' id ] ] children

bookTitle_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
bookTitle_ id children = div [ classes [ titleC, class' id ] ] children

bookAuthors_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
bookAuthors_ id children = div [ classes [ authorsC, class' id ] ] children

bookEditor_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
bookEditor_ id children = div [ classes [ editorC, class' id ] ] children

bookYear_ :: ∀ w i. InstanceId -> Array (HTML w i) -> HTML w i
bookYear_ id children = div [ classes [ yearC, class' id ] ] children
