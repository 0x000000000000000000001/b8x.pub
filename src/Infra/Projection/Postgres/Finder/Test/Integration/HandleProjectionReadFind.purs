module Infra.Projection.Postgres.Finder.Test.Integration.HandleProjectionReadFind where

import Proem

import Core.Feat.Reference.Message.Command.ReferenceAuthor.Command (ReferenceAuthor(..))
import Core.Feat.Reference.Message.Command.ReferenceBook.Command (ReferenceBook(..))
import Core.Feat.Reference.Message.Command.ReferenceEditor.Command (ReferenceEditor(..))
import Core.Feat.Reference.Message.Query.SearchBooks.Projection.Projection (Book(..), BookFilter(..), findBooks)
import Core.Feat.Review.Message.Command.WriteArticle.Command (WriteArticle(..))
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection (ArticleFilter(..), findArticles)
import Core.Message.Command.Handle.Handle (handleCommand_)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Year.Year (Year(..))
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Html.Html (unsafeFromString)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Filter (EqualsUpToNormalization(..), Limit(..), StrictlyEquals(..), by, noLimit)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, findMany_)
import Core.Mod.Projection.Finder.Sort (SortDirection(..), noSort)
import Core.Mod.Projection.Finder.Sort as Sort
import Core.Mod.Projection.Projection (noAfter)
import Core.Mod.Time.Year as Time
import Data.Array (length, (!!))
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect.Aff (Aff)
import Infra.Projection.Postgres.Finder.Test.Integration.TestM (TestM)
import Test.Spec (SpecT, before, it, describe)
import Test.Util.Assert ((=?))
import Util.Type.Random (random)
import Util.Type.String.ToString (toString)

fullModuleName :: String
fullModuleName = "Infra.Projection.Postgres.Finder.Test.Integration.HandleProjectionReadFind"

spec :: SpecT TestM Ɩ Aff Ɩ
spec = before setupEntities $ describe fullModuleName do
  it "can find a book by exact year" \{ author, editor } -> do
    _ <- referenceBook author editor "Germinal" 1885
    _ <- referenceBook author editor "L'Assommoir" 1877

    { items: books } <- findBooks (defaultFindOpt { filter = Just $ BookHasYear (Time.unsafeFromInt 1885), limit = noLimit, expectation = QuickNothingBetterThanSlowerSomething, sort = noSort })

    length books =? 1

    "Germinal" =? (books !! 0 ?? (unwrap ▷ _.name ▷ toString) ⇔ "")

  it "can correctly interpret and find texts stored in a list" \{ author, editor } -> do
    harryPotterBookId <- referenceBook author editor "Harry Potter et la Chambre des Secrets" 1998
    lotrBookId <- referenceBook author editor "Le Seigneur des Anneaux" 1954
    germinalBookId <- referenceBook author editor "Germinal" 1885

    writeArticle author [ harryPotterBookId, lotrBookId ] "My Fantasy Article"
    writeArticle author [ germinalBookId ] "My Realistic Article"

    let
      filter1 = Just $ ArticleBookHasName { name: unsafeFromString "Potter", weight: 1.0 }
      filter2 = Just $ ArticleBookHasName { name: unsafeFromString "Secrets", weight: 1.0 }
      filter3 = Just $ ArticleBookHasName { name: unsafeFromString "Anneaux", weight: 1.0 }
      filter4 = Just $ ArticleBookHasName { name: unsafeFromString "Germinal", weight: 1.0 }
      filter5 = Just $ ArticleBookHasName { name: unsafeFromString "Harry Seigneur", weight: 1.0 }

    { items: res1 } <- findArticles (defaultFindOpt { filter = filter1, limit = Finite 10, expectation = QuickNothingBetterThanSlowerSomething, after = noAfter, sort = noSort })
    length res1 =? 1
    "My Fantasy Article" =? (res1 !! 0 ?? (unwrap ▷ _.title ▷ toString) ⇔ "")

    { items: res2 } <- findArticles (defaultFindOpt { filter = filter2, limit = Finite 10, expectation = QuickNothingBetterThanSlowerSomething, after = noAfter, sort = noSort })
    length res2 =? 1
    "My Fantasy Article" =? (res2 !! 0 ?? (unwrap ▷ _.title ▷ toString) ⇔ "")

    { items: res3 } <- findArticles (defaultFindOpt { filter = filter3, limit = Finite 10, expectation = QuickNothingBetterThanSlowerSomething, after = noAfter, sort = noSort })
    length res3 =? 1
    "My Fantasy Article" =? (res3 !! 0 ?? (unwrap ▷ _.title ▷ toString) ⇔ "")

    { items: res4 } <- findArticles (defaultFindOpt { filter = filter4, limit = Finite 10, expectation = QuickNothingBetterThanSlowerSomething, after = noAfter, sort = noSort })
    length res4 =? 1
    "My Realistic Article" =? (res4 !! 0 ?? (unwrap ▷ _.title ▷ toString) ⇔ "")

    { items: res5 } <- findArticles (defaultFindOpt { filter = filter5, limit = Finite 10, expectation = QuickNothingBetterThanSlowerSomething, after = noAfter, sort = noSort })
    length res5 =? 1
    "My Fantasy Article" =? (res5 !! 0 ?? (unwrap ▷ _.title ▷ toString) ⇔ "")

  it "can find an article using global full-text search (ByMatches)" \{ author, editor } -> do
    maryGabrielId <- random
    handleCommand_ false $ ReferenceAuthor
      { id: maryGabrielId
      , name: unsafeFromString "Mary Gabriel"
      , biography: Nothing
      , portrait: Nothing
      , legacyIds: []
      }

    marxMaryGabrielBookId <- do
      bId <- random
      coverUrl <- random
      handleCommand_ false $ ReferenceBook
        { id: bId
        , authors: [ maryGabrielId ]
        , editor: Just editor
        , name: unsafeFromString "Marx intime"
        , year: Just $ Year { year: Time.unsafeFromInt 2014, approximately: false }
        , cover: coverUrl
        , legacyId: Nothing
        }
      η bId

    let
      articleCapital = "Article sur le Capital"
      articleSansRapport = "Un autre article sans rapport"

    writeArticle author [ marxMaryGabrielBookId ] articleCapital
    writeArticle author [] articleSansRapport

    let filter1 = Just $ ArticleMatches { query: "marx intime mary gabriel", weight: 1.0 }

    { items: res1 } <- findArticles (defaultFindOpt { filter = filter1, limit = Finite 10, expectation = QuickNothingBetterThanSlowerSomething, after = noAfter, sort = noSort })
    length res1 =? 1

    articleCapital =? (res1 !! 0 ?? (unwrap ▷ _.title ▷ toString) ⇔ "")

  it "can sort books by multiple criteria" \{ author, editor } -> do
    _ <- referenceBook author editor "Book B" 2000
    _ <- referenceBook author editor "Book A" 2000
    _ <- referenceBook author editor "Book D" 1990
    _ <- referenceBook author editor "Book C" 2010

    let
      sort =
        [ Sort.by @"year.year" Desc
        , Sort.by @"name" Asc
        ]

    { items: books } <- findBooks (defaultFindOpt { limit = noLimit, expectation = QuickNothingBetterThanSlowerSomething, sort = sort })

    let names = map (\(Book { name }) -> toString name) books

    names =? [ "Book C", "Book A", "Book B", "Book D" ]

  it "combines text search score and custom sort" \{ author, editor } -> do
    _ <- referenceBook author editor "Le Loup quantique" 1927
    _ <- referenceBook author editor "Le Loup de Wall Street quantique" 2007
    _ <- referenceBook author editor "Loup quantique" 2020

    let
      sort = [ Sort.by @"year.year" Desc ]
      filter = Just $ BookHasName { name: unsafeFromString "Le Loup quantique", weight: 1.0 }

    { items: books } <- findBooks (defaultFindOpt { filter = filter, limit = noLimit, expectation = QuickNothingBetterThanSlowerSomething, sort = sort })

    let namesAndYears = map (\(Book b) -> toString b.name <> " " <> show (b.year <#> (\yr -> (unwrap yr).year))) books

    namesAndYears =?
      [ "Le Loup quantique (Just (Year 1927))"
      , "Loup quantique (Just (Year 2020))"
      , "Le Loup de Wall Street quantique (Just (Year 2007))"
      ]

  it "can sort books by multiple criteria with limit, filter and cursor pagination (after)" \{ author, editor } -> do
    _ <- referenceBook author editor "Book AAA" 2010
    _ <- referenceBook author editor "Book ZZZ" 2010
    _ <- referenceBook author editor "Book CCC" 2000
    _ <- referenceBook author editor "Book BBB" 2000
    _ <- referenceBook author editor "Book EEE" 1990

    let
      sort =
        [ Sort.by @"year.year" Desc
        , Sort.by @"name" Asc
        ]
      filter = Just $ (BookHasYear (Time.unsafeFromInt 2010)) || (BookHasYear (Time.unsafeFromInt 2000))

    { items: page1 } <- findBooks (defaultFindOpt { filter = filter, limit = Finite 2, expectation = QuickNothingBetterThanSlowerSomething, after = noAfter, sort = sort })
    let names1 = map (\(Book { name }) -> toString name) page1
    names1 =? [ "Book AAA", "Book ZZZ" ]

    let afterId = page1 !! 1 <#> unwrap ▷ _.id

    { items: page2 } <- findBooks (defaultFindOpt { filter = filter, limit = Finite 2, expectation = QuickNothingBetterThanSlowerSomething, after = afterId, sort = sort })
    let names2 = map (\(Book { name }) -> toString name) page2
    names2 =? [ "Book BBB", "Book CCC" ]

    let afterId2 = page2 !! 1 <#> unwrap ▷ _.id

    { items: page3 } <- findBooks (defaultFindOpt { filter = filter, limit = Finite 2, expectation = QuickNothingBetterThanSlowerSomething, after = afterId2, sort = sort })
    let names3 = map (\(Book { name }) -> toString name) page3
    names3 =? []

  it "can find a book by strict name" \{ author, editor } -> do
    let
      germinal' = "gErminaL   "
      germina' = "germina"
      germinalll' = "germinalll"
      germinalBis' = "Germinal Bis"
      lassommoir' = "L'Assommoir"

    _ <- referenceBook author editor germinal' 1885
    _ <- referenceBook author editor germina' 1885
    _ <- referenceBook author editor germinalll' 1885
    _ <- referenceBook author editor germinalBis' 1885
    _ <- referenceBook author editor lassommoir' 1877

    { items: books } <- findMany_ (defaultFindOpt { filter = Just $ by @"name" @Book StrictlyEquals (unsafeFromString germinal') })

    length books =? 1

    germinal' =? (books !! 0 ?? (unwrap ▷ _.name ▷ toString) ⇔ "")

  it "can find a book by name up to normalization" \{ author, editor } -> do
    let
      germinal' = "gErminaL   "
      germina' = "germina"
      germinalll' = "germinalll"
      germinalBis' = "Germinal Bis"
      lassommoir' = "L'Assommoir"

    _ <- referenceBook author editor germinal' 1885
    _ <- referenceBook author editor germina' 1885
    _ <- referenceBook author editor germinalll' 1885
    _ <- referenceBook author editor germinalBis' 1885
    _ <- referenceBook author editor lassommoir' 1877

    { items: books } <- findMany_ (defaultFindOpt { filter = Just $ by @"name" @Book EqualsUpToNormalization (unsafeFromString "\n gerMinàl!") })

    length books =? 1

    germinal' =? (books !! 0 ?? (unwrap ▷ _.name ▷ toString) ⇔ "")

    { items: books' } <- findMany_ (defaultFindOpt { filter = Just $ by @"name" @Book StrictlyEquals (unsafeFromString "\n gerMinàl!") })

    length books' =? 0

  it "follows our weights" \{ author, editor } -> do
    _ <- referenceBook' author editor germinal
    _ <- referenceBook' author editor uneHistoireVraie

    assertSortedBooks
      (BookHasName { name: unsafeFromString "Germinal", weight: 1.0 })
      [ germinal
      ]

    assertSortedBooks
      ( (BookHasName { name: unsafeFromString "germinal", weight: 1.0 })
          || (BookHasName { name: unsafeFromString "histoire", weight: 1.0 })
      )
      [ germinal
      , uneHistoireVraie
      ]

    assertSortedBooks
      ( (BookHasName { name: unsafeFromString "germinal", weight: 1.0 })
          || (BookHasName { name: unsafeFromString "une histoire vraie", weight: 3.0 })
      )
      [ uneHistoireVraie
      , germinal
      ]

    assertSortedBooks
      ( (BookHasName { name: unsafeFromString "germinal", weight: 2.0 })
          || (BookHasName { name: unsafeFromString "histoire vraie", weight: 1.0 })
      )
      [ germinal
      , uneHistoireVraie
      ]

    assertSortedBooks
      ( (BookHasName { name: unsafeFromString "germinal", weight: 1.0 })
          || (BookHasName { name: unsafeFromString "une histoire vraie", weight: 3.0 })
      )
      [ uneHistoireVraie
      , germinal
      ]

    assertSortedBooks
      ( (BookHasName { name: unsafeFromString "germinal", weight: 1.0 })
          || (BookHasName { name: unsafeFromString "histoire", weight: 2.0 })
      )
      [ germinal
      , uneHistoireVraie
      ]

    assertSortedBooks
      ( (BookHasName { name: unsafeFromString "germinal", weight: 1.0 })
          || (BookHasName { name: unsafeFromString "histoire", weight: 1000000000.0 })
      )
      [ uneHistoireVraie
      , germinal
      ]

  it "follows match weights internally" \{ author, editor } -> do
    _ <- referenceBook' author editor germinal
    _ <- referenceBook' author editor lesMiserables
    _ <- referenceBook' author editor lassommoir
    _ <- referenceBook' author editor histoire
    _ <- referenceBook' author editor histoires
    _ <- referenceBook' author editor uneHistoireVraie
    _ <- referenceBook' author editor lhistoireTragiqueDeLaBelleAuBoisDormant
    _ <- referenceBook' author editor laBelleEtGrandeHistoire
    _ <- referenceBook' author editor laBelleAuBoisDormant_etc
    _ <- referenceBook' author editor piegeeParLaFee_etc_withCharlesPerroFlip
    _ <- referenceBook' author editor piegeeParLaFee_etc

    assertSortedBooks'
      "Histoire"
      QuickNothingBetterThanSlowerSomething
      [ histoire
      , histoires
      , uneHistoireVraie
      , laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , laBelleAuBoisDormant_etc
      , piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "histoire"
      QuickNothingBetterThanSlowerSomething
      [ histoire
      , histoires
      , uneHistoireVraie
      , laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , laBelleAuBoisDormant_etc
      , piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "histoires"
      QuickNothingBetterThanSlowerSomething
      [ histoires
      , histoire
      , uneHistoireVraie
      , laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , laBelleAuBoisDormant_etc
      , piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "hÎstôrïque"
      QuickNothingBetterThanSlowerSomething
      [ piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      ""
      QuickNothingBetterThanSlowerSomething
      []

    assertSortedBooks'
      ""
      SlowerSomethingBetterThanQuickNothing
      []

    assertSortedBooks'
      "a"
      QuickNothingBetterThanSlowerSomething
      []

    assertSortedBooks'
      "a"
      SlowerSomethingBetterThanQuickNothing
      []

    assertSortedBooks'
      "."
      QuickNothingBetterThanSlowerSomething
      []

    assertSortedBooks'
      "."
      SlowerSomethingBetterThanQuickNothing
      []

    assertSortedBooks'
      "harry potter"
      QuickNothingBetterThanSlowerSomething
      []

    assertSortedBooks'
      "harry potter"
      SlowerSomethingBetterThanQuickNothing
      []

    assertSortedBooks'
      "grandehistoire"
      QuickNothingBetterThanSlowerSomething
      []

    assertSortedBooks'
      "grandehistoire"
      SlowerSomethingBetterThanQuickNothing
      [ laBelleEtGrandeHistoire
      ]

    assertSortedBooks'
      "rgandehistoire"
      SlowerSomethingBetterThanQuickNothing
      [ laBelleEtGrandeHistoire
      ]

    assertSortedBooks'
      "lassommoir"
      QuickNothingBetterThanSlowerSomething
      [ lassommoir
      ]

    assertSortedBooks'
      "lassommoir"
      SlowerSomethingBetterThanQuickNothing
      [ lassommoir
      ]

    assertSortedBooks'
      "l assommoir"
      QuickNothingBetterThanSlowerSomething
      [ lassommoir
      ]

    assertSortedBooks'
      "l.assommoir"
      QuickNothingBetterThanSlowerSomething
      [ lassommoir
      ]

    assertSortedBooks'
      "miserâBle"
      QuickNothingBetterThanSlowerSomething
      [ lesMiserables
      ]

    assertSortedBooks'
      "miserâBle"
      SlowerSomethingBetterThanQuickNothing
      [ lesMiserables
      ]

    assertSortedBooks'
      "germinall"
      QuickNothingBetterThanSlowerSomething
      [ germinal
      ]

    assertSortedBooks'
      "germinall"
      SlowerSomethingBetterThanQuickNothing
      [ germinal
      ]

    assertSortedBooks'
      "histoie"
      QuickNothingBetterThanSlowerSomething
      [ histoire
      , histoires
      , uneHistoireVraie
      , laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , laBelleAuBoisDormant_etc
      , piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "histoier"
      QuickNothingBetterThanSlowerSomething
      [ histoire
      , histoires
      , uneHistoireVraie
      , laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , laBelleAuBoisDormant_etc
      , piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "ihstoire"
      QuickNothingBetterThanSlowerSomething
      [ histoire
      , histoires
      , uneHistoireVraie
      , laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , laBelleAuBoisDormant_etc
      , piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "belle histoire"
      QuickNothingBetterThanSlowerSomething
      [ laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , laBelleAuBoisDormant_etc
      ]

    assertSortedBooks'
      "belle histoire"
      SlowerSomethingBetterThanQuickNothing
      [ laBelleAuBoisDormant_etc
      , piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      , laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , uneHistoireVraie
      , histoires
      , histoire
      ]

    assertSortedBooks'
      "histoire, belle ?!"
      QuickNothingBetterThanSlowerSomething
      [ laBelleEtGrandeHistoire
      , lhistoireTragiqueDeLaBelleAuBoisDormant
      , laBelleAuBoisDormant_etc
      ]

    assertSortedBooks'
      "mauvaise aiternel jeun"
      QuickNothingBetterThanSlowerSomething
      [ piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "Charles Perr"
      QuickNothingBetterThanSlowerSomething
      [ piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "Charles Perr"
      SlowerSomethingBetterThanQuickNothing
      [ piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      , laBelleAuBoisDormant_etc
      ]

    assertSortedBooks'
      "Charles Perro"
      QuickNothingBetterThanSlowerSomething
      [ piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

    assertSortedBooks'
      "Charles Perrault"
      QuickNothingBetterThanSlowerSomething
      [ laBelleAuBoisDormant_etc
      ]

    assertSortedBooks'
      "Perro Charles"
      QuickNothingBetterThanSlowerSomething
      [ piegeeParLaFee_etc
      , piegeeParLaFee_etc_withCharlesPerroFlip
      ]

referenceBook :: AuthorId -> EditorId -> String -> Int -> TestM BookId
referenceBook author editor name year = do
  bookId <- random

  coverUrl <- random

  handleCommand_ false $ ReferenceBook
    { id: bookId
    , authors: [ author ]
    , editor: Just editor
    , name: unsafeFromString name
    , year: Just $ Year { year: Time.unsafeFromInt year, approximately: false }
    , cover: coverUrl
    , legacyId: Nothing
    }

  η bookId

referenceBook' :: AuthorId -> EditorId -> String -> TestM BookId
referenceBook' author editor name = referenceBook author editor name 2000

writeArticle :: AuthorId -> Array BookId -> String -> TestM Ɩ
writeArticle authorId bookIds titleStr = do
  articleId <- random
  legacyId <- random

  handleCommand_ false $ WriteArticle
    { id: articleId
    , legacyId: legacyId
    , books: bookIds
    , author: Just authorId
    , theme: Nothing
    , title: unsafeFromString titleStr
    , lead: Nothing
    , notes: Nothing
    , sources: Nothing
    , content: unsafeFromString "<p>Some HTML Content</p>"
    , illustrations: []
    , profitable: true
    , slug: Nothing
    , magazineIssue: Nothing
    }

searchBooks :: String -> Expectation -> TestM (Array Book)
searchBooks search expectation =
  findBooks (defaultFindOpt { filter = Just $ BookHasName { name: unsafeFromString search, weight: 1.0 }, limit = noLimit, expectation = expectation, sort = noSort }) >>= (η ◁ _.items)

assertFoundBooks :: String -> Int -> TestM Ɩ
assertFoundBooks name count = do
  books <- searchBooks name QuickNothingBetterThanSlowerSomething
  length books =? count

assertSortedBooks :: BookFilter -> Array String -> TestM Ɩ
assertSortedBooks filter expectedBookNames = do
  { items: books } <- findBooks (defaultFindOpt { filter = Just filter, limit = noLimit, expectation = QuickNothingBetterThanSlowerSomething, sort = noSort })

  expectedBookNames =? (map (\(Book { name }) -> toString name) books)

assertSortedBooks' :: String -> Expectation -> Array String -> TestM Ɩ
assertSortedBooks' search expectation expectedBookNames = do
  books <- searchBooks search expectation

  expectedBookNames =? (map (\(Book { name }) -> toString name) books)

type SharedEntities =
  { author :: AuthorId
  , editor :: EditorId
  }

setupEntities :: TestM SharedEntities
setupEntities = do
  author <- random
  handleCommand_ false $ ReferenceAuthor
    { id: author
    , name: unsafeFromString "Zola"
    , biography: Just $ unsafeFromString "Blablah..."
    , legacyIds: []
    , portrait: Nothing
    }

  editor <- random
  handleCommand_ false $ ReferenceEditor
    { id: editor
    , name: unsafeFromString "Flammarion"
    , legacyBookIds: [ 1 ]
    }

  η { author, editor }

withEntities :: (SharedEntities -> TestM Ɩ) -> TestM Ɩ
withEntities f = do
  ctx <- setupEntities
  f ctx

germinal = "Germinal" :: String
lesMiserables = "Les Misérables" :: String
lassommoir = "L'Assommoir" :: String
histoire = "Histoire" :: String
histoires = "Histoires" :: String
uneHistoireVraie = "Une histoire vraie" :: String
lhistoireTragiqueDeLaBelleAuBoisDormant = "L'histoire tragique de la belle au bois dormant" :: String
laBelleEtGrandeHistoire = "La belle et grande histoire" :: String
laBelleAuBoisDormant_etc = "La Belle au bois dormant[1] est un conte populaire, une histoire, qui se rattache au conte-type 410, dans les dernières versions de la classification Aarne-Thompson[2]. Parmi les versions les plus célèbres figurent celle de Charles Perrault, publiée en 1697 dans Les Contes de ma mère l'Oye (une autre histoire), et celle des frères Grimm Dornröschen publiée en 1812.La version de Perrault est fondée sur Soleil, Lune et Thalie de Giambattista Basile (publié à titre posthume en 1634), un conte lui-même fondé sur un ou plusieurs contes populaires. Une des premières versions connues de l'histoire est Perceforest, composé entre 1330 et 1344 et imprimé en 1528. Mais on peut aussi mentionner la version provençale (parfois considérée comme catalane) de la même époque que constitue Frayre de Joy e Sor de Plaser[3],[4]." :: String
piegeeParLaFee_etc = "Piégée par la Fée de la peur afin qu'elle touche une rose empoisonnée, une jeune princesse tombe dans un sommeil profond et éternel. Un seul remède peut rompre cet haineux sortilège - le premier baiser du véritable amour (Charles Perro).L'histoire familière de la princesse ensorcelée Aurore, des bonnes et des mauvaises fées et du prince aventureux prend tout son sens comme ballet. Les costumes et les décors époustouflants évoquent un monde de contes de fées richement coloré, qui captivera le public, des jeunes enfants aux adultes. La Belle au Bois Dormant est une première expérience idéale de ballet pour un enfant. Voilà pour l'historique." :: String
piegeeParLaFee_etc_withCharlesPerroFlip = "Piégée par la Fée de la peur afin qu'elle touche une rose empoisonnée, une jeune princesse tombe dans un sommeil profond et éternel. Un seul remède peut rompre cet haineux sortilège - le premier baiser du véritable amour (Perro Charles).L'histoire familière de la princesse ensorcelée Aurore, des bonnes et des mauvaises fées et du prince aventureux prend tout son sens comme ballet. Les costumes et les décors époustouflants évoquent un monde de contes de fées richement coloré, qui captivera le public, des jeunes enfants aux adultes. La Belle au Bois Dormant est une première expérience idéale de ballet pour un enfant. Voilà pour l'historique." :: String
