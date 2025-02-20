import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'patient_edit_profile_screen.dart';
import 'package:curosync/utils/values.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(getPhone()).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoader();
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found.", style: TextStyle(color: Colors.white)));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(data),
                const SizedBox(height: 20),

                _buildSectionTitle("Personal Details"),
                _buildProfileCard(Icons.person, "Full Name", data['Name']),
                _buildProfileCard(Icons.badge, "Medical ID", "CSP-" + getPhone().substring(0, 7)),
                _buildProfileCard(Icons.cake, "Age", data['Age']),
                _buildProfileCard(Icons.male, "Gender", data['Gender']),
                _buildProfileCard(Icons.bloodtype, "Blood Group", data['BloodGroup']),

                const SizedBox(height: 20),

                _buildSectionTitle("Contact Information"),
                _buildProfileCard(Icons.phone, "Phone Number", data['PhoneNumber']),
                _buildProfileCard(Icons.email, "Email", data['Email']),
                _buildProfileCard(Icons.home, "Address", data['Address']),

                const SizedBox(height: 20),

                _buildSectionTitle("Medical Information"),
                _buildProfileCard(Icons.local_hospital, "Disease Condition", data['Disease']),
                _buildProfileCard(Icons.medical_services, "Current Hospital", data['Hospital']),

                const SizedBox(height: 20),

                _buildSectionTitle("Emergency Contacts"),
                _buildProfileCard(Icons.emergency_rounded, "Emergency Contact 1", data['Eme1']),
                _buildProfileCard(Icons.emergency_rounded, "Emergency Contact 2", data['Eme2']),
                _buildProfileCard(Icons.emergency_rounded, "Emergency Contact 3", data['Eme3']),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen(userId: getPhone())),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Edit Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent[700],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.blueGrey[800],
            backgroundImage: AssetImage("assets/logo.jpeg"),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          data['Name'] ?? "N/A",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          "PATIENT",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.tealAccent,
        ),
      ),
    );
  }

  Widget _buildProfileCard(IconData icon, String title, String? value) {
    return Card(
      color: Colors.blueGrey[800],
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.tealAccent, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 16)),
        subtitle: Text(value ?? "N/A", style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[700]!,
          highlightColor: Colors.grey[500]!,
          child: Card(
            color: Colors.blueGrey[800],
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 24,
              ),
              title: Container(
                height: 15,
                width: 100,
                color: Colors.white,
              ),
              subtitle: Container(
                height: 10,
                width: 150,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
