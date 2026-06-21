import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://pifrzzpmqjqbuijuqozq.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_1WdaLqVzEcj1WNIbMuIrIQ_RJc4Upw9';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
