module GraphParams.GraphView where

import Relude

import GraphParams.Graph as Graph
import GraphParams.Model (Model, Position, EditMode(..), selectedGraph, nbVertices, partialColoring, labelToString)
import GraphParams.Msg (Msg(..))
import GraphParams.UI as UI
import GraphParams.Util (map2)
import Pha.Html (Html)
import Pha.Html as H
import Pha.Html.Attributes as P
import Pha.Html.Events as E
import Pha.Svg as S
import Pha.Svg.Attributes as SA


currentLine ∷ ∀ a. Position → Position → Html a
currentLine p1 p2 =
  S.line
    [ SA.x1 $ 100.0 * p1.x
    , SA.y1 $ 100.0 * p1.y
    , SA.x2 $ 100.0 * p2.x
    , SA.y2 $ 100.0 * p2.y
    , H.class_ "graphparams-graphview-edge pointer-events-none"
    ]

graphView ∷ Model → Html Msg
graphView model@{ editmode, currentPosition, selectedVertex } =
  let
    n = nbVertices model
    graph@{ layout, edges } = selectedGraph model
    vertexColor = partialColoring model
  in
    H.div []
      [ H.div [ H.class_ "graphparams-graphview-board" ]
          [ S.svg
              [ H.class_ "block"
              , SA.viewBox 0.0 0.0 100.0 100.0
              , E.onClick AddVertex
              , E.onPointerUp \_ → DropOrLeave
              , E.onPointerLeave \_ → DropOrLeave
              , E.onPointerMove $ GraphMove
              ]
              [ S.g []
                  $ edges
                  <#> \edge →
                      H.maybe (Graph.getCoordsOfEdge graph edge) \{ x1, x2, y1, y2 } →
                        S.line
                          [ SA.x1 $ 100.0 * x1
                          , SA.y1 $ 100.0 * y1
                          , SA.x2 $ 100.0 * x2
                          , SA.y2 $ 100.0 * y2
                          , H.class_ "graphparams-graphview-edge"
                          , H.class' "deletemode" $ editmode == DeleteMode
                          , E.onClick \_ → DeleteEdge edge
                          ]
              , S.g []
                  $ map2 layout vertexColor \i { x, y } color →
                      S.circle
                        [ SA.cx $ 100.0 * x
                        , SA.cy $ 100.0 * y
                        , SA.r 4
                        , SA.strokeWidth 0.5
                        , H.class_ $ "graphparams-graphview-vertex color" <> show color
                        , H.class' "deletemode" $ editmode == DeleteMode
                        , E.onClick (DeleteVertex i)
                        , E.onPointerDown (SelectVertex i)
                        , E.onPointerUp \_ → PointerUp i
                        ]
              , H.when (n <= 26) \_ ->
                  S.g [] $
                    layout # mapWithIndex \idx {x, y} ->
                        S.text 
                          [ H.class_ "pointer-events-none graphview-text"
                          , SA.x (100.0 * x - 2.0)
                          , SA.y (100.0 * y + 2.0)
                          ]
                          [ H.text $ labelToString idx ]
              , H.when (editmode == AddEMode) \_ →
                  H.fromMaybe case selectedVertex of
                    Just v → currentLine <$> currentPosition <*> Graph.getCoords graph v
                    _ → Nothing
              ]
          ]
      , UI.buttonGroup
          [ { name: "Déplacer", onClick: SetEditMode MoveMode, attrs: [ P.selected $ editmode == MoveMode] }
          , { name: "Ajouter sommet", onClick: SetEditMode VertexMode, attrs: [ P.selected $ editmode == VertexMode ] }
          , { name: "Ajouter arête", onClick: SetEditMode AddEMode, attrs: [ P.selected $ editmode == AddEMode ] } 
          , { name: "Retirer", onClick: SetEditMode DeleteMode, attrs: [ P.selected $ editmode == DeleteMode] }
          , { name: "Tout effacer", onClick: ClearGraph, attrs: [ ] }
          , { name: "Ajuster", onClick: AdjustGraph, attrs: [ ] }
          , { name: "Gros graphe", onClick: GenBigGraph, attrs: [ ] }
          ]
      ]
