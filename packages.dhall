let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.8-20230515/packages.dhall
        sha256:34308184189e985277c9f0214c489a845e260ff7472f322c42f5fa49e8773c11

let additions =
      { pha =
        { dependencies =
          [ "aff"
          , "effect"
          , "free"
          , "prelude"
          , "profunctor-lenses"
          , "unsafe-reference"
          , "web-uievents"
          , "web-pointerevents"
          ]
        , repo = "https://github.com/gbagan/purescript-pha.git"
        , version = "master"
        }
      , relude =
        { dependencies =
          [ "aff"
          , "arrays"
          , "control"
          , "effect"
          , "either"
          , "foldable-traversable"
          , "generate-values"
          , "integers"
          , "lazy"
          , "lists"
          , "maybe"
          , "numbers"
          , "ordered-collections"
          , "prelude"
          , "profunctor-lenses"
          , "transformers"
          , "tuples"
          , "unfoldable"
          ]
        , repo = "https://github.com/gbagan/purescript-relude.git"
        , version = "master"
        }
      }


in      upstream // additions
