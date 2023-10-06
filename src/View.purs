module GraphParams.View (view) where

import Relude

import GraphParams.GraphView (graphView)
import GraphParams.Model (Model, Algorithm(..), algoToString, orderingToString)
import GraphParams.Msg (Msg(..))
import GraphParams.UI as UI
import Pha.Html (Html)
import Pha.Html as H
import Pha.Html.Attributes as P
import Pha.Html.Events as E

view ∷ Model → Html Msg
view model@{ selectedAlgorithm, results } =
  H.div [ H.class_ "flex flex-row justify-between" ]
    [ H.div [ H.class_ "w-3/4" ]
        [ UI.card "Graph" [graphView model] ]
    , H.div [ H.class_ "flex flex-col graphparams-help-container" ]
        [ H.text "Graphe"
        , H.select [H.class_ UI.selectClass, P.value "1",  E.onValueChange SetGraph]
            [ H.option [P.value "1"] [H.text "Graphe 1"]
            , H.option [P.value "2"] [H.text "Graphe 2"]
            , H.option [P.value "3"] [H.text "Graphe 3"]
            , H.option [P.value "4"] [H.text "Graphe 4"]
            ]
        , UI.button {onClick: Save, name: "Sauvegarder", attrs: [] }
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
                ]
            _ -> H.empty
        , UI.button {onClick: Compute, name: "Calculer", attrs: [] }
        , H.text "Résultats"
        , H.div [] $
            results <#> \{algorithm, number} ->
              H.text $ algoToString algorithm <> "(" <> show number <> ")"
        , UI.button {onClick: PreviousStep, name: "Etape précédente", attrs: [] }
        , UI.button {onClick: NextStep, name: "Etape suivante", attrs: [] }
        , UI.button {onClick: FinishColoring, name: "Termine la coloration", attrs: [] }
        ]
    ]