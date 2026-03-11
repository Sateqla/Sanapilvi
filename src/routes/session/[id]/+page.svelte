<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import QRCode from 'qrcode';
  
  import WordCloud from '$lib/components/WordCloud.svelte';

  const sessionId = $page.params.id;
  
  let qrCodeDataUrl = '';
  let joinUrl = '';
  let wordCount = 0;
  let copySuccess = false;

  async function copyLink() {
    try {
      await navigator.clipboard.writeText(joinUrl);
      copySuccess = true;
      setTimeout(() => {
        copySuccess = false;
      }, 2000);
    } catch (err) {
      console.error('Failed to copy', err);
    }
  }

  onMount(async () => {
    // Determine the full join URL based on the current origin
    joinUrl = `${window.location.origin}/join/${sessionId}`;
    
    try {
      // Generate QR Code containing the joinUrl
      qrCodeDataUrl = await QRCode.toDataURL(joinUrl, {
        width: 300,
        margin: 2,
        color: {
          dark: '#000000', // Black QR Code
          light: '#ffffff'  // White background
        }
      });
    } catch (err) {
      console.error("Error generating QR code", err);
    }
  });

</script>

<svelte:head>
  <title>Sanapilvi - Esittäjän näkymä</title>
</svelte:head>

<div class="session-header">
  <img src="/jamk-logo.svg" alt="JAMK Logo" class="brand-logo" />
  <h2>Sanapilvi</h2>
</div>

<div class="presenter-layout">
  <!-- Word Cloud Section -->
  <div class="cloud-container glass-panel">
      {#if wordCount === 0}
        <p class="waiting-text">Odotellaan sanoja pilveen...</p>
      {/if}
      
      {#if sessionId}
        <WordCloud {sessionId} bind:wordCount />
      {/if}
  </div>

  <!-- Sidebar: QR Code and Instructions -->
  <aside class="sidebar glass-panel">
    <h3>Liity mukaan!</h3>
    <p>Skannaa QR-koodi tai klikkaa linkkiä osallistuaksesi.</p>
    
    {#if qrCodeDataUrl}
      <div class="qr-container">
        <img src={qrCodeDataUrl} alt="QR Code to join word cloud" />
      </div>
    {/if}
    
    <div class="link-box">
      <button class="copy-button" onclick={copyLink} aria-label="Kopioi osallistumislinkki">
        <i class="fa-solid {copySuccess ? 'fa-check' : 'fa-copy'}"></i>
        <span>{copySuccess ? 'Kopioitu!' : 'Kopioi osallistumislinkki'}</span>
      </button>
      <a href={joinUrl} target="_blank" rel="noopener noreferrer">({joinUrl})</a>
    </div>
  </aside>
</div>

<style>
  .presenter-layout {
    display: flex;
    gap: 0; /* Remove gap so they sit directly next to each other */
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
    /* JAMK Blue vertical gradient */
    background: linear-gradient(180deg, #10054F 0%, #332682 100%) !important;
  }

  .session-header {
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    width: 100%;
    background-color: #0D014D; /* JAMK Tolopea Navy */
    padding: 2.5rem 0; /* Add padding so the background is visible around text */
    margin: 0; /* Remove margin-bottom to connect seamlessly with containers below if needed */
  }

  .brand-logo {
    position: absolute;
    left: 4rem;
    top: 50%;
    transform: translateY(-50%);
    height: 45px; /* Adjust size based on visual proportions */
    width: auto;
  }

  .session-header h2 {
    font-size: 2.5rem;
    margin: 0;
    color: #ffffff; /* White text */
  }

  .waiting-text {
    position: absolute;
    color: #ffffff;
    font-size: 2rem;
    text-align: center;
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
    background-color: #e2066f !important; /* JAMK Pink background */
    color: #ffffff !important; /* White text */
  }

  .sidebar h3, .sidebar p {
    color: #ffffff !important; /* Override default heading/text color */
  }

  .sidebar h3 {
    color: var(--accent-hover);
    font-size: 2rem;
    font-weight: bold;
  }

  .qr-container {
    background: white;
    padding: 10px;
    border-radius: 0;
    box-shadow: 0 5px 15px -3px rgba(0, 0, 0, 0.1);
  }

  .qr-container img {
    display: block;
    width: 100%;
    height: auto;
    border-radius: 4px;
  }

  .link-box {
    background: #0d004c; /* JAMK Blue background for link */
    padding: 1.5rem 1rem;
    border-radius: 0;
    width: 100%;
    word-break: break-all;
    border: none;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.5rem;
  }

  .copy-button {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    background: none;
    border: none;
    color: #ffffff;
    font-size: 1rem;
    font-weight: 600;
    font-family: inherit;
    cursor: pointer;
    padding: 0.25rem;
    margin-bottom: 0.5rem;
    transition: opacity 0.2s;
  }

  .copy-button:hover {
    opacity: 0.8;
  }

  .copy-button i {
    font-size: 1.1rem;
  }

  .link-box a {
    color: #ffffff; /* White text on blue background */
    text-decoration: none;
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
