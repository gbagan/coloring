<script lang="ts">
  import type { Algo, Result } from "../lib/model";
  import ResultView from "./Result.svelte";

  const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  type Props = {
    selectedAlgorithm: Algo;
    currentStep: number;
    results: Result[];
    selectedResultIndex: number;
    showLetters: boolean;
    setGraph: (idx: number) => void;
    setAlgo: (type: string) => void;
    setCustomOrdering: (type: string) => void;
    compute: () => void;
    previousStep: () => void;
    nextStep: () => void;
    finishColoring: () => void;
    setResultIndex: (idx: number) => void;
    saveGraph: () => void;
    openImportDialog: () => void;
    exportGraph: () => void;
  }

  let { selectedAlgorithm, currentStep, results, selectedResultIndex, showLetters,
    setGraph, setAlgo, setCustomOrdering, compute, previousStep, nextStep, finishColoring,
    setResultIndex, saveGraph, openImportDialog, exportGraph
  }: Props = $props();

  let partialOrdering = $derived.by(() => {
    const result = results[selectedResultIndex]
    return !result
      ? ""
      : result.coloring.map(c => ALPHABET[c.vertex]).slice(0, currentStep).join("")
  });
</script>

<div class="container">
  <h2>Graphe</h2>
  <select class="select"
    value="0"
    onchange={e => setGraph(Number(e.currentTarget.value))}
  >
    <option value="0">Cygne</option>
    <option value="1">Confluence</option>
    <option value="2">Lapin</option>
    <option value="3">Poisson</option>
    <option value="4">Gros graphe</option>
    <option value="5">Graphe personnalisé 1</option>
    <option value="6">Graphe personnalisé 2</option>
    <option value="7">Graphe personnalisé 3</option>
  </select>
  <div class="btngroup">
    <button class="btn left" onclick={saveGraph}>Sauvegarder</button>
    <button class="btn" onclick={openImportDialog}>Importer</button>
    <button class="btn right" onclick={exportGraph}>Exporter</button>
  </div>
  <h2>Ordre</h2>
  <select
    class="select"
    value={selectedAlgorithm.type}
    onchange={e => setAlgo(e.currentTarget.value)}
  >
    <option value="alpha">Alphabétique</option>
    <option value="decdegree">Degré décroissant</option>
    <option value="indset">Stables</option>
    <option value="dsatur">DSatur</option>
    <option value="custom">Personnalisé</option>
  </select>
  {#if selectedAlgorithm.type === "custom" && showLetters}
    <input
      type="text"
      class="input-text"
      value={selectedAlgorithm.ordering.map(v => ALPHABET[v]).join("")}
      onchange={e => setCustomOrdering(e.currentTarget.value)}
    />
  {/if}
  <button class="btn" onclick={compute}>Choisir</button>
  <h2>Résultats</h2>
  <ul>
    {#each [0, 1, 2, 3, 4] as i}
      <ResultView
        result={results[i]}
        selected={selectedResultIndex === i}
        onclick={() => setResultIndex(i)}
      />
    {/each}
  </ul>
  <div class="btngroup">
    <button
      class="btn left"
      disabled={results.length === 0}
      onclick={previousStep}
    >
      Etape précédente
    </button>
    <button
      class="btn"
      disabled={results.length === 0}
      onclick={nextStep}
    >
      Etape suivante
    </button>
    <button
      class="btn right"
      disabled={results.length === 0}
      onclick={finishColoring}
    >
      Terminer la coloration
    </button>
  </div>
  {#if showLetters}
    <span class="text-xl">{partialOrdering}</span>
  {/if}
</div>

<style>
  .container {
    display: flex;
    flex-direction: column;
  }

  h2 {
    margin-bottom: 0.5rem;
    margin-top: 1rem;
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--text);
  }
</style>