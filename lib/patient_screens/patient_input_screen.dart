import 'package:curosync/patient_screens/patient_home_screen.dart';
import 'package:curosync/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputScreen extends StatefulWidget {
  final String userId;

  const InputScreen({super.key, required this.userId});

  @override
  InputScreenState createState() => InputScreenState();
}

class InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _eme1Controller = TextEditingController();
  final TextEditingController _eme2Controller = TextEditingController();
  final TextEditingController _eme3Controller = TextEditingController();

  String? _gender;
  String? _bloodGroup;
  List<String> _hospitalNames = [];
  final List<String> _genders = ["Male", "Female", "Other"];
  final List<String> _bloodGroups = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

  bool _isLoading = false;

  void _fetchHospitalNames() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
        'Admin').get();

    setState(() {
      _hospitalNames =
          querySnapshot.docs.map((doc) => doc['Hospital'] as String).toList();
    });
  }
  @override
  void initState() {
    super.initState();
    _fetchHospitalNames();
  }

  Future<void> _savePatientData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> patientData = {
      "Name": _nameController.text,
      "Age": _ageController.text,
      "Gender": _gender,
      "BloodGroup": _bloodGroup,
      "Address": _addressController.text,
      "Disease": _diseaseController.text,
      "Hospital": _medicationsController.text,
      "Eme1": _eme1Controller.text,
      "Eme2": _eme2Controller.text,
      "Eme3": _eme3Controller.text,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phno = prefs.getString('phno');

    await FirebaseFirestore.instance.collection('Users').doc(phno).set(patientData);

    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PatientHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.health_and_safety, size: 80, color: Colors.tealAccent),
                const SizedBox(height: 15),
                Text("Complete Your Profile",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 5),
                Text("Help us know you better!",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 30),

                _buildSectionTitle("Personal Details"),
                _buildTextField(_nameController, "Full Name", Icons.person),
                _buildNumberField(_ageController, "Age", Icons.cake),
                _buildDropdownField("Gender", _gender, _genders, (value) => setState(() => _gender = value), Icons.male),
                _buildDropdownField("Blood Group", _bloodGroup, _bloodGroups, (value) => setState(() => _bloodGroup = value), Icons.bloodtype),

                const SizedBox(height: 20),
                _buildSectionTitle("Contact Information"),
                _buildTextField(_addressController, "Address", Icons.home),

                const SizedBox(height: 20),
                _buildSectionTitle("Medical Information"),
                _buildTextField(_diseaseController, "Disease Contition", Icons.medical_services),
                _buildHospitalDropdown(),

                const SizedBox(height: 20),
                _buildSectionTitle("Emergency Contacts"),
                _buildNumberField(_eme1Controller, "Emergency Contact 1", Icons.emergency_rounded),
                _buildNumberField(_eme2Controller, "Emergency Contact 2", Icons.emergency_rounded),
                _buildNumberField(_eme3Controller, "Emergency Contact 3", Icons.emergency_rounded),

                const SizedBox(height: 30),
                const SizedBox(height: 30),
                _buildButton("SUBMIT", _savePatientData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
      ),
    );
  }

  // Text Field Widget
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  // Number Field Widget
  Widget _buildNumberField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  // Dropdown Field Widget
  Widget _buildDropdownField(String label, String? value, List<String> options, Function(String?) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField(
        dropdownColor: Colors.blueGrey[800],
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        value: value,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Required" : null,
      ),
    );
  }

  // Reusable Input Decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.tealAccent),
      filled: true,
      fillColor: Colors.blueGrey[800],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Modern Button
  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.tealAccent[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildHospitalDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: _inputDecoration("Select Hospital", Icons.local_hospital),
        dropdownColor: Colors.blueGrey[800],
        value: _medicationsController.text.isNotEmpty ? _medicationsController.text : null,
        items: _hospitalNames.map((hospital) {
          return DropdownMenuItem<String>(
            value: hospital,
            child: Text(
              hospital,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _medicationsController.text = newValue ?? '';
          });
        },
        validator: (value) => value == null || value.isEmpty ? 'Please select a hospital' : null,
      ),
    );
  }

}
