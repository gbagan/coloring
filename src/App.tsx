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

const App: Component = () => {
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
      state.selectedAlgorithm = {type: "alpha"};
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
      setState("selectedAlgorithm", {type: "custom", ordering });
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

  const configActions = {
    setGraph,
    setAlgo,
    setCustomOrdering,
    compute,
    previousStep,
    nextStep,
    finishColoring,
    setResultIndex,
  }

  const addVertex = (pos: Position) => {
    setState("graphs", state.selectedGraphIdx, g => G.addVertex(g, pos));
  }

  const moveVertex = (idx: number, pos: Position) => {
    //setState(produce(s => s.graphs[s.selectedGraphIdx].layout[idx] = pos))
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

  const graphViewActions = {
    addVertex,
    moveVertex,
    addEdge,
    removeVertex,
    removeEdge,
  }

  // view
  return (
    <div class="flex flex-row justify-around items-start">
      <div class="p-6 bg-white border border-gray-200 rounded-lg shadow">
        <GraphView
          graph={graph()}
          colors={partialColoring()}
          showLetters={nbVertices(graph()) <= 26}
          {...graphViewActions}
        />
      </div>
      <Card title="Ordre des couleurs">
        <div class="w-32">
          <svg viewBox="0 0 20 100">
            {range(0, 10).map(i =>
              <>
                <rect x="0" y={i * 10} width="10" height="10" class={colors[i]} />
                <text x="12" y={i * 10 + 8} class="graphtext">{i + 1}</text>
              </>
            )}
          </svg>
        </div>
      </Card>
      <Config state={state} showLetters={nbVertices(graph()) <= 26} {...configActions} />
    </div>
  )
}

export default App;