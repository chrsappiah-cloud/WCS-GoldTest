import Foundation

/// Supabase Swift SDK integration point — phase 2.
/// Configure via xcconfig: SUPABASE_URL, SUPABASE_ANON_KEY
enum SupabaseClientProvider {
    static func makeClient(configuration: AppConfiguration) -> Any? {
        guard configuration.supabaseURL != nil,
              configuration.supabaseAnonKey != nil else {
            return nil
        }
        // return SupabaseClient(supabaseURL: url, supabaseKey: key)
        return nil
    }
}
