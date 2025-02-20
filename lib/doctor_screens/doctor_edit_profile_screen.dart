import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  final String userId;

  const EditDoctorProfileScreen({super.key, required this.userId});

  @override
  _EditDoctorProfileScreenState createState() => _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  late TextEditingController _specializationController;
  late TextEditingController _hospitalName;

  String? _gender;
  String? _bloodGroup;
  bool _isLoading = false;

  final List<String> _genders = ["Male", "Female", "Other"];
  final List<String> _bloodGroups = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    var userDoc = await FirebaseFirestore.instance.collection('Doctors').doc(widget.userId).get();
    if (userDoc.exists) {
      var data = userDoc.data()!;
      setState(() {
        _nameController = TextEditingController(text: data['Name']);
        _ageController = TextEditingController(text: data['Age']);
        _addressController = TextEditingController(text: data['Address']);
        _specializationController = TextEditingController(text: data['Specialization']);
        _hospitalName = TextEditingController(text: data['Hospital']);
        _gender = data['Gender'];
        _bloodGroup = data['BloodGroup'];
      });
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Map<String, dynamic> updatedData = {
      "Name": _nameController.text,
      "Age": _ageController.text,
      "Gender": _gender,
      "BloodGroup": _bloodGroup,
      "Address": _addressController.text,
      "Specialization": _specializationController.text,
      "Hospital": _hospitalName.text,
    };

    await FirebaseFirestore.instance.collection('Doctors').doc(widget.userId).update(updatedData);

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[700],
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfilePicture(),
                  const SizedBox(height: 20),
                  _buildSection("Personal Details", [
                    _buildTextField(_nameController, "Full Name", Icons.person),
                    _buildNumberField(_ageController, "Age", Icons.cake),
                    _buildDropdownField("Gender", _gender, _genders, (value) => setState(() => _gender = value), Icons.male),
                    _buildDropdownField("Blood Group", _bloodGroup, _bloodGroups, (value) => setState(() => _bloodGroup = value), Icons.bloodtype),
                  ]),
                  _buildSection("Contact Information", [
                    _buildTextField(_addressController, "Address", Icons.home),
                  ]),
                  _buildSection("Medication Information", [
                    _buildTextField(_specializationController, "Specialization", Icons.medical_services),
                    _buildTextField(_hospitalName, "Hospital Name", Icons.local_hospital),
                  ]),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.blueGrey[600],
            backgroundImage: const AssetImage("assets/logo.jpeg"),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "DOCTOR",
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      color: Colors.blueGrey[800],
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, IconData icon) {
    return _buildTextField(controller, label, icon);
  }

  Widget _buildDropdownField(String label, String? value, List<String> options, Function(String?) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField(
        decoration: _inputDecoration(label, icon),
        dropdownColor: Colors.blueGrey[800],
        value: value,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Required" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.tealAccent),
      filled: true,
      fillColor: Colors.blueGrey[700],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _updateUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
        icon: const Icon(Icons.save, color: Colors.white, size: 24),
        label: const Text("Save Changes", style: TextStyle(color: Colors.white)),
      ),
    );
  }


}
