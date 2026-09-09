# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm run dev          # Start development server
npm run build        # Production build
npm run preview      # Preview production build
npm run check        # TypeScript/Svelte type checking
npm run check:watch  # Continuous type checking
```

## Architecture

**Sanapilvi** is a real-time collaborative word cloud app for live events. A presenter creates a session, participants submit words via a join link/QR code, and the word cloud updates live.

**Stack:** SvelteKit 2 (Svelte 5) + TypeScript, Supabase (PostgreSQL + Realtime), D3.js + d3-cloud, deployed on Vercel.

### Data Flow

1. Presenter hits `/` → creates `sessions` row in Supabase → redirected to `/session/[id]`
2. Presenter page shows QR code linking to `/join/[id]` and a live word cloud
3. Participants open `/join/[id]` → submit words → inserted into `words` table (uppercased)
4. `WordCloud.svelte` subscribes to Supabase Realtime (`postgres_changes` on `words`, filtered by `session_id`) → updates local `rawWords` array → recalculates frequencies → D3-cloud re-layouts SVG

### Routes

| Route | Purpose |
|---|---|
| `/` | Home — create new session |
| `/session/[id]` | Presenter view — word cloud + QR code + share link |
| `/join/[id]` | Participant view — word submission form |

No server-side routes — all data operations go through the Supabase client SDK in the browser.

### Key Component: `WordCloud.svelte`

- Subscribes to Supabase Realtime on mount, unsubscribes in `onDestroy`
- `calculateFrequencies()` counts word occurrences and maps to sized/colored visualization objects (size = `20 + count * 15`)
- D3-cloud layout uses Archimedean spiral, no rotation, 10px padding
- `ResizeObserver` triggers re-layout on container resize
- Colors cycle through brand palette (Pink, Yellow, Teal, White)

### Database (schema.sql)

- `sessions(id uuid PK, created_at)`
- `words(id uuid PK, session_id FK → sessions, word text, created_at)`
- RLS policies allow anonymous read/write — no auth required by design
- Optional pg_cron job in schema to purge sessions/words older than 2 months

### Environment Variables

```
PUBLIC_SUPABASE_URL=
PUBLIC_SUPABASE_ANON_KEY=
```

Loaded via SvelteKit's `$env/dynamic/public`. The home page shows an error if these are missing.

### Styling

- Global CSS custom properties in `app.css`: `--surface-color: #0D004C` (Navy), `--accent-color: #500257` (Magenta)
- Sofia Pro font (Adobe TypeKit) with Outfit (Google Fonts) as fallback
- Mobile breakpoint at 900px: desktop has a 350px fixed sidebar; mobile stacks vertically
