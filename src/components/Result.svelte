<script lang="ts">
    import { orderingToString, type Algo, type Result } from "../lib/model";

  function algoName(algo: Algo) {
    switch(algo.type) {
      case "alpha": return "Ordre alphabétique";
      case "decdegree": return "Degré décroissant";
      case "indset": return "Stables";
      case "dsatur": return "DSatur";
      case "custom": return orderingToString((algo as any).ordering);
    }
  }

  type Props = {
    result: Result | undefined;
    selected: boolean;
    onclick: () => void;
  }

  let { result, selected, onclick }: Props = $props();
</script>

{#if !result}
  <li></li>
{:else}
  <li
    class={{ selected }}
  >
    <button {onclick}>
      {algoName(result.algorithm)}
      {#if result.showNbColors}
         &nbsp;({result.nbColors} couleurs)
      {/if}
    </button>    
  </li>
{/if}

<style>
  button {
    color: inherit;
    font-size: 1rem;
    cursor: pointer;
  }

  .selected {
    color: var(--blue-600);
  }
</style>