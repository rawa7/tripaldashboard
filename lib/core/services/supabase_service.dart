import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient;
  
  SupabaseService(this._supabaseClient);
  
  // Get the supabase client instance
  SupabaseClient get client => _supabaseClient;
  
  // Initialize Supabase
  static Future<SupabaseClient> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
    // Get Supabase URL and anon key from .env file
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase credentials not found in .env file');
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    return Supabase.instance.client;
  }
  
  // Generic fetch method with pagination
  Future<List<Map<String, dynamic>>> fetchRecords({
    required String table,
    int page = 1,
    int limit = 10,
    String? orderBy,
    bool ascending = false,
    Map<String, dynamic>? filters,
  }) async {
    // We'll use a simple approach here - fetch all records and then
    // manually apply filtering, sorting, and pagination
    final query = _supabaseClient.from(table).select();
    final response = await query;
    
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(response);
    
    // Apply filters if provided
    if (filters != null && filters.isNotEmpty) {
      result = result.where((record) {
        bool match = true;
        filters.forEach((key, value) {
          if (record[key] != value) {
            match = false;
          }
        });
        return match;
      }).toList();
    }
    
    // Sort the results
    if (orderBy != null) {
      result.sort((a, b) {
        dynamic valueA = a[orderBy];
        dynamic valueB = b[orderBy];
        
        if (valueA == null && valueB == null) return 0;
        if (valueA == null) return ascending ? -1 : 1;
        if (valueB == null) return ascending ? 1 : -1;
        
        int comparison;
        if (valueA is String && valueB is String) {
          comparison = valueA.compareTo(valueB);
        } else if (valueA is num && valueB is num) {
          comparison = valueA.compareTo(valueB);
        } else if (valueA is DateTime && valueB is DateTime) {
          comparison = valueA.compareTo(valueB);
        } else {
          // Default to string comparison
          comparison = valueA.toString().compareTo(valueB.toString());
        }
        
        return ascending ? comparison : -comparison;
      });
    }
    
    // Apply pagination
    final startIndex = (page - 1) * limit;
    if (startIndex >= result.length) {
      return [];
    }
    
    final endIndex = (startIndex + limit) > result.length ? result.length : (startIndex + limit);
    return result.sublist(startIndex, endIndex);
  }
  
  // Insert a record
  Future<Map<String, dynamic>> insertRecord({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final response = await _supabaseClient.from(table).insert(data).select();
    return response.first;
  }
  
  // Get a record by ID
  Future<Map<String, dynamic>?> getRecordById({
    required String table,
    required String id,
  }) async {
    final response = await _supabaseClient.from(table).select().eq('id', id);
    
    if (response.isEmpty) {
      return null;
    }
    
    return response.first;
  }
  
  // Update a record
  Future<Map<String, dynamic>> updateRecord({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _supabaseClient
      .from(table)
      .update(data)
      .eq('id', id)
      .select();
      
    return response.first;
  }
  
  // Delete a record
  Future<void> deleteRecord({
    required String table,
    required String id,
  }) async {
    await _supabaseClient.from(table).delete().eq('id', id);
  }
} 