import 'package:supabase_flutter/supabase_flutter.dart';

/// Fill these in with your actual CoinVision Supabase project values
/// (Project Settings → API). The anon/public key is safe to ship in the
/// client — it's constrained entirely by the RLS policies we built.
class SupabaseConfig {
  static const String projectUrl = 'https://aljdqfcokyzciefxptfj.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsamRxZmNva3l6Y2llZnhwdGZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYxOTkwNTQsImV4cCI6MjEwMTc3NTA1NH0.pn2715_cP3xR087gH1ZlhPh14SnRCGJWzHpCrZWBfSs';

  static Future<void> init() async {
    await Supabase.initialize(url: projectUrl, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
