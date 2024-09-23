import range from 'lodash.range';
import take from 'lodash.take';
import { Component, Show } from 'solid-js';
import { Algo, CustomAlgo, Result } from '../model';
import ResultView from './Result';

const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

type ConfigComponent = Component<{
  selectedAlgorithm: Algo,
  currentStep: number,
  results: Result[],
  selectedResultIndex: number,
  showLetters: boolean,
  setGraph: (idx: number) => void,
  setAlgo: (type: string) => void,
  setCustomOrdering: (type: string) => void,
  compute: () => void,
  previousStep: () => void,
  nextStep: () => void,
  finishColoring: () => void,
  setResultIndex: (idx: number) => void,
  saveGraph: () => void,
  openImportDialog: () => void,
  exportGraph: () => void,
}>

const Config: ConfigComponent = props => {
  const partialOrdering = () => {
    const result = props.results[props.selectedResultIndex];
    if (!result)
      return "";
    return take(result.coloring.map(c => alphabet[c.vertex]), props.currentStep).join("");
  }

  const algoOrdering = () =>
    (props.selectedAlgorithm as CustomAlgo).ordering.map(c => alphabet[c]).join("");

  return (
    <div class="flex flex-col">
      <span class="configtitle">Graphe</span>
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
      <div class="btngroup">
        <button class="btn rounded-l-md" onClick={props.saveGraph}>Sauvegarder</button>
        <button class="btn" onClick={props.openImportDialog}>Importer</button>
        <button class="btn rounded-r-md" onClick={props.exportGraph}>Exporter</button>
      </div>
      <span class="configtitle">Ordre</span>
      <select
        class="select"
        value={props.selectedAlgorithm.type}
        onChange={e => props.setAlgo(e.currentTarget.value)}
      >
        <option value="alpha">Alphabétique</option>
        <option value="decdegree">Degré décroissant</option>
        <option value="indset">Stables</option>
        <option value="dsatur">DSatur</option>
        <option value="custom">Personnalisé</option>
      </select>
      <Show when={props.selectedAlgorithm.type === "custom" && props.showLetters}>
        <input 
          class="textinput"
          value={algoOrdering()}
          onChange={e => props.setCustomOrdering(e.currentTarget.value)}
          type="text"
        />    
      </Show>
      <button class="btn" onClick={props.compute}>Choisir</button>
      <span class="configtitle">Résultats</span>
      <ul class="ml-4 list-disc">
        {range(0, 5).map(i => (
          <ResultView
            idx={i}
            result={props.results[i]}
            selected={props.selectedResultIndex == i}
            onClick={[props.setResultIndex, i]}
          />
        ))}
      </ul>
      <div class="btngroup">
        <button
          class="btn rounded-l-md"
          disabled={props.results.length === 0}
          onClick={props.previousStep}
        >
          Etape précédente
        </button>
        <button
          class="btn"
          disabled={props.results.length === 0}
          onClick={props.nextStep}
        >
          Etape suivante
        </button>
        <button
          class="btn rounded-r-md"
          disabled={props.results.length === 0}
          onClick={props.finishColoring}
        >
          Terminer la coloration
        </button>
      </div>
      <Show when={props.showLetters}>
        <span class="text-xl">{partialOrdering()}</span>
      </Show>
    </div>
  )
}

export default Config