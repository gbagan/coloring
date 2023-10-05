module GraphParams.Coloring where

import Prelude
import Data.Array ((..), (!!), length, sortWith)
import GraphParams.Graph (AdjGraph)

type Coloring = Array { vertex :: Int, color :: Int }

foreign import customColoring :: AdjGraph -> Array Int -> Coloring

foreign import dsatur :: AdjGraph -> Coloring

alphabeticalColoring :: AdjGraph -> Coloring
alphabeticalColoring [] = []
alphabeticalColoring graph = customColoring graph (0 .. (length graph - 1))

decreasingDegreeColoring :: AdjGraph -> Coloring
decreasingDegreeColoring [] = []
decreasingDegreeColoring graph = customColoring graph ordering
    where
    ordering = 0 .. (length graph - 1) # sortWith \u -> negate <$> length <$> graph !! u