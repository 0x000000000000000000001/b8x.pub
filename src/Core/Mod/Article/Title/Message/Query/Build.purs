module Core.Mod.Article.Title.Message.Query.Build where

import Proem

import Core.Message.Query.Payload as Payload
import Core.Message.Query.Result as Result
import Core.Mod.Article.Title.Message.Query.Opt (TitleOpt, TitleInnerNeeds)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Article.Title.Clean as TitleClean

buildTitle :: Payload.Need TitleOpt TitleInnerNeeds -> Title -> Result.Return Title
buildTitle Payload.NotNeeded _ = Result.NotGivenBecauseNotNeeded
buildTitle (Payload.Needed { untagHtml } _) title = Result.Given $ TitleClean.cleanHtml untagHtml title
