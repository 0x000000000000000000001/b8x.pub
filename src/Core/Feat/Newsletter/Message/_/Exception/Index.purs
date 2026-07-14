module Core.Feat.Newsletter.Message.Exception.Index where

import Core.Feat.Newsletter.Message.Command.Exception.Index (NewsletterCommandExceptionRow)
import Type.Row (type (+))

type NewsletterMessageExceptionRow :: Row Type -> Row Type
type NewsletterMessageExceptionRow r =
  NewsletterCommandExceptionRow
    + r
