module Util.Type.String.Test.Slugify where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Type.String.String (slugify)

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.Slugify"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "converts simple name to slug" do
    slugify "Christelle Evita" =? "christelle-evita"

  it "handles hyphenated names" do
    slugify "Jean-Paul Dupont" =? "jean-paul-dupont"

  it "trims spaces" do
    slugify "  Marie  Louise  " =? "marie-louise"

  it "removes accents from French characters" do
    slugify "François" =? "francois"
    slugify "Hélène" =? "helene"
    slugify "Jérôme" =? "jerome"

  it "handles uppercase" do
    slugify "HELLO WORLD" =? "hello-world"

  it "handles mixed case" do
    slugify "HeLLo WoRLd" =? "hello-world"

  it "removes special characters" do
    slugify "Hello@World!" =? "helloworld"

  it "handles multiple spaces" do
    slugify "hello     world" =? "hello-world"

  it "removes consecutive dashes" do
    slugify "hello--world" =? "hello-world"

  it "trims leading and trailing dashes" do
    slugify "-hello-world-" =? "hello-world"

  it "handles empty string" do
    slugify "" =? ""

  it "handles string with only spaces" do
    slugify "   " =? ""

  it "handles string with only special characters" do
    slugify "@#$%^&*()" =? ""

  it "preserves numbers" do
    slugify "test 123" =? "test-123"

  it "handles complex accented text" do
    slugify "Café de l'été" =? "cafe-de-lete"

  it "handles all types of accents" do
    slugify "àâäéèêëïîôöùûüç" =? "aaaeeeeiioouuuc"

  it "handles uppercase accents" do
    slugify "ÀÂÄÉÈÊËÏÎÔÖÙÛÜÇ" =? "aaaeeeeiioouuuc"

  it "handles multiple consecutive special chars" do
    slugify "hello!!!world" =? "helloworld"

  it "handles mixed content" do
    slugify "Test-123 @Home!" =? "test-123-home"
