module Core.Mod.Newsletter.Exception.Index where

import Core.Mod.Newsletter.Exception.NewsletterAlreadyScheduled (NewsletterAlreadyScheduledRow)
import Type.Row (type (+))

type NewsletterExceptionRow r =
  NewsletterAlreadyScheduledRow
    + r
