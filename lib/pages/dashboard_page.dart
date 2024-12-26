import 'package:flutter/material.dart';
import 'package:inventory_system/auth/auth_service.dart';
import 'package:inventory_system/components/dashboard_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // get authService
  final authService = AuthService();

  // logout button pressed
  void logout() async {
    await authService.SignOut();
  }

  Future<int> _getTotalProduct() async {
    try {
      final response = await Supabase.instance.client.from('product').select();
      if (response == null || response.isEmpty) {
        return 0;
      }
      return response.length;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    }
  }

  Future<int> _getTotalSupplier() async {
    try {
      final response = await Supabase.instance.client.from('supplier').select();
      if (response == null || response.isEmpty) {
        return 0;
      }
      return response.length;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data:\n ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dahboard"),
        actions: [
          // Logout button
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder<int>(
                    future: _getTotalProduct(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final totalProduct = snapshot.data ?? 0;
                      return DashboardCard(
                        title: 'Barang',
                        icon: Icons.inventory_sharp,
                        total: totalProduct,
                        onTap: () {
                          Navigator.pushNamed(context, '/barangList');
                        },
                      );
                    },
                  ),
                  FutureBuilder<int>(
                    future: _getTotalSupplier(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final totalSupplier = snapshot.data ?? 0;
                      return DashboardCard(
                        title: 'Supplier',
                        icon: Icons.store,
                        total: totalSupplier,
                        onTap: () {
                          Navigator.pushNamed(context, '/supplierList');
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }
}
