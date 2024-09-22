import max from 'lodash.max';
import range from 'lodash.range';
import take from 'lodash.take';
import { createMemo, Component, batch } from 'solid-js';
import { createStore, produce } from "solid-js/store";
import Card from './Card';
import Config from './Config';
import GraphView from './GraphView';
import { Algo, initState, runBiasedColoring } from './model';
import { colors } from './colors';
import { nbVertices } from './graph';

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

  const compute = () => {
    const coloring = runBiasedColoring(state.selectedGraphIdx, graph(), state.selectedAlgorithm);
    if (coloring === undefined)
      return
    const res = {
      algorithm: state.selectedAlgorithm,
      coloring,
      nbColors: 1 + (max(coloring.map(c => c.color)) ?? -1),
      showNbColors: false
    }
    setState("results", results => take([res, ...results], 5))
  }

  const showNbColors = () => {
    if (state.currentStep === nbVertices(graph())) {
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

  const actions = {
    setGraph,
    setAlgo,
    compute,
    previousStep,
    nextStep,
    finishColoring,
  }

  // view
  return (
    <div class="flex flex-row justify-around items-start">
      <div class="p-6 bg-white border border-gray-200 rounded-lg shadow">
        <GraphView graph={graph()} colors={partialColoring()} />
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
      <Config state={state} {...actions} />
    </div>
  )
}

export default App;