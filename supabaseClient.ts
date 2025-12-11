import { createClient } from '@supabase/supabase-js';

// Configuration for Supabase
// We prioritize environment variables, but fallback to the provided hardcoded values to prevent crashes.
const supabaseUrl = process.env.REACT_APP_SUPABASE_URL || 'https://mvlvspbaqfugsofwmmnz.supabase.co';
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY || 'sb_publishable_gsFbhLI2lM1Ap8RlN4zoDA_jAwLh0B-'; 

// Validation
if (!supabaseUrl || !supabaseAnonKey) {
  console.error("Supabase credentials missing. Please check your configuration.");
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);