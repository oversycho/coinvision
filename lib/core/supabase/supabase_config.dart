import 'package:supabase_flutter/supabase_flutter.dart';

/// Fill these in with your actual CoinVision Supabase project values
/// (Project Settings → API). The anon/public key is safe to ship in the
/// client — it's constrained entirely by the RLS policies we built.
class SupabaseConfig {
  static const String projectUrl = 'https://aljdqfcokyzciefxptfj.supabase.co';
  static const String anonKey = 'PASTE_YOUR_ANON_PUBLIC_KEY_HERE';

  static Future<void> init() async {
    await Supabase.initialize(url: projectUrl, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
