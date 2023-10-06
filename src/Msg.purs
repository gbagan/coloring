module GraphParams.Msg where

import Web.UIEvent.MouseEvent (MouseEvent)
import Web.PointerEvent (PointerEvent)
import GraphParams.Graph (Edge)
import GraphParams.Model (EditMode)

data Msg
  = AddVertex MouseEvent
  | SelectVertex Int PointerEvent
  | PointerUp Int
  | GraphMove PointerEvent
  | DeleteVertex Int MouseEvent
  | DeleteEdge Edge
  | DropOrLeave
  | SetEditMode EditMode
  | ClearGraph
  | AdjustGraph
  | GenBigGraph
  | SetGraph String
  | SetAlgo String
  | CustomAlgoTextChange String
  | SetResultIndex Int
  | Save
  | Load
  | OpenImportDialog
  | Export
  | ChangeImportText String
  | ImportAndClose
  | CloseDialog
  | Compute
  | PreviousStep
  | NextStep
  | FinishColoring