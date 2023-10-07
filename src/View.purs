module GraphParams.View (view) where

import Relude

import GraphParams.GraphView (graphView)
import GraphParams.Model (Model, Algorithm(..), Dialog(..), algoToString, orderingToString)
import GraphParams.Msg (Msg(..))
import GraphParams.Util (repeat)
import GraphParams.UI as UI
import Pha.Html (Html)
import Pha.Html as H
import Pha.Html.Attributes as P
import Pha.Html.Events as E
import Pha.Svg as S
import Pha.Svg.Attributes as SA

exportDialog ∷ String → Html Msg
exportDialog text = UI.dialog "Exporter les graphes" [body] buttons
  where
  body = H.textarea [H.class_ UI.textareaClass, P.cols 150, P.rows 30, P.value text, P.readonly true]
  buttons = [ { name: "OK", onClick: CloseDialog } ]

importDialog ∷ String → Html Msg
importDialog text = UI.dialog "Importer les graphes" [body] buttons
  where
  body = H.textarea
          [ H.class_ UI.textareaClass
          , P.cols 150
          , P.rows 30
          , P.value text
          , E.onValueChange ChangeImportText
          ]
  buttons =
    [ { name: "Annuler", onClick: CloseDialog }
    , { name: "OK", onClick: ImportAndClose }
    ]

view ∷ Model → Html Msg
view model@{ dialog, selectedAlgorithm, results, selectedResultIndex } =
  H.div [ H.class_ "flex flex-row justify-around" ]
    [ UI.card "Graphe" [graphView model]
    , UI.card "Ordre des couleurs"
      [ H.div [H.class_ "w-16"]
          [ S.svg [SA.viewBox 0.0 0.0 10.0 100.0] $
              (0..9) <#> \i ->
                S.rect [SA.x 0, SA.y $ i * 10, SA.width 10, SA.height 10, H.class_ $ "color" <> show i]
          ]
      ]
    , H.div [ H.class_ "flex flex-col" ]
        [ H.span [H.class_ "mb-2 mt-4 text-2xl font-bold"] [H.text "Graphe"]
        , H.select [H.class_ UI.selectClass, P.value "1",  E.onValueChange SetGraph]
            [ H.option [P.value "1"] [H.text "Graphe 1"]
            , H.option [P.value "2"] [H.text "Graphe 2"]
            , H.option [P.value "3"] [H.text "Graphe 3"]
            , H.option [P.value "4"] [H.text "Graphe 4"]
            ]
        , UI.buttonGroup
            [ {onClick: Save, name: "Sauvegarder", attrs: [] }
            , {onClick: OpenImportDialog, name: "Importer", attrs: [] }
            , {onClick: Export, name: "Exporter", attrs: [] }
            ]
        , H.span [H.class_ "mb-2 mt-4 text-2xl font-bold"] [H.text "Algorithme"]
        , H.select [H.class_ UI.selectClass, P.name "dsatur", E.onValueChange SetAlgo]
            [ H.option [P.value "alpha"] [H.text "Alphabetique"]
            , H.option [P.value "decdegree"] [H.text "Degré décroissant"]
            , H.option [P.value "welsh"] [H.text "Welsh and Powell"]
            , H.option [P.value "dsatur"] [H.text "DSatur"]
            , H.option [P.value "custom"] [H.text "Personnalisé"]
            ]
        , case selectedAlgorithm of
            CustomAlgorithm ord -> 
              H.input 
                [ H.class_ UI.textInputClass
                , P.type_ "text"
                , P.value $ orderingToString ord
                , E.onValueChange CustomAlgoTextChange
                ]
            _ -> H.empty
        , UI.button {onClick: Compute, name: "Calculer", attrs: [] }
        , H.span [H.class_ "mb-2 mt-4 text-2xl font-bold"] [H.text "Résultats"]
        , H.ul [H.class_ "ml-4 list-disc"] $
            (results # mapWithIndex \idx {algorithm, number} ->
              H.li
                [ H.class' "text-blue-600" $ selectedResultIndex == idx
                , E.onClick \_ -> SetResultIndex idx
                ]
                [ H.text $ algoToString algorithm <> " (" <> show number <> " couleurs)" ]
            ) <> (repeat (5 - length results) \_ -> H.li [] [])
        , UI.buttonGroup 
            [ {onClick: PreviousStep, name: "Etape précédente", attrs: [] }
            , {onClick: NextStep, name: "Etape suivante", attrs: [] }
            , {onClick: FinishColoring, name: "Termine la coloration", attrs: [] }
            ]
        ]
    , case dialog of
        NoDialog -> H.empty
        ExportDialog text -> exportDialog text
        ImportDialog text -> importDialog text
    ]