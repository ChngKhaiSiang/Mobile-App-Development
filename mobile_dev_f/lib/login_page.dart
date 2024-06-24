// lib/login_page.dart
import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'main_page.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'slide_page_route.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF203F81),
      appBar: AppBar(
        title: const Text('Login'), // Set app bar title
        backgroundColor: const Color(0xFFFFFFFF), // Set app bar background color
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),
                const LoginForm(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: const SignupPage()), // Use SlidePageRoute for navigation
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Sign up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _isFocused = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                border: Border.all(color: _isFocused ? Colors.blue : Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white24,
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.white24,
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              prefixIcon: Icon(Icons.lock, color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 80),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isPressed = true;
              });
              await Future.delayed(const Duration(milliseconds: 200));
              setState(() {
                _isPressed = false;
              });

              if (_formKey.currentState!.validate()) {
                String email = _emailController.text;
                String password = _passwordController.text;
                user_model? user = await DatabaseHelper.instance.getUserByEmail(email);
                if (user != null && user.password == password) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage(id: user.id)),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Invalid email or password';
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E4264),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
              elevation: 30, // Add shadow
              textStyle: const TextStyle(
                fontSize: 20,
                fontFamily: 'Roboto',
              ),
            ),
            child: AnimatedScale(
              scale: _isPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: const Text('Login'),
            ),
          ),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
