import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String phoneNumber = _phoneController.text.trim();

      if (phoneNumber.isEmpty) {
        throw FirebaseAuthException(code: 'invalid-phone', message: 'Phone number is required.');
      }

      String normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (normalizedPhone.length == 12 && normalizedPhone.startsWith('91')) {
        normalizedPhone = normalizedPhone.substring(2); // Remove country code if it's +91
      }

      if (normalizedPhone.length != 10) {
        throw FirebaseAuthException(code: 'invalid-phone', message: 'Invalid phone number.');
      }

      var existingUser1 = await FirebaseFirestore.instance.collection('Users').doc(normalizedPhone).get();
      var existingUser2 = await FirebaseFirestore.instance.collection('Users').doc('+91$normalizedPhone').get();

      if (existingUser1.exists || existingUser2.exists) {
        throw FirebaseAuthException(code: 'phone-number-in-use', message: 'Phone number is already registered.');
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user?.sendEmailVerification();

      await FirebaseFirestore.instance.collection('Users').doc(normalizedPhone).set({
        'Email': _emailController.text.trim(),
        'PhoneNumber': normalizedPhone,
        'Pass': _passwordController.text.trim(),
        'CreatedAt': FieldValue.serverTimestamp(),
      }).then((value) {
        print("User saved to Firestore successfully!");
      }).catchError((error) {
        print("Failed to save user to Firestore: $error");
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Successful! Check your email for verification.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false); // Stop progress indicator

      String message = "Registration failed. Please try again.";
      if (e.code == 'email-already-in-use') {
        message = "Email is already registered. Try logging in.";
        _emailController.clear();
      } else if (e.code == 'weak-password') {
        message = "Password too weak. Use uppercase, number, and symbol.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      } else if (e.code == 'phone-number-in-use') {
        message = "Phone number is already registered.";
        _phoneController.clear();
      } else if (e.code == 'invalid-phone') {
        message = "Please enter a valid phone number.";
      } else {
        message = e.message ?? "Unknown error occurred.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => _isLoading = false);
  }


  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Enter your phone number';

    String cleanedNumber = value.replaceAll(RegExp(r'[^0-9+]'), '');

    if (RegExp(r'^[6789]\d{9}$').hasMatch(cleanedNumber)) {
      return null;
    }

    if (RegExp(r'^\+\d{11,15}$').hasMatch(cleanedNumber)) {
      return null;
    }
    return 'Enter a valid phone number';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(),hintText: 'e.g. example@gmail.com',),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. +919876543210 or 9876543210',
                  ),
                  validator: _validatePhoneNumber,
                ),

                SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter a password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$').hasMatch(value)) {
                      return 'Use uppercase, number, and special character';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                SizedBox(height: 24),

                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register, // Disable button when loading
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text("Register"),
                  ),
                ),

                SizedBox(height: 16),

                // Login Link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: Text("Already have an account? Login"),
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
