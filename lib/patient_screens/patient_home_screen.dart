import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'telemedicine_screen.dart';
import 'tablets_screen.dart';
import 'profile_screen.dart';
import 'monitoring_screen.dart';
import 'package:curosync/utils/sos_helper.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 2; // Home is now the default selected tab
  String userName = "Loading...";
  String profilePicUrl = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String phoneNumber = user.phoneNumber ?? "Unknown";
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(phoneNumber).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc["Name"] ?? "Patient";
          profilePicUrl = userDoc["ProfilePic"] ?? "";
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  static final List<Widget> _pages = <Widget>[
    MediciensScreen(),
    RemoteMonitoringScreen(),
    HomeScreen(),
    TelemedicineScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Dashboard")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage:
                    profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                    radius: 30,
                    child: profilePicUrl.isEmpty ? Icon(Icons.person, size: 40) : null,
                  ),
                  SizedBox(height: 10),
                  Text(userName, style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                _onItemTapped(4); // Switch to Profile tab
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("Help"),
              onTap: () {
                print("Settings Clicked");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.medical_information), label: 'Tablets'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: 'Monitoring'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // Default Tab
          BottomNavigationBarItem(icon: Icon(Icons.video_call), label: 'Telemedicine'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey[600],
        selectedItemColor: Colors.green[600],
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: triggerSOS,
        backgroundColor: Colors.red,
        child: Icon(Icons.sos, color: Colors.white),
      ),
    );
  }
}




