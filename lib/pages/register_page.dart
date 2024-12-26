import 'package:flutter/material.dart';
import 'package:inventory_system/auth/auth_service.dart';
import 'package:inventory_system/components/styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Get auth service
  final authService = AuthService();

  // text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Signin button pressed
  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // check that password is match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }

    // attempt signUp...
    try {
      await authService.signUpWithEmailPassword(email, password);

      // pop this register page
      Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [

          // email
          InputLayout(
            'Email', 
            TextFormField(
              controller: _emailController,
              decoration: customInputDecoration("Email"),
            ),
          ),

          const SizedBox(height: 6,),

          // password
          InputLayout(
            'Password',
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: customInputDecoration("Password"),
            ),
          ),

          const SizedBox(height: 6,),

          // confirm password
          InputLayout(
            'Confirm Password',
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: customInputDecoration("Confirm Password"),
            ),
          ),

          const SizedBox(height: 12,),

          // button
          ElevatedButton(
            onPressed: signUp, 
            child: const Text("Sign In")
          ),

        ],
      ),
    );
  }
}
