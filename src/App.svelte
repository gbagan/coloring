<script lang="ts">
  import { arrayOf, range } from '@gbagan/utils';
  import toast, {Toaster} from 'svelte-5-french-toast'
  import { type Mode } from "./types";
  import GraphView from "./components/Graph.svelte";
  import { addEdge, addVertex, emptyGraph, initialGraphs, jsonToGraph,
    moveVertex, nbVertices, removeEdge, removeVertex } from "./lib/graph";
  import Config from "./components/Config.svelte";
  import { tick } from 'svelte';
  import { isValidOrdering, runBiasedColoring, stringToOrdering, type Algo, type Result } from './lib/model';
  import Card from './components/Card.svelte';

  let graphs = $state.raw(initialGraphs);
  let graphIndex = $state(0);
  let graph = $derived(graphs[graphIndex]);
  let mode = $state<Mode>("move");
  let dialogContent = $state("");
  let selectedAlgorithm = $state.raw<Algo>({ type: "alpha" });
  let results: Result[] = $state([]);
  let selectedResultIndex = $state(0);
  let currentStep = $state(0);
 
  let dialogEl!: HTMLDialogElement;
  let importTextArea: HTMLTextAreaElement | undefined = $state();  

  let partialColoring = $derived.by(() => {
    const g = graph;
    const colors = arrayOf(g.layout.length, -1);
    const coloring = results[selectedResultIndex]?.coloring ?? [];
    const m = Math.min(coloring.length, currentStep)
    for (let i = 0; i < m; i++) {
      colors[coloring[i].vertex] = coloring[i].color;
    }
    return colors;
  });

  function setGraph(idx: number) {
    graphIndex = idx;
    results = [];
    selectedAlgorithm = { type: "alpha" };
    selectedResultIndex = 0;
    currentStep = 0;
  }

  function setAlgo(type: string) {
    currentStep = 0;
    selectedAlgorithm =
      type === "custom"
      ? { type: "custom", ordering: range(0, graph.layout.length) }
      : { type: type } as Algo
  }

  function setCustomOrdering(text: string) {
    const ordering = stringToOrdering(text);
    if (ordering !== null) {
      selectedAlgorithm = { type: "custom", ordering };
    }
  }

  function compute() {
    const algo = selectedAlgorithm;
    if (algo.type === "custom" && !isValidOrdering(algo.ordering)) {
      return
    }
    const coloring = runBiasedColoring(graphIndex, graph, selectedAlgorithm);
    if (coloring === null) return;
    const res = {
      algorithm: algo,
      coloring,
      nbColors: 1 + (Math.max(...coloring.map(c => c.color)) ?? -1),
      showNbColors: false
    }
    results = [res, ...results].slice(0, 5);
    selectedResultIndex = 0;
    currentStep = 0;
  }

  function showNbColors() {
    if (currentStep === nbVertices(graph) && results.length > 0) {
      results[selectedResultIndex].showNbColors = true;
    }
  }

  function previousStep() {
    currentStep = Math.max(0, currentStep - 1);
  }

  function nextStep() {
    currentStep = Math.min(nbVertices(graph), currentStep + 1);
    showNbColors();
  }

  function finishColoring() {
    currentStep = nbVertices(graph);
    showNbColors();
  }

  function setResultIndex(idx: number) {
    selectedResultIndex = idx
    if (results[idx].showNbColors) {
      currentStep = nbVertices(graph);
    } else {
      currentStep = 0;
    }
  }
  
  function saveGraph() {
    if (graphIndex < 5) return;
    const json = JSON.stringify(graph);
    window.localStorage.setItem(`coloring-graph-${graphIndex}`, json);
    toast.success("Le graphe a été sauvegardé sur votre machine");
  }

  function importGraph() {
    const g = jsonToGraph(dialogContent);
    if (g === null) {
      toast.error("Le texte que vous avez entré ne représente pas un graphe valide");
    } else {
      graphs = graphs.with(graphIndex, g);
      results = [];
      selectedAlgorithm = { type: "alpha" };
      selectedResultIndex = 0;
      currentStep = 0;
    }
    dialogEl.close();
  }

  function openImportDialog() {
    navigator.clipboard
      .readText()
      .then((text) => dialogContent = text)
      .catch(() => dialogContent = "")
      .finally(async () => {
        dialogEl.showModal();
        await tick();
        importTextArea?.focus();
      })
  }

  function exportGraph() {
    navigator.clipboard.writeText(JSON.stringify(graph));
    toast.success("Le graphe a été copié dans le presse-papier");
  }
</script>

<div class="container">
  <div class="main-container">
    <div class="graph-container">
      <GraphView 
        {graph}
        {mode}
        colors={partialColoring}
        showLetters={nbVertices(graph) <= 26}
        addVertex={pos => graphs = graphs.with(graphIndex, addVertex(graph, pos))}
        moveVertex={(idx, pos) => graphs = graphs.with(graphIndex, moveVertex(graph, idx, pos))}
        addEdge={(u, v) => graphs = graphs.with(graphIndex, addEdge(graph, u, v))}
        removeVertex={(idx) => graphs = graphs.with(graphIndex, removeVertex(graph, idx))}
        removeEdge={(edge) => graphs = graphs.with(graphIndex, removeEdge(graph, edge))}
      />
    </div>
    <div class="btngroup">
      <button
        class={["btn left", { active: mode === "move" }]}
        onclick={() => mode = "move"}
      >
        <span class="check">✓</span> Déplacer
      </button>
      <button
        class={["btn", { active: mode === "addv" }]}
        onclick={() => mode = "addv"}
      >
        <span class="check">✓</span> Ajouter sommet
      </button>
      <button
        class={["btn", { active: mode === "adde" }]}
        onclick={() => mode = "adde"}
      >
        <span class="check">✓</span> Ajouter arête
      </button>
      <button
        class={["btn", { active: mode === "delete" }]}
        onclick={() => mode = "delete"}
      >
        <span class="check">✓</span> Retirer
      </button>
      <button
        class="btn"
        onclick={() => graphs = graphs.with(graphIndex, emptyGraph())}
      >
        Tout effacer
      </button>
      <button
        class="btn right"
        onclick={() => graphs = graphs.with(graphIndex, initialGraphs[graphIndex])}
      >
        Réinitialiser
      </button>
    </div>
  </div>
  <Card title="Ordre des couleurs">
    <div class="colors">
      <svg viewBox="0 0 40 200">
        {#each range(0, 10) as i}
          <rect x="0" y={i * 20} width="20" height="20" style:fill="var(--color-{i+1})" />
          <text x="24" y={i * 20 + 16} class="color-text">{i + 1}</text>
        {/each}
      </svg>
    </div>
  </Card>
  <Config
    {selectedAlgorithm}
    {currentStep}
    {results}
    {selectedResultIndex}
    showLetters={nbVertices(graph) <= 26}
    {setGraph}
    {setAlgo}
    {setCustomOrdering}
    {compute}
    {previousStep}
    {nextStep}
    {finishColoring}
    {setResultIndex}
    {saveGraph}
    {openImportDialog}
    {exportGraph}
  />
</div>
<dialog bind:this={dialogEl}>
  <div class="dialog-title">Importer un graphe</div>
  <div class="dialog-body" >
    <textarea
      class="textarea"
      cols="100"
      rows="20"
      bind:this={importTextArea}
      bind:value={dialogContent}
    ></textarea>
  </div>
  <div class="dialog-buttons">
    <button class="btn rounded-lg" onclick={() => dialogEl.close()}>Annuler</button>
    <button class="btn rounded-lg" onclick={importGraph}>OK</button>
  </div>
</dialog>
<Toaster />

<style>
  .container {
    display: flex;
    justify-content: space-around;
  }

  .main-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
    border: 1px solid var(--border);
    padding: 1.5rem;
    background-color: #ffffff;
    border-radius: 0.5rem;
    box-shadow: var(--shadow-md);
  }

  .graph-container {
    width: 40rem;
    touch-action: none;
  }

  .colors {
    width: 8rem;
  }

  dialog {
    position: fixed;
    left: 50%;
    top: 50%;
    transform: translateX(-50%) translateY(-50%);
    border: none;
    background-color: #ffffff;
    border-radius: 0.5rem;
    box-shadow: var(--shadow-lg);
  }

  dialog::backdrop {
    background-color: rgb(107 114 128 / 0.7);
  }

  .dialog-title {
    margin: 0;
    padding: 1rem;
    min-height: 2rem;
    border-bottom: 2px solid var(--gray-200);
    font-size: 2.25rem;
    font-weight: 500;
  }

  .dialog-body {
    margin: 0;
    padding: 1.5rem;
    border-bottom: 2px solid var(--gray-200);
  }

  .dialog-buttons {
    padding: 1rem;
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
  }

  .color-text {
    font: bold 12px sans-serif;
    fill: var(--text);
    pointer-events: none;
    touch-action: none;
    user-select: none;
  }
</style>