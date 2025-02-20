import 'package:curosync/doctor_screens/doctor_home_screen.dart';
import 'package:curosync/splash_screen.dart';
import 'package:curosync/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin_screens/admin_home_screeen.dart';

class DoctorLoginScreen extends StatefulWidget {
  @override
  _DoctorLoginScreenState createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found', message: 'User not found.');

      QuerySnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .where('Email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (doctorSnapshot.docs.isNotEmpty) {
        String phoneNumber = doctorSnapshot.docs.first.id;
        setPhone(phoneNumber);

        await FirebaseFirestore.instance.collection('Doctors').doc(phoneNumber).update({
          'LastLogin': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ));

        _saveUserRole("Doctor", phoneNumber);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoctorHomePage()),
        );
      } else {
        QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
            .collection('Admin')
            .where('Email', isEqualTo: _emailController.text.trim())
            .limit(1)
            .get();

        if (adminSnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Admin verified! Redirecting to Admin Page...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ));

          _saveUserRole("Admin", "");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomeScreeen()),
          );
        } else {
          throw FirebaseAuthException(code: 'user-not-found', message: 'No Doctor or Admin record found.');
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getErrorMessage(e.code)), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  String getErrorMessage(String errorCode) {
    Map<String, String> errors = {
      'user-not-found': "No account found with this email.",
      'wrong-password': "Incorrect password. Try again.",
      'invalid-email': "Invalid email format.",
      'user-disabled': "This account has been disabled.",
      'too-many-requests': "Too many failed attempts. Please try again later."
    };
    return errors[errorCode] ?? "Login failed. Please try again.";
  }

  Future<void> _saveUserRole(String role,String phno) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
    await prefs.setString('phno', phno);
  }


  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter your email to reset password"), backgroundColor: Colors.blue),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset link sent to your email"), backgroundColor: Colors.green),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Failed to send reset email"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Doctor Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  "Log in to manage your patients",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
                ),
                SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: Icon(Icons.email, color: Colors.white70),
                          ),
                          validator: (value) => value!.isEmpty ? 'Enter a valid email' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: Icon(Icons.lock, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Enter your password' : null,
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resetPassword,
                            child: Text("Forgot Password?", style: TextStyle(color: Colors.redAccent)),
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent[700],
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              "LOGIN",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context, MaterialPageRoute(builder: (context) => SplashScreen())),
                          child: Text("Back to select Role", style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
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
