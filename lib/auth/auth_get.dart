import 'package:flutter/material.dart';
import 'package:inventory_system/pages/dashboard_page.dart';
import 'package:inventory_system/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGet extends StatelessWidget {
  const AuthGet({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // Listen to auth state change
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Loading...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // if there is a valid session curently
          final session = snapshot.hasData ? snapshot.data!.session : null;

          if (session != null) {
            return const DashboardPage();
          } else {
            return const LoginPage();
          }

        });
  }
}
