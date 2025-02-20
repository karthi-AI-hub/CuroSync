import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curosync/admin_screens/admin_home_screeen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorRegisterScreen extends StatefulWidget {
  @override
  _DoctorRegisterScreenState createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
              Icon(Icons.medical_services, size: 80, color: Colors.white),
              SizedBox(height: 10),

              Text(
                "Doctor Registration",
                style: TextStyle(fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                "Join us today and manage your patients efficiently!",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(controller: _nameController,
                        label: "Full Name",
                        icon: Icons.person),
                    SizedBox(height: 15),
                    _buildTextField(controller: _emailController,
                        label: "Email",
                        icon: Icons.email,
                        inputType: TextInputType.emailAddress),
                    SizedBox(height: 15),
                    _buildTextField(controller: _phoneController,
                        label: "Phone Number",
                        icon: Icons.phone,
                        inputType: TextInputType.phone),
                    SizedBox(height: 15),
                    _buildTextField(controller: _specializationController,
                        label: "Specialization",
                        icon: Icons.medical_services),
                    SizedBox(height: 15),
                    _buildTextField(controller: _passwordController,
                        label: "Password",
                        icon: Icons.lock,
                        isPassword: true),
                    SizedBox(height: 15),
                    _buildTextField(controller: _confirmPasswordController,
                        label: "Confirm Password",
                        icon: Icons.lock_reset,
                        isPassword: true),
                    SizedBox(height: 25),

                    _buildButton(text: "REGISTER",
                        onPressed: _isLoading ? null : _register),
                    SizedBox(height: 20),
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
  Widget _buildTextField(
      {required TextEditingController controller, required String label, required IconData icon, TextInputType inputType = TextInputType
          .text, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword ? (label == "Password"
          ? _obscurePassword
          : _obscureConfirmPassword) : false,
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
          icon: Icon(
              label == "Password" ? (_obscurePassword ? Icons.visibility : Icons
                  .visibility_off) : (_obscureConfirmPassword
                  ? Icons.visibility
                  : Icons.visibility_off), color: Colors.white70),
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
        if (label == "Email" &&
            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value)) return 'Enter a valid email';
        if (label == "Phone Number" &&
            !RegExp(r'^[6789]\d{9}$').hasMatch(value))
          return 'Enter a valid phone number';
        if (label == "Password" && value.length < 6)
          return 'Password must be at least 6 characters';
        if (label == "Confirm Password" && value != _passwordController.text)
          return 'Passwords do not match';
        return null;
      },
    );
  }

  // Reusable Button
  Widget _buildButton(
      {required String text, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.tealAccent[700],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(text, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("No admin user is currently logged in.");

      String adminEmail = currentUser.email!;

      QuerySnapshot adminQuery = await _firestore
          .collection('Admin')
          .where('Email', isEqualTo: adminEmail)
          .limit(1)
          .get();

      String hospital = adminQuery.docs.isNotEmpty ? adminQuery.docs.first['Hospital'] ?? "Unknown" : "Unknown";

      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String normalizedPhone = _phoneController.text.trim();
      print(normalizedPhone);
      await _firestore.collection('Doctors').doc(normalizedPhone).set({
        'Name': _nameController.text.trim(),
        'Email': _emailController.text.trim(),
        'PhoneNumber': normalizedPhone,
        'Specialization': _specializationController.text.trim(),
        'Hospital': hospital,
        'CreatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful!', textAlign: TextAlign.center), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminHomeScreeen()));

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auth Error: ${e.message}"), backgroundColor: Colors.red),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firestore Error: ${e.message}"), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unknown Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

}