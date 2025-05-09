import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginDatabase {
  final database = Supabase.instance.client;
}

final adminresponse =
    LoginDatabase().database
        .from('profile') // Replace with your table name
        .select('access_code') // Replace with the column name for access code
        .eq('username', 'ayushprtp') // Filter by the provided username
        .single();
final String? fetchadminaccess = adminresponse.toString();
