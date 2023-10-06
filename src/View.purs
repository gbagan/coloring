module GraphParams.View (view) where

import Relude

import GraphParams.GraphView (graphView)
import GraphParams.Model (Model, Algorithm(..), Dialog(..), algoToString, orderingToString)
import GraphParams.Msg (Msg(..))
import GraphParams.UI as UI
import Pha.Html (Html)
import Pha.Html as H
import Pha.Html.Attributes as P
import Pha.Html.Events as E

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
view model@{ dialog, selectedAlgorithm, results, currentResultIndex } =
  H.div [ H.class_ "flex flex-row justify-between" ]
    [ H.div [ H.class_ "w-3/4" ]
        [ UI.card "Graphe" [graphView model] ]
    , H.div [ H.class_ "flex flex-col graphparams-help-container" ]
        [ H.text "Graphe"
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
        , H.text "Algorithme"
        , H.select [H.class_ UI.selectClass, P.name "dsatur", E.onValueChange SetAlgo]
            [ H.option [P.value "alpha"] [H.text "Alphabetique"]
            , H.option [P.value "decdegree"] [H.text "Degré décroissant"]
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
        , H.text "Résultats"
        , H.div [H.class_ "flex flex-col"] $
            results # mapWithIndex \idx {algorithm, number} ->
              H.div
                [ H.class' "text-blue-600" $ currentResultIndex == idx
                , E.onClick \_ -> SetResultIndex idx
                ]
                [ H.text $ algoToString algorithm <> "(" <> show number <> ")" ]
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