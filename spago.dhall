{ name = "graphparams"
, dependencies =
  [ "argonaut-codecs"
  , "argonaut-core"
  , "arrays"
  , "integers"
  , "numbers"
  , "pha"
  , "profunctor-lenses"
  , "relude"
  , "st"
  , "strings"
  , "web-dom"
  , "web-events"
  , "web-html"
  , "web-pointerevents"
  , "web-storage"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
