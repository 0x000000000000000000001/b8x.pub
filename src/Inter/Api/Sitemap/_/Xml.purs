module Inter.Api.Sitemap.Xml where

import Proem

import Effect.Aff (Aff)
import Node.Encoding (Encoding(..))
import Node.HTTP.OutgoingMessage (setHeader, toWriteable)
import Node.HTTP.ServerResponse (setStatusCode, toOutgoingMessage)
import Node.HTTP.Types (ServerResponse)
import Node.Stream (end, writeString)

sendXml :: ServerResponse -> Int -> String -> Aff Ɩ
sendXml res statusCode body = ʌ do
  setStatusCode statusCode res
  let msg = toOutgoingMessage res
  setHeader "Content-Type" "application/xml; charset=utf-8" msg
  _ <- writeString (toWriteable msg) UTF8 body
  end (toWriteable msg)