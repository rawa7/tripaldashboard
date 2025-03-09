import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripaldashboard/core/services/storage_service.dart';
import 'package:tripaldashboard/core/services/supabase_service.dart';

// Provider for the Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for the SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseService(supabaseClient);
});

// Provider for the StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return StorageService(supabaseClient);
}); 