export type Role = 'admin' | 'member';

export interface Profile {
  id: string; // Internal UUID
  user_id?: string; // Link to Auth User
  email: string;
  full_name: string;
  role: Role;
  phone?: string;
  address?: string; // ... rest is same
  birth_date?: string;
  baptism_date?: string;
  marital_status?: string;
  ministry_role?: string;
  photo_url?: string;
  internal_notes?: string; // Admin only
  created_at: string;
}

export interface Service {
  id: string;
  title: string;
  day_of_week: string; // e.g., 'Domingo'
  time: string; // e.g., '19:00'
  description?: string;
}

export interface ChurchEvent {
  id: string;
  title: string;
  event_type?: string; // e.g., 'casamento', 'vigília'
  start_time: string;
  end_time?: string;
  location?: string;
  responsible?: string;
  description?: string;
}

export interface NewsItem {
  id: string;
  title: string;
  content: string;
  image_url?: string;
  published_at: string;
  created_at: string;
}

export interface VideoItem {
  id: string;
  title: string;
  youtube_id: string;
  description?: string;
  published_at: string;
  created_at: string;
}

export interface FinanceRecord {
  id: string;
  type: 'income' | 'expense';
  category: string;
  amount: number;
  description?: string;
  date: string;
  member_id?: string; // Optional link to member
  created_at: string;
}

// Bible API Types
export interface BibleBook {
  abbrev: { pt: string };
  author: string;
  chapters: number;
  group: string;
  name: string;
  testament: string;
}

export interface BibleChapter {
  book: BibleBook;
  chapter: { number: number; verses: number };
  verses: { number: number; text: string }[];
}
