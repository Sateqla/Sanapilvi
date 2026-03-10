<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { supabase } from '$lib/supabase';
  import cloud from 'd3-cloud';

  export let sessionId: string;
  export let wordCount: number = 0;

  let container: HTMLDivElement;
  let wordsData: { text: string; size: number }[] = [];
  let cloudWords: any[] = [];
  let subscription: any;
  let layout: any;
  let scaleDimension = 1;

  // Track raw words to calculate frequencies
  let rawWords: string[] = [];
  
  $: wordCount = rawWords.length;

  function calculateFrequencies() {
    const counts: Record<string, number> = {};
    rawWords.forEach(w => {
      counts[w] = (counts[w] || 0) + 1;
    });

    // Map to array and scale sizes
    // Base size 20, max size heavily depends on freq
    wordsData = Object.entries(counts).map(([text, count]) => ({
      text,
      size: 20 + count * 15 // Scale factor
    }));

    updateCloud();
  }

  function updateCloud() {
    if (!container || wordsData.length === 0) return;
    
    const width = container.clientWidth;
    const height = container.clientHeight;

    layout = cloud()
      .size([width, height])
      .words(wordsData.map(d => ({...d}))) // Clone array so d3 can mutate it
      .padding(10) // Increase padding between words slightly
      .spiral('archimedean') // Use Archimedean spiral for dense, non-overlapping packing
      .rotate(() => 0) // Always horizontal
      .font('Outfit')
      .fontSize((d: any) => d.size)
      .on('end', (words: any[], bounds: any[]) => {
        cloudWords = words;
        
        // Calculate required scale to fit everything
        if (bounds && bounds.length === 2) {
          const cloudWidth = bounds[1].x - bounds[0].x;
          const cloudHeight = bounds[1].y - bounds[0].y;
          
          // Add a little padding to the calculation
          const scaleX = width / (cloudWidth + 20);
          const scaleY = height / (cloudHeight + 20);
          
          // Use the smaller scale so it fits both dimensions, max out at 1 so it doesn't blow up tiny clouds
          scaleDimension = Math.min(scaleX, scaleY, 1);
        }
      });

    layout.start();
  }

  onMount(() => {
    // 1. Initial fetch of existing words
    const fetchInitialData = async () => {
      const { data } = await supabase
        .from('words')
        .select('word')
        .eq('session_id', sessionId);
        
      if (data) {
        rawWords = data.map(d => d.word);
        calculateFrequencies();
      }
    };
    
    fetchInitialData();

    // Handle window resize
    const resizeObserver = new ResizeObserver(() => {
        updateCloud();
    });
    resizeObserver.observe(container);

    // 2. Subscribe to realtime inserts
    subscription = supabase
      .channel('public:words')
      .on('postgres_changes', { 
        event: 'INSERT', 
        schema: 'public', 
        table: 'words',
        filter: `session_id=eq.${sessionId}` 
      }, payload => {
        rawWords = [...rawWords, payload.new.word];
        calculateFrequencies();
      })
      .subscribe();
      
    return () => {
      resizeObserver.disconnect();
    };
  });

  onDestroy(() => {
    if (subscription) {
      supabase.removeChannel(subscription);
    }
  });
  
  // Custom color palette for the words to look beautiful
  const colors = ['#f472b6', '#a78bfa', '#38bdf8', '#34d399', '#fbbf24', '#f87171', '#e879f9'];
  
  function getColor(index: number) {
    return colors[index % colors.length];
  }
</script>

<div class="word-cloud-wrapper" bind:this={container}>
  {#if cloudWords.length > 0}
    <svg width="100%" height="100%">
      <g transform={`translate(${container?.clientWidth / 2}, ${container?.clientHeight / 2}) scale(${scaleDimension})`}>
        {#each cloudWords as word, i (word.text)}
          <text
            text-anchor="middle"
            transform={`translate(${word.x}, ${word.y}) rotate(${word.rotate})`}
            style="font-size: {word.size}px; fill: {getColor(i)}; transition: all 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);"
          >
            {word.text}
          </text>
        {/each}
      </g>
    </svg>
  {/if}
</div>

<style>
  .word-cloud-wrapper {
    width: 100%;
    height: 100%;
    min-height: 400px;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  text {
    font-weight: 800;
    text-shadow: 0px 4px 10px rgba(0,0,0,0.3);
    cursor: default;
  }
</style>
