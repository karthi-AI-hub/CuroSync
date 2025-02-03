import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  String userName = "Loading...";
  String profilePicUrl = "";
  Map<String, dynamic>? healthStats;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String phoneNumber = user.phoneNumber ?? "Unknown";
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(phoneNumber).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc["Name"] ?? "Patient";
          profilePicUrl = userDoc["ProfilePic"] ?? "";
          healthStats = userDoc["HealthStats"] ?? {};
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Dashboard")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profilePicUrl.isNotEmpty
                      ? NetworkImage(profilePicUrl)
                      : AssetImage("assets/logo.jpeg") as ImageProvider,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text("Chronic Disease Patient", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Health Stats Summary
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Health Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Heart Rate: ${healthStats?["heartRate"] ?? "--"} bpm"),
                    Text("Blood Pressure: ${healthStats?["bloodPressure"] ?? "--"}"),
                    Text("Blood Sugar: ${healthStats?["bloodSugar"] ?? "--"} mg/dL"),
                    // Add more health parameters if available
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Quick Access Features
            Text("Quick Access", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                _buildFeatureButton("Remote Monitoring", Icons.monitor_heart, _onRemoteMonitoringPressed),
                _buildFeatureButton("Telemedicine", Icons.video_call, _onTelemedicinePressed),
                _buildFeatureButton("Appointments", Icons.calendar_today, _onAppointmentsPressed),
                _buildFeatureButton("Health Reports", Icons.file_copy, _onHealthReportsPressed),
                _buildFeatureButton("Medicine Reminders", Icons.notifications_active, _onMedicineRemindersPressed),
                _buildFeatureButton("Emergency Help", Icons.local_hospital, _onEmergencyHelpPressed),
              ],
            ),
            SizedBox(height: 20),

            // Emergency Assistance Button
            Center(
              child: ElevatedButton(
                onPressed: _onEmergencyHelpPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Emergency Assistance", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(String title, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Feature Button Actions
  void _onRemoteMonitoringPressed() {
    // Fetch and display real-time health data from connected devices
    print("Fetching real-time health data...");
  }

  void _onTelemedicinePressed() {
    // Initiate a video call with a doctor for teleconsultation
    print("Starting telemedicine session...");
  }

  void _onAppointmentsPressed() {
    // Navigate to the appointment booking system
    print("Opening appointment booking...");
  }

  void _onHealthReportsPressed() {
    // Fetch and display historical health reports
    print("Loading health reports...");
  }

  void _onMedicineRemindersPressed() {
    // Navigate to medicine reminder management system
    print("Setting up medicine reminders...");
  }

  void _onEmergencyHelpPressed() {
    // Trigger an emergency alert or call emergency services
    print("Sending emergency alert...");
  }
}
