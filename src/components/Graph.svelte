<script lang="ts">
  import { type Edge, getCoordsOfEdge, type Graph, type Position } from '../lib/graph';
  import type { Mode } from '../types';

  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  function getPointerPosition(e: MouseEvent): Position {
    const el = e.currentTarget as Element
    const { left, top, width, height } = el.getBoundingClientRect();
    return { x: (e.clientX - left) / width, y: (e.clientY - top) / height };
  }

  type Props = {
    graph: Graph;
    colors: number[];
    mode: Mode;
    showLetters: boolean;
    addVertex: (pos: Position) => void;
    moveVertex: (idx: number, pos: Position) => void;
    addEdge: (u: number, v: number) => void;
    removeVertex: (idx: number) => void;
    removeEdge: (edge: Edge) => void;

  }

  let { graph, mode, colors, showLetters,
        addVertex, moveVertex, addEdge, removeVertex, removeEdge }: Props = $props();

  let pointerPosition = $state<Position | null>(null);
  let selectedVertex = $state<number | null>(null);

  function handleMove(ev: MouseEvent) {
    const pos = getPointerPosition(ev);
    const idx = selectedVertex;
    if (mode === "move" && idx !== null) {
      moveVertex(idx, pos);
    } else if (mode === "adde") {
      pointerPosition = pos;
    }
  }

  function handlePointerDown(idx: number, e: PointerEvent) {
    if (mode === "move" || mode === "adde") {
      if (e.currentTarget) {
        (e.currentTarget as Element).releasePointerCapture(e.pointerId);
      }
      selectedVertex = idx;
    }
  }

  function handlePointerUp(idx: number, ev: MouseEvent) {
    ev.stopPropagation();
    const idx2 = selectedVertex;
    if (mode === "adde" && idx2 !== null && idx2 !== idx) {
      addEdge(idx, idx2);
    }
    selectedVertex = null;
  }

  function handleNodeClick(idx: number, ev: MouseEvent) {
    ev.stopPropagation();
    if (mode === "delete") {
      removeVertex(idx);
    }
  }
</script>

<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<svg
  viewBox="0 0 200 200"
  class={{deletemode: mode === "delete"}}
  onpointermove={handleMove}
  onpointerup={() => mode === "adde" && (selectedVertex = null)}
  onclick={e => mode === "addv" && addVertex(getPointerPosition(e))}
>
  {#each graph.edges as edge}
    {@const {x1, x2, y1, y2} = getCoordsOfEdge(graph, edge)}
    <line
      x1={200 * x1}
      x2={200 * x2}
      y1={200 * y1}
      y2={200 * y2}
      class="edge"
      onclick={() => mode === "delete" && removeEdge(edge)}
    />
  {/each}
  {#each graph.layout as {x, y}, i}
    {@const color = colors[i]}
    <circle
      cx={200 * x}
      cy={200 * y}
      r={showLetters ? 8 : 4}
      style:fill={0 <= color && color <= 9 ? `var(--color-${color+1}` : "white"}
      class="vertex"
      onpointerdown={e => handlePointerDown(i, e)}
      onpointerup={e => handlePointerUp(i, e)}
      onclick={e => handleNodeClick(i, e)}
    />
  {/each}
  {#if showLetters}
    {#each graph.layout as {x, y}, i}
      <text
        x={200 * x}
        y={200 * y + 4}
        text-anchor="middle"
        class="text"
      >
        {alphabet[i]}
      </text>
    {/each}
  {/if}
  {#if mode == "adde" && selectedVertex !== null && pointerPosition !== null}
    {@const selectedPosition = graph.layout[selectedVertex]}
    <line
      x1={200 * selectedPosition.x}
      y1={200 * selectedPosition.y}
      x2={200 * pointerPosition.x}
      y2={200 * pointerPosition.y}
      class="edge"
      pointer-events="none"
    />
  {/if}
</svg>

<style>
  .vertex {
    stroke: var(--text);
    stroke-width: 1;
  }

  .edge {
    stroke: var(--blue-500);
    stroke-width: 1;
  }

  .text {
    font: bold 12px sans-serif;
    fill: var(--text);
    pointer-events: none;
    touch-action: none;
    user-select: none;
  }
</style>