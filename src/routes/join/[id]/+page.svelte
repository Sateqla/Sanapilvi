<script lang="ts">
  import { page } from '$app/stores';
  import { supabase } from '$lib/supabase';

  let word = '';
  let submitting = false;
  let errorMsg = '';
  let successMsg = '';

  const sessionId = $page.params.id;

  async function submitWord() {
    if (!word.trim() || submitting) return;

    submitting = true;
    errorMsg = '';
    successMsg = '';

    try {
      // Normalize word (e.g. lowercase and trim)
      const normalizedWord = word.trim().toUpperCase();

      const { error } = await supabase
        .from('words')
        .insert([{ session_id: sessionId, word: normalizedWord }]);

      if (error) throw error;
      
      successMsg = 'Added successfully!';
      word = ''; // Reset input
      
      setTimeout(() => {
        successMsg = '';
      }, 3000);
      
    } catch (err: any) {
      console.error(err);
      errorMsg = err.message || 'Failed to submit word. Make sure the database is running.';
    } finally {
      submitting = false;
    }
  }
</script>

<svelte:head>
  <title>Join Live Cloud</title>
</svelte:head>

<div class="glass-panel" style="width: 100%; max-width: 500px; text-align: center;">
  <h2>Submit a Word</h2>
  <p style="margin-bottom: 2rem;">What's on your mind?</p>

  <form on:submit|preventDefault={submitWord} style="display: flex; flex-direction: column; gap: 1rem;">
    <input 
      type="text" 
      bind:value={word} 
      placeholder="Type a word..." 
      maxlength="30"
      required
      disabled={submitting}
    />
    
    <button type="submit" class="btn-primary" disabled={submitting || !word.trim()}>
      {#if submitting}
        Submitting...
      {:else}
        Send to Cloud
      {/if}
    </button>
  </form>

  {#if errorMsg}
    <p style="color: var(--error-color); margin-top: 1rem;">{errorMsg}</p>
  {/if}
  {#if successMsg}
    <p style="color: #4ade80; margin-top: 1rem; font-weight: 600;">{successMsg}</p>
  {/if}
</div>
