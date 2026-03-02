class SupabaseConfig {
  // Prefer compile-time env, but fall back to your project values so the
  // app works out of the box in development.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://phxazbsbnglpjnauhxah.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBoeGF6YnNibmdscGpuYXVoeGFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzNjYwNDQsImV4cCI6MjA4Nzk0MjA0NH0.7mrMb6OnPIiShYZqOexiRcWbeLghAKtdncVhbIVRyA8',
  );

  const SupabaseConfig._();
}
