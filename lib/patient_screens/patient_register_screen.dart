import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curosync/patient_screens/patient_login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientRegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 80, color: Colors.white),
              SizedBox(height: 10),

              Text(
                "Create Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                "Join us today for a better health experience!",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(controller: _emailController, label: "Email", icon: Icons.email, inputType: TextInputType.emailAddress),
                    SizedBox(height: 15),
                    _buildTextField(controller: _phoneController, label: "Phone Number", icon: Icons.phone, inputType: TextInputType.phone),
                    SizedBox(height: 15),
                    _buildTextField(controller: _passwordController, label: "Password", icon: Icons.lock, isPassword: true),
                    SizedBox(height: 15),
                    _buildTextField(controller: _confirmPasswordController, label: "Confirm Password", icon: Icons.lock_reset, isPassword: true),
                    SizedBox(height: 25),

                    _buildButton(text: "REGISTER", onPressed: _isLoading ? null : _register),
                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PatientLoginScreen()),
                        );
                      },
                      child: Text("Already have an account? Login", style: TextStyle(color: Colors.white70, fontSize: 14, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Input Field
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType inputType = TextInputType.text, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword ? (label == "Password" ? _obscurePassword : _obscureConfirmPassword) : false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.blueGrey[800],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(label == "Password" ? (_obscurePassword ? Icons.visibility : Icons.visibility_off) : (_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off), color: Colors.white70),
          onPressed: () {
            setState(() {
              if (label == "Password") {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (label == "Email" && !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) return 'Enter a valid email';
        if (label == "Phone Number" && !RegExp(r'^[6789]\d{9}$').hasMatch(value)) return 'Enter a valid phone number';
        if (label == "Password" && value.length < 6) return 'Password must be at least 6 characters';
        if (label == "Confirm Password" && value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  // Reusable Button
  Widget _buildButton({required String text, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.tealAccent[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String normalizedPhone = _phoneController.text.trim();

      await _firestore.collection('Users').doc(normalizedPhone).set({
        'Pass': _passwordController.text.trim(),
        'Email': _emailController.text.trim(),
        'PhoneNumber': normalizedPhone,
        'CreatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Successful!', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );
      MaterialPageRoute(builder: (context) => PatientLoginScreen());
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      if (e.code == 'email-already-in-use') {
        errorMsg = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        errorMsg = "Password should be at least 6 characters.";
      } else {
        errorMsg = "Registration failed: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

}
