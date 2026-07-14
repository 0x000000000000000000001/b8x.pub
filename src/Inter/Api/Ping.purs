module Inter.Api.Ping (handlePing) where

import Proem

import Effect.Aff (Aff)

handlePing :: Aff String
handlePing = η "pong"
