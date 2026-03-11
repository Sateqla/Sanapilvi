# Sanapilvi (Live Word Cloud)

A real-time, visual word cloud application built with SvelteKit, Supabase, and D3.js.

## Features

- **Session Management**: Create and store distinct word cloud sessions.
- **Easy Participation**: Allow users to add words to sessions via direct sharing links or QR codes—zero login required.
- **Real-Time Visualization**: Display a visually appealing word cloud that updates live as new words are submitted, dynamically scaling word sizes and adjusting positions based on submission frequency.
- **Automated Cleanup (Optional)**: Can be configured with `pg_cron` to automatically delete sessions and words older than 2 months to keep the database tidy.

## Database Requirement

**⚠️ Important**: By default, this project is configured to use **[Supabase](https://supabase.com/)** as its backend database.

It leverages Supabase for:
- Connecting to a PostgreSQL database for storing sessions and words.
- Utilizing **Supabase Realtime** via Postgres publications to listen for and instantly broadcast new word additions to the client.
- Handling Row Level Security (RLS) to ensure basic limits for anonymous read/write access.

Please refer to `schema.sql` for the exact table structures, RLS policies, and realtime publication configurations needed for your Supabase project.

---

## Developing

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

```sh
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```sh
npm run build
```

You can preview the production build with `npm run preview`.
