<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import QRCode from 'qrcode';
  
  import WordCloud from '$lib/components/WordCloud.svelte';

  const sessionId = $page.params.id;
  
  let qrCodeDataUrl = '';
  let joinUrl = '';
  let wordCount = 0;

  onMount(async () => {
    // Determine the full join URL based on the current origin
    joinUrl = `${window.location.origin}/join/${sessionId}`;
    
    try {
      // Generate QR Code containing the joinUrl
      qrCodeDataUrl = await QRCode.toDataURL(joinUrl, {
        width: 300,
        margin: 2,
        color: {
          dark: '#1e1b4b', // Dark purple module color
          light: '#ffffff'  // White background
        }
      });
    } catch (err) {
      console.error("Error generating QR code", err);
    }
  });

</script>

<svelte:head>
  <title>Live Session - Presenter View</title>
</svelte:head>

<div class="session-header">
  <h2>Live Word Cloud</h2>
</div>

<div class="presenter-layout">
  <!-- Word Cloud Section -->
  <div class="cloud-container glass-panel">
      {#if wordCount === 0}
        <p class="waiting-text">Waiting for words to the cloud...</p>
      {/if}
      
      {#if sessionId}
        <WordCloud {sessionId} bind:wordCount />
      {/if}
  </div>

  <!-- Sidebar: QR Code and Instructions -->
  <aside class="sidebar glass-panel">
    <h3>Join the Session!</h3>
    <p>Scan the code or go to the link to participate.</p>
    
    {#if qrCodeDataUrl}
      <div class="qr-container">
        <img src={qrCodeDataUrl} alt="QR Code to join word cloud" />
      </div>
    {/if}
    
    <div class="link-box">
      <a href={joinUrl} target="_blank" rel="noopener noreferrer">{joinUrl}</a>
    </div>
  </aside>
</div>

<style>
  .presenter-layout {
    display: flex;
    gap: 2rem;
    width: 100%;
    flex: 1; /* Take up remaining height */
    min-height: 0; /* Important for flex children to allow scrolling/resizing properly */
  }

  .cloud-container {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: relative;
    overflow: hidden;
  }

  .session-header {
    text-align: center;
    margin-bottom: 2rem;
    width: 100%;
  }

  .session-header h2 {
    font-size: 2.5rem;
    margin: 0;
    color: var(--text-primary);
  }

  .waiting-text {
    position: absolute;
    color: var(--text-secondary);
    z-index: 10;
    pointer-events: none;
  }

  .sidebar {
    width: 350px;
    flex-shrink: 0; /* Prevent the sidebar from shrinking */
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 1.5rem;
  }

  .sidebar h3 {
    color: var(--accent-hover);
  }

  .qr-container {
    background: white;
    padding: 10px;
    border-radius: 12px;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.3);
  }

  .qr-container img {
    display: block;
    width: 100%;
    height: auto;
    border-radius: 4px;
  }

  .link-box {
    background: rgba(0,0,0,0.3);
    padding: 1rem;
    border-radius: 8px;
    width: 100%;
    word-break: break-all;
    border: 1px solid var(--surface-border);
  }

  .link-box a {
    color: #38bdf8;
    text-decoration: none;
    font-weight: 600;
  }
  
  .link-box a:hover {
    text-decoration: underline;
  }

  @media (max-width: 900px) {
    .presenter-layout {
      flex-direction: column;
      height: auto;
    }
    .sidebar {
      width: 100%;
      flex-direction: row;
      flex-wrap: wrap;
      justify-content: center;
    }
    .cloud-container {
      min-height: 50vh;
    }
  }
</style>
