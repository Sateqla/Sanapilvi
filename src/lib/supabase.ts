import { createClient } from '@supabase/supabase-js';

// We will use import.meta.env for SvelteKit environment variables (Vite)
// These need to be prefixed with VITE_ by default or loaded via SvelteKit's $env/static/public
import { env } from '$env/dynamic/public';

const supabaseUrl = env.PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = env.PUBLIC_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Returns the session's topic, or '' if it has none or loading fails.
export async function fetchSessionTopic(sessionId: string | undefined): Promise<string> {
  if (!sessionId) return '';

  const { data, error } = await supabase
    .from('sessions')
    .select('topic')
    .eq('id', sessionId)
    .maybeSingle();

  if (error) {
    console.error('Failed to load session topic', error);
    return '';
  }
  return typeof data?.topic === 'string' ? data.topic : '';
}
