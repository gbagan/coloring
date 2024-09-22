import { Component, createSignal, For, Index, Show } from 'solid-js';
import { Edge, getCoordsOfEdge, Graph, Position } from '../graph';
import { colors } from '../colors';
import EdgeView from './Edge';

const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

type EditMode = "move" | "addv" | "adde" | "delete";

function getPointerPosition(e: MouseEvent): Position {
  const el = e.currentTarget as Element;
  const { left, top, width, height } = el.getBoundingClientRect();
  return { x: (e.clientX - left) / width, y: (e.clientY - top) / height };
}

type GraphComponent = Component<{
  graph: Graph,
  colors: number[],
  showLetters: boolean,
  addVertex: (pos: Position) => void,
  moveVertex: (idx: number, pos: Position) => void,
  addEdge: (u: number, v: number) => void,
  removeVertex: (idx: number) => void,
  removeEdge: (edge: Edge) => void,
}>;

const GraphView: GraphComponent = props => {
  const [editMode, setEditMode] = createSignal("move" as EditMode);
  const [pointerPosition, setPointerPosition] = createSignal(null as Position | null);
  const [selectedVertex, setSelectedVertex] = createSignal(null as number | null);

  const selectedPosition = () => props.graph.layout[selectedVertex()!];

  const move = (ev: MouseEvent) => {
    const pos = getPointerPosition(ev);
    const idx = selectedVertex();
    const mode = editMode();
    if (mode === "move" && idx !== null) {
      props.moveVertex(idx, pos);
    } else if (mode === "adde") {
      setPointerPosition(pos);
    }
  }

  const pointerDown = (idx: number) => {
    const mode = editMode();
    if (mode === "move" || mode === "adde") {
      setSelectedVertex(idx);
    }
  }

  const pointerUp = (ev: MouseEvent, idx: number) => {
    ev.stopPropagation();
    const mode = editMode();
    const idx2 = selectedVertex();
    if (mode === "adde" && idx2 !== null && idx2 !== idx) {
      props.addEdge(idx, idx2);
    }
    setSelectedVertex(null);
  }

  return (
    <div>
      <div class="w-3xl h-3xl">
        <svg
          viewBox="0 0 100 100"
          class="block"
          onPointerMove={move}
          onPointerUp={() => editMode() === "adde" && setSelectedVertex(null)}
          onClick={e => editMode() === "addv" && props.addVertex(getPointerPosition(e))}
        >
          <For each={props.graph.edges}>
            {edge => (
              <EdgeView
                coords={getCoordsOfEdge(props.graph, edge)}
                onClick={() => editMode() === "delete" && props.removeEdge(edge)}
              />
            )}
          </For>
          <Index each={props.graph.layout}>
            {(pos, i) => (
              <circle
                cx={100 * pos().x}
                cy={100 * pos().y}
                r={props.showLetters ? 4 : 2}
                stroke-width="0.5"
                stroke="black"
                class={"touch-none " + (colors[props.colors[i]] ?? "fill-white")}
                onPointerDown={() => pointerDown(i)}
                onPointerUp={e => pointerUp(e, i)}
                onClick={() => editMode() === "delete" && props.removeVertex(i)}
              />
            )}
          </Index>
          <Show when={props.showLetters}>
            <Index each={props.graph.layout}>
              {(pos, i) => (
                <text
                  x={100 * pos().x - 2}
                  y={100 * pos().y + 2}
                  class="graphtext pointer-events-none touch-none select-none"
                >
                  {alphabet[i]}
                </text>
              )}
            </Index>
          </Show>
          <Show when={editMode() == "adde" && selectedVertex() !== null && pointerPosition()}>
            <line
              x1={100 * selectedPosition().x}
              y1={100 * selectedPosition().y}
              x2={100 * pointerPosition()!.x}
              y2={100 * pointerPosition()!.y}
              stroke-width="0.5"
              class="stroke-blue-500 pointer-events-none"
            />
          </Show>
        </svg>
      </div>
      <div class="btngroup">
        <button class="btn rounded-l-md" onClick={() => setEditMode("move")}>Déplacer</button>
        <button class="btn" onClick={() => setEditMode("addv")}>Ajouter sommet</button>
        <button class="btn" onClick={() => setEditMode("adde")}>Ajouter arête</button>
        <button class="btn" onClick={() => setEditMode("delete")}>Retirer</button>
        <button class="btn">Tout effacer</button>
        <button class="btn rounded-r-md">Réinitialiser</button>
      </div>
    </div>
  )
}

export default GraphView;