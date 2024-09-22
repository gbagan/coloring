import range from 'lodash.range';
import take from 'lodash.take';
import { Component, Show } from 'solid-js';
import { Algo, Result, State } from './model';

const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

function algoName(algo: Algo): string {
  switch(algo.type) {
    case "alpha": return "Ordre alphabétique";
    case "decdegree": return "Degré décroissant";
    case "indset": return "Stables";
    case "dsatur": return "DSatur";
    case "custom": return "Personnalisé";
  }
} 

type ConfigComponent = Component<{
  state: State,
  setGraph: (idx: number) => void,
  setAlgo: (type: string) => void,
  compute: () => void,
  previousStep: () => void,
  nextStep: () => void,
  finishColoring: () => void,
}>

const Config: ConfigComponent = props => {
  const partialOrdering = () => {
    const result = props.state.results[props.state.selectedResultIndex];
    if (result === undefined)
      return "";
    return take(result.coloring.map(c => alphabet[c.vertex]), props.state.currentStep).join("");
  }

  return (
    <div class="flex flex-col">
      <span class="mb-2 mt-4 text-2xl font-bold">Graphe</span>
      <select class="select"
        value="0"
        onChange={e => props.setGraph(Number(e.currentTarget.value))}
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
      <div>
        <button class="btn rounded-l">Sauvegarder</button>
        <button class="btn">Importer</button>
        <button class="btn rounded-r">Exporter</button>
      </div>
      <span class="mb-2 mt-4 text-2xl font-bold">Ordre</span>
      <select
        class="select"
        value={props.state.selectedAlgorithm.type}
        onChange={e => props.setAlgo(e.currentTarget.value)}
      >
        <option value="alpha">Alphabétique</option>
        <option value="decdegree">Degré décroissant</option>
        <option value="indset">Stables</option>
        <option value="dsatur">DSatur</option>
        <option value="custom">Personnalisé</option>
      </select>
      <button class="btn" onClick={props.compute}>Choisir</button>
      <span class="mb-2 mt-4 text-2xl font-bold">Résultats</span>
      <ul class="ml-4 list-disc">
        {range(0, 5).map(i => (
          <ResultView
            idx={i}
            result={props.state.results[i]}
            selected={props.state.selectedResultIndex == i}
          />
        ))}
      </ul>
      <div>
        <button class="btn rounded-l" onClick={props.previousStep}>Etape précédente</button>
        <button class="btn" onClick={props.nextStep}>Etape suivanter</button>
        <button class="btn rounded-r" onClick={props.finishColoring}> Termine la coloration</button>
      </div>
      <Show when={true}>
        <span class="text-xl">{partialOrdering()}</span>
      </Show>
    </div>
  )
}

type ResultComponent = Component<{
  idx: number,
  result: Result | undefined
  selected: boolean,
}>

const ResultView: ResultComponent = props =>
  <Show when={props.result} fallback={<li></li>}>
    <li classList={{"text-blue-600": props.selected}}>
      {algoName(props.result!.algorithm)}
      {props.result!.showNbColors && " (" + props.result!.nbColors + " couleurs)"}
    </li>
  </Show>

export default Config