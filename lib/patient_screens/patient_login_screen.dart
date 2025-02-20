import 'package:curosync/patient_screens/patient_home_screen.dart';
import 'package:curosync/patient_screens/patient_register_screen.dart';
import 'package:curosync/splash_screen.dart';
import 'package:curosync/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curosync/patient_screens/patient_input_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientLoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<PatientLoginScreen> with SingleTickerProviderStateMixin {
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

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User record not found in records.');
      }

      String phoneNumber = querySnapshot.docs.first.id;
      setPhone(phoneNumber);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(phoneNumber).get();
      var userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null || !userData.containsKey('Name') || userData['Name'].toString().trim().isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InputScreen(userId: user.uid)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientHomePage()),
        );
      }

      await FirebaseFirestore.instance.collection('Users').doc(phoneNumber).update({
        'LastLogin': FieldValue.serverTimestamp(),
      });

      _saveUserRole("Patient", phoneNumber);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login Successful!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));

    } on FirebaseAuthException catch (e) {
      String message = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      } else if (e.code == 'user-disabled') {
        message = "Your account has been disabled. Contact support.";
      } else if (e.code == 'too-many-requests') {
        message = "Too many failed attempts. Try again later.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveUserRole(String role, String phno) async {
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
                  "Welcome Back!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  "Log in to continue",
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
                        Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SplashScreen()),
                                );
                              },
                              child: Text(
                                "Back to select Role",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PatientRegisterScreen()),
                                );
                              },
                              child: Text(
                                "Don't have an account? Register",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),

                          ],
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
