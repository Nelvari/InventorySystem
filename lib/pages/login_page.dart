import 'package:flutter/material.dart';
import 'package:inventory_system/auth/auth_service.dart';
import 'package:inventory_system/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Get auth service
  final authService = AuthService();

  // text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Login button pressed
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // attempt login...
    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [

          // email
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),

          const SizedBox(height: 12,),

          // password
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: "Password"),
          ),

          const SizedBox(height: 12,),

          // button
          ElevatedButton(
            onPressed: login, 
            child: const Text("Login")
          ),

          const SizedBox(height: 12,),

          // Go to register
          GestureDetector(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
                )),
            child: const Center(child: Text("Don't have an account? Sign Up")),
          ),

        ],
      ),
    );
  }
}
