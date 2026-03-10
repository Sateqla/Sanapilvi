<script lang="ts">
  import { goto } from '$app/navigation';
  import { supabase } from '$lib/supabase';
  import { env } from '$env/dynamic/public';
  import { onMount } from 'svelte';

  let creating = false;
  let errorMsg = '';
  let supabaseConnected = true;

  onMount(async () => {
    // Quick check to see if Supabase config is somewhat valid
    if (!env.PUBLIC_SUPABASE_URL || !env.PUBLIC_SUPABASE_ANON_KEY) {
      supabaseConnected = false;
    }
  });

  async function createSession() {
    if (!supabaseConnected) {
       errorMsg = "Supabase API keys are missing. Please add them to your .env file.";
       return;
    }

    creating = true;
    errorMsg = '';

    try {
      const { data, error } = await supabase
        .from('sessions')
        .insert([{}])
        .select()
        .single();

      if (error) throw error;
      
      if (data) {
        // Navigate to the newly created session securely
        goto(`/session/${data.id}`);
      }
    } catch (err: any) {
      console.error(err);
      errorMsg = err.message || 'Failed to create a session';
    } finally {
      creating = false;
    }
  }
</script>

<svelte:head>
  <title>Live Word Cloud - Create Session</title>
</svelte:head>

<div class="glass-panel" style="text-align: center; max-width: 600px;">
  <h1>Live Word Cloud</h1>
  <p style="margin-bottom: 2rem;">
    Create an interactive visual cloud on the fly. Gather spontaneous thoughts from your audience in real-time.
  </p>

  {#if !supabaseConnected}
    <div style="background: rgba(239, 68, 68, 0.1); border: 1px solid var(--error-color); padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; color: #fca5a5;">
      <strong>Configuration Missing:</strong> Supabase URL and Anon Key are missing. Copy <code>.env.example</code> to <code>.env</code> and fill in your project details.
    </div>
  {/if}

  <button class="btn-primary" on:click={createSession} disabled={creating || !supabaseConnected}>
    {#if creating}
      Creating Session...
    {:else}
      Start a New Session
    {/if}
  </button>
  
  {#if errorMsg}
    <p style="color: var(--error-color); margin-top: 1rem;">{errorMsg}</p>
  {/if}
</div>
