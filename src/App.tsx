import max from 'lodash.max';
import range from 'lodash.range';
import take from 'lodash.take';
import { createMemo, Component, batch } from 'solid-js';
import { createStore, produce } from "solid-js/store";
import Card from './components/Card';
import Config from './components/Config';
import GraphView from './components/GraphView';
import { Algo, initState, isValidOrdering, runBiasedColoring, stringToOrdering } from './model';
import { colors } from './colors';
import { Edge, nbVertices, Position } from './graph';
import * as G from './graph';
import toast, { Toaster } from 'solid-toast';

const App: Component = () => {
  let importDialog: HTMLDialogElement;

  const [state, setState] = createStore(initState);

  const graph = () => state.graphs[state.selectedGraphIdx];

  const partialColoring = createMemo(() => {
    const g = graph();
    const n = g.layout.length;
    const colors: number[] = new Array(n);
    colors.fill(-1);
    const coloring = state.results[state.selectedResultIndex]?.coloring ?? [];
    let m = Math.min(coloring.length, state.currentStep);
    for (let i = 0; i < m; i++) {
      colors[coloring[i].vertex] = coloring[i].color;
    }
    return colors
  })

  const setGraph = (idx: number) => {
    setState(produce(state => {
      state.selectedGraphIdx = idx;
      state.results = [];
      state.selectedAlgorithm = { type: "alpha" };
      state.selectedResultIndex = 0;
      state.currentStep = 0;
    }))
  }

  const setAlgo = (type: string) => {
    setState(produce(state => {
      state.currentStep = 0;
      state.selectedAlgorithm =
        type === "custom"
          ? { type: "custom", ordering: range(0, graph().layout.length) }
          : { type } as Algo
    }))
  }

  const setCustomOrdering = (text: string) => {
    const ordering = stringToOrdering(text);
    if (ordering !== null) {
      setState("selectedAlgorithm", { type: "custom", ordering });
    }
  }

  const compute = () => {
    const algo = state.selectedAlgorithm;
    if (algo.type === "custom" && !isValidOrdering(algo.ordering)) {
      return
    }
    const coloring = runBiasedColoring(state.selectedGraphIdx, graph(), state.selectedAlgorithm);
    if (coloring === null)
      return
    const res = {
      algorithm: state.selectedAlgorithm,
      coloring,
      nbColors: 1 + (max(coloring.map(c => c.color)) ?? -1),
      showNbColors: false
    }
    batch(() => {
      setState("results", results => take([res, ...results], 5));
      setState("selectedResultIndex", 0);
      setState("currentStep", 0);
    });
  }

  const showNbColors = () => {
    if (state.currentStep === nbVertices(graph()) && state.results.length > 0) {
      setState("results", state.selectedResultIndex, "showNbColors", true);
    }
  }

  const previousStep = () => {
    setState("currentStep", step => Math.max(0, step - 1))
  }

  const nextStep = () => {
    batch(() => {
      setState("currentStep", step => Math.min(nbVertices(graph()), step + 1))
      showNbColors();
    })
  }

  const finishColoring = () => {
    batch(() => {
      setState("currentStep", nbVertices(graph()));
      showNbColors();
    })
  }

  const setResultIndex = (idx: number) => {
    setState(produce(state => {
      state.selectedResultIndex = idx;
      if (state.results[idx].showNbColors) {
        state.currentStep = nbVertices(graph());
      } else {
        state.currentStep = 0;
      }
    }))
  }

  const saveGraph = () => {
    const idx = state.selectedGraphIdx;
    if (idx < 5) {
      return;
    }
    const json = JSON.stringify(graph());
    window.localStorage.setItem(`coloring-graph-${idx}`, json);
    toast.success("Le graphe a été sauvegardé sur votre machine");
  }

  const openImportDialog = () => {
    navigator.clipboard
      .readText()
      .then(text => {
        setState("dialogContent", text);
      }).catch(() => {
        setState("dialogContent", "");
      }).finally(() => {
        importDialog.showModal();
      })
  }

  const importGraph = () => {
    const json = state.dialogContent;
    const graph = G.jsonToGraph(json);
    if (graph === null) {
      toast.error("Le texte que vous avez entré ne représente pas un graph valide");
    } else {
      setState("graphs", state.selectedGraphIdx, graph);
    }
    importDialog.close();
  }

  const exportGraph = () => {
    navigator.clipboard.writeText(JSON.stringify(graph()));
    toast.success("Le graphe a été copié dans le presse-papier");
  }

  const configActions = {
    setGraph,
    setAlgo,
    setCustomOrdering,
    compute,
    previousStep,
    nextStep,
    finishColoring,
    setResultIndex,
    saveGraph,
    openImportDialog,
    exportGraph,
  }

  const addVertex = (pos: Position) => {
    setState("graphs", state.selectedGraphIdx, g => G.addVertex(g, pos));
  }

  const moveVertex = (idx: number, pos: Position) => {
    setState("graphs", state.selectedGraphIdx, "layout", idx, pos);
  }

  const addEdge = (u: number, v: number) => {
    setState("graphs", state.selectedGraphIdx, g => G.addEdge(g, u, v));
  }

  const removeVertex = (idx: number) => {
    setState("graphs", state.selectedGraphIdx, g => G.removeVertex(g, idx));
  }

  const removeEdge = (edge: Edge) => {
    setState("graphs", state.selectedGraphIdx, g => G.removeEdge(g, edge));
  }

  const clearGraph = () => {
    setState("graphs", state.selectedGraphIdx, { layout: [], edges: [] });
  }

  const reinitGraph = () => {
    setState("graphs", state.selectedGraphIdx, G.genGraph(state.selectedGraphIdx));
  }


  const graphViewActions = {
    addVertex,
    moveVertex,
    addEdge,
    removeVertex,
    removeEdge,
    clearGraph,
    reinitGraph,
  }

  // view
  return (
    <div class="flex flex-row justify-around items-start">
      <Toaster position="top-right" />
      <div class="p-6 bg-white border border-gray-200 rounded-lg shadow">
        <GraphView
          graph={graph()}
          colors={partialColoring()}
          showLetters={nbVertices(graph()) <= 26}
          {...graphViewActions}
        />
      </div>
      <Card title="Ordre des couleurs">
        <div class="w-16 xl-w-24 2xl-w-32">
          <svg viewBox="0 0 40 200">
            {colors.map((color, i) =>
              <>
                <rect x="0" y={i * 20} width="20" height="20" class={color} />
                <text x="24" y={i * 20 + 16} class="graphtext">{i + 1}</text>
              </>
            )}
          </svg>
        </div>
      </Card>
      <Config
        selectedAlgorithm={state.selectedAlgorithm}
        currentStep={state.currentStep}
        results={state.results}
        selectedResultIndex={state.selectedResultIndex}
        showLetters={nbVertices(graph()) <= 26}
        {...configActions}
      />
      <dialog ref={el => (importDialog = el)} class="dialog">
        <div class="dialogtitle">Importer un graphe</div>
        <div class="p-6 border-b-2" >
          <textarea
            class="textarea"
            cols="100"
            rows="20"
            onChange={e => setState("dialogContent", e.currentTarget.value)}
          >
            {state.dialogContent}
          </textarea>
        </div>
        <div class="p-4 text-right">
          <button class="btn rounded-md" onClick={() => importDialog.close()}>Annuler</button>
          <button class="btn rounded-md" autofocus onClick={importGraph}>OK</button>
        </div>
      </dialog>
    </div>
  )
}

export default App;