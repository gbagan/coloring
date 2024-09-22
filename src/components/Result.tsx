import { Component, Show } from "solid-js"
import { Algo, orderingToString, Result } from "../model"

function algoName(algo: Algo): string {
  switch (algo.type) {
    case "alpha": return "Ordre alphabétique";
    case "decdegree": return "Degré décroissant";
    case "indset": return "Stables";
    case "dsatur": return "DSatur";
    case "custom": return orderingToString(algo.ordering);
  }
}

type ResultComponent = Component<{
  idx: number,
  result: Result | null
  selected: boolean,
  onClick: () => void,
}>

const ResultView: ResultComponent = props =>
  <Show when={props.result} fallback={<li></li>}>
    <li classList={{ "text-blue-600": props.selected }} onClick={props.onClick}>
      {algoName(props.result!.algorithm)}
      {props.result!.showNbColors && " (" + props.result!.nbColors + " couleurs)"}
    </li>
  </Show>

export default ResultView;