import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  void registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'user',
        'registrationDateTime': DateTime.now().toIso8601String(),
      });

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Text(_error!, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: "First Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter first name' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter last name' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val != null && val.contains('@')
                    ? null
                    : 'Enter a valid email',
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (val) => val != null && val.length >= 6
                    ? null
                    : 'Password must be at least 6 characters',
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: registerUser,
                      child: Text("Register"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
