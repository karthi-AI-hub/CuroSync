import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:curosync/utils/values.dart';

class SOSManager {
  final BuildContext context;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = getPhone();
  SOSManager(this.context);

  Future<void> decisionSOS() async {
    _showLoadingDialog();
    try {
      DocumentSnapshot userDocument = await _firestore.collection('Users').doc(userId).get();
      Navigator.of(context, rootNavigator: true).pop();

      if (userDocument.exists && userDocument.data() != null) {
        Map<String, dynamic> data = userDocument.data() as Map<String, dynamic>;
        String? eme1 = data['Eme1'];
        String? eme2 = data['Eme2'];
        String? eme3 = data['Eme3'];

        if (eme1 != null && eme2 != null && eme3 != null) {
          showSOSDialog(eme1, eme2, eme3);
        } else {
          showEmergencyContactDialog();
        }
      } else {
        showEmergencyContactDialog();
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print("Error getting user document: $e");
    }
  }

  void showSOSDialog(String eme1, String eme2, String eme3) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Emergency Contacts", style: TextStyle(color: Colors.tealAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSOSButton("Call Contact 1", eme1),
              _buildSOSButton("Call Contact 2", eme2),
              _buildSOSButton("Call Contact 3", eme3),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.tealAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                showEditEmergencyContactsDialog();
              },
              child: const Text("Edit", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void showEditEmergencyContactsDialog() {
    TextEditingController eme1Controller = TextEditingController();
    TextEditingController eme2Controller = TextEditingController();
    TextEditingController eme3Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Edit Emergency Contacts", style: TextStyle(color: Colors.tealAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(eme1Controller, "New Emergency Contact 1", Icons.phone),
              _buildTextField(eme2Controller, "New Emergency Contact 2", Icons.phone),
              _buildTextField(eme3Controller, "New Emergency Contact 3", Icons.phone),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.tealAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                String eme1 = eme1Controller.text.trim();
                String eme2 = eme2Controller.text.trim();
                String eme3 = eme3Controller.text.trim();

                if (eme1.isNotEmpty && eme2.isNotEmpty && eme3.isNotEmpty) {
                  saveEmergencyContacts(_firestore.collection('Users').doc(userId), eme1, eme2, eme3);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter all emergency contacts")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showEmergencyContactDialog() {
    TextEditingController eme1Controller = TextEditingController();
    TextEditingController eme2Controller = TextEditingController();
    TextEditingController eme3Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Set Emergency Contacts", style: TextStyle(color: Colors.tealAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(eme1Controller, "Emergency Contact 1", Icons.phone),
              _buildTextField(eme2Controller, "Emergency Contact 2", Icons.phone),
              _buildTextField(eme3Controller, "Emergency Contact 3", Icons.phone),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.tealAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                String eme1 = eme1Controller.text.trim();
                String eme2 = eme2Controller.text.trim();
                String eme3 = eme3Controller.text.trim();

                if (eme1.isNotEmpty && eme2.isNotEmpty && eme3.isNotEmpty) {
                  saveEmergencyContacts(_firestore.collection('Users').doc(userId), eme1, eme2, eme3);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter all emergency contacts")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSOSButton(String label, String phoneNumber) {
    return Card(
      color: Colors.blueGrey[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          phoneNumber,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone_forwarded, color: Colors.tealAccent),
          onPressed: () => makeEmergencyCall(phoneNumber),
        ),
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        cursorColor: Colors.tealAccent,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.tealAccent, size: 22),
          ),
          filled: true,
          fillColor: Colors.blueGrey.shade800,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.tealAccent.withOpacity(0.4), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.tealAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  void saveEmergencyContacts(DocumentReference userDocRef, String eme1, String eme2, String eme3) {
    userDocRef.update({
      "Eme1": eme1,
      "Eme2": eme2,
      "Eme3": eme3,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Emergency contacts updated successfully")),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update emergency contacts")),
      );
    });
  }

  void makeEmergencyCall(String phoneNumber) async {
    final Uri callUri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      print("Could not launch emergency call");
    }
  }
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Row(
            children: const [
              CircularProgressIndicator(color: Colors.tealAccent),
              SizedBox(width: 20),
              Text("Loading...", style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

}
