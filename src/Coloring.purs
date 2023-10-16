module GraphParams.Coloring where

import Relude
import Control.Monad.ST as ST
import Control.Monad.ST (ST)
import Data.Array.ST as STA
import Data.Array.ST (STArray)
import GraphParams.Graph (AdjGraph)

type Coloring = Array { vertex ∷ Int, color ∷ Int }

firstAvailableColor ∷ AdjGraph → Array Int → Int → Int
firstAvailableColor graph colors u = go 0
  where
  adjColors = (graph !! u ?: []) # map \v -> colors !! v ?: (-1)
  go i | i `elem` adjColors = go (i+1)
       | otherwise = i

colorWithFirstAvailable ∷ forall h. AdjGraph → STArray h Int → Int → ST h Int
colorWithFirstAvailable graph colors u = do
  colors' <- STA.unsafeFreeze colors
  let c = firstAvailableColor graph colors' u
  _ <- colors # STA.poke u c
  pure c

customColoring :: AdjGraph → Array Int → Coloring
customColoring graph ordering =
  let
    clrs = STA.run do
      colors <- STA.unsafeThaw $ replicate (length ordering) (-1)
      ST.foreach ordering \vertex →
        void $ colorWithFirstAvailable graph colors vertex
      pure colors
  in
    ordering <#> \v → { vertex: v, color: clrs !! v ?: 0 }

alphabeticalColoring ∷ AdjGraph → Coloring
alphabeticalColoring [] = []
alphabeticalColoring graph = customColoring graph (0 .. (length graph - 1))

decreasingDegreeColoring ∷ AdjGraph → Coloring
decreasingDegreeColoring [] = []
decreasingDegreeColoring graph = customColoring graph ordering
  where
  ordering = 0 .. (length graph - 1) # sortWith \u → negate <$> length <$> graph !! u

foreign import indSetColoringImpl ∷ AdjGraph → Array Int → Coloring

indSetColoring ∷ AdjGraph → Coloring
indSetColoring [] = []
indSetColoring graph = indSetColoringImpl graph ordering
  where
  ordering = 0 .. (length graph - 1) # sortWith \u → negate <$> length <$> graph !! u

dsaturStep ∷ AdjGraph → Array Int → Maybe Int
dsaturStep graph colors =
  zip graph colors 
    # mapWithIndex (\u (nbor /\ color) → do
        guard $ color == -1
        Just
            { vertex: u
            , saturation: nbor 
                            # map (\v -> colors !! v ?: -1)
                            # filter (_ /= -1)
                            # nub
                            # length
            , degree: length nbor
            }
    )
    # catMaybes
    # maximumBy (comparing \{saturation, degree} -> saturation /\ degree)
    # map _.vertex


dsatur ∷ AdjGraph → Coloring
dsatur graph = STA.run do
  colors <- STA.unsafeThaw $ replicate (length graph) (-1)
  result <- STA.new
  ST.foreach graph \_ → do
    mayv <- dsaturStep graph <$> STA.unsafeFreeze colors
    case mayv of
        Nothing → pure unit
        Just v → do
            c <- colorWithFirstAvailable graph colors v
            void $ result # STA.push { vertex: v, color: c }
  pure result