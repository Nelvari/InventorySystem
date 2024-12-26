
import 'package:flutter/material.dart';
import 'package:inventory_system/auth/auth_get.dart';
import 'package:inventory_system/pages/barang/barang_page.dart';
import 'package:inventory_system/pages/dashboard_page.dart';
import 'package:inventory_system/pages/login_page.dart';
import 'package:inventory_system/pages/register_page.dart';
import 'package:inventory_system/pages/supplier/supplier_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pyevhmddlaqnfyitoiux.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5ZXZobWRkbGFxbmZ5aXRvaXV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg4OTI2NjUsImV4cCI6MjA0NDQ2ODY2NX0.S8aYv_mTB_8mPd4DnaKhTtWsuqzEr2-TUcomVNF8VHE',
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'Inventaris',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGet(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/barangList': (context) => const BarangPage(),
        '/supplierList': (context) => const SupplierPage(),
      },
    );
  }
}