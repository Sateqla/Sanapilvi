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
      
      successMsg = 'Sana lisätty pilveen!';
      word = ''; // Reset input
      
      setTimeout(() => {
        successMsg = '';
      }, 3000);
      
    } catch (err: any) {
      console.error(err);
      errorMsg = err.message || 'Sanan lähettäminen epäonnistui. Varmista, että tietokanta on käynnissä.';
    } finally {
      submitting = false;
    }
  }
</script>

<svelte:head>
  <title>Sanapilvi - Liity mukaan!</title>
</svelte:head>

<div class="join-container">
  <div class="glass-panel form-box">
    <h2>Lisää sana pilveen</h2>
    <p style="margin-bottom: 2rem;">Mitä on mielessäsi?</p>

    <form on:submit|preventDefault={submitWord} style="display: flex; flex-direction: column; gap: 1rem;">
      <input 
        type="text" 
        bind:value={word} 
        placeholder="Kirjoita sana..." 
        maxlength="30"
        required
        disabled={submitting}
      />
      
      <button type="submit" class="btn-primary" disabled={submitting || !word.trim()}>
        {#if submitting}
          Lähetetään...
        {:else}
          Lähetä sana sanapilveen
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
</div>

<style>
  .join-container {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1rem;
    background-color: var(--bg-gradient-start); /* default desktop background */
  }

  .form-box {
    width: 100%;
    max-width: 500px;
    text-align: center;
    /* margin: auto is no longer needed because of flexbox centering */
  }

  @media (max-width: 900px) {
    .join-container {
      background-color: var(--surface-color); /* JAMK Blue */
      align-items: center;
      padding: 2rem 1rem;
    }

    .form-box {
      padding: 1rem 0; /* Blend with the background */
    }
  }
</style>
