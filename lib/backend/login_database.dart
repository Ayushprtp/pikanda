import 'package:supabase_flutter/supabase_flutter.dart';

class LoginDatabase {
  final database = Supabase.instance.client;
}

final fetchadminaccess =
    LoginDatabase().database
        .from('profile')
        .select('access_code')
        .eq('username', 'ayushprtp')
        .single();

Future<String?> fetchAccessCodeByUsername(String username) async {
  // Initialize the Supabase client
  final SupabaseClient supabase = Supabase.instance.client;

  try {
    // Query the profile table to fetch the access_code using the username
    final response =
        await supabase
            .from('profile') // Table name
            .select('access_code') // Column to fetch
            .eq('username', username) // Filter by username
            .single(); // Fetch only one row

    // Check if the response contains data
    if (response == null || response['access_code'] == null) {
      print('No record found for the given username.');
      return null;
    }

    // Extract the access_code
    final String? accessCode = response['access_code'];
    return accessCode;
  } catch (error) {
    print('Error fetching access code: $error');
    return null;
  }
}

const String username = "ayushprtp";

final Future<String?> accessCode = fetchAccessCodeByUsername(username);

Future<List> readData() async {
  final fetchadminaccess = await LoginDatabase().database
      .from('profile')
      .select('access_code')
      .eq('username ', 'pika');
  return fetchadminaccess;
}
