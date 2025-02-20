import 'package:curosync/patient_screens/patient_input_screen.dart';
import 'package:curosync/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_login_screen.dart';
import 'home_screen.dart';
import 'patient_telemedicine_screen.dart';
import 'patient_tablets_screen.dart';
import 'patient_profile_screen.dart';
import 'patient_monitoring_screen.dart';
import 'package:curosync/utils/sos_helper.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 2;
  String userName = "";
  String profilePicUrl = "";
  late SOSManager sosManager;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    sosManager = SOSManager(context);
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String phoneNumber = getPhone() ?? "Unknown";
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
          'Users').doc(phoneNumber).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc["Name"] ?? "Patient";
          profilePicUrl = userDoc["ProfilePic"] ?? "";
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientLoginScreen()),
        );
      }

    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PatientLoginScreen()),
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
      appBar: AppBar(
        title: Text(
          getAppName(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
        iconTheme: IconThemeData(color: Colors.white),),
      drawer: _buildDrawer(),
      body: _pages[_selectedIndex],
      backgroundColor: Colors.blueGrey[900],

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blueGrey[800],
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.medical_information), label: 'Tablets'),
            BottomNavigationBarItem(
                icon: Icon(Icons.monitor_heart), label: 'Monitoring'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.video_call), label: 'Telemedicine'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.grey[500],
          selectedItemColor: Colors.tealAccent[700],
          onTap: _onItemTapped,
          elevation: 15, // Added shadow effect
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sosManager.decisionSOS();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.sos, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 10, // Added depth effect
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.teal[700]),
                  accountName: Text(
                    "CSP-" + getPhone().substring(0, 7),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(
                    "Loading...",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  currentAccountPicture: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                    child: profilePicUrl.isEmpty
                        ? ClipOval(
                      child: Image.asset(
                        'assets/logo.jpeg',
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    )
                        : null,
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.teal[700]),
                  accountName: Text(
                    "CSP-" + getPhone().substring(0, 7),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(
                    "Loading ...",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  currentAccountPicture: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.jpeg',
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                );
              }

              var userDoc = snapshot.data!;
              String fetchedName = userDoc["Name"] ?? "Patient";
              String fetchedProfilePic ="";

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.teal[700]),
                accountName: Text(
                  "CSP-" + getPhone().substring(0, 7),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  fetchedName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                currentAccountPicture: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: fetchedProfilePic.isNotEmpty ? NetworkImage(fetchedProfilePic) : null,
                  child: fetchedProfilePic.isEmpty
                      ? ClipOval(
                    child: Image.asset(
                      'assets/logo.jpeg',
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  )
                      : null,
                ),
              );
            },
          ),

          _buildDrawerItem(Icons.home, "Home", 2),
          _buildDrawerItem(Icons.person, "Profile", 4),
          _buildDrawerItem(Icons.medical_information, "Tablets", 0),
          _buildDrawerItem(Icons.monitor_heart, "Monitoring", 1),
          _buildDrawerItem(Icons.video_call, "Telemedicine", 3),
          _buildDrawerItem(Icons.info, "About Us", -3),
          _buildDrawerItem(Icons.help, "Help", -1),

          const Divider(),
          _buildDrawerItem(Icons.logout, "Logout", -2, iconColor: Colors.red,
              textColor: Colors.red,
              onTap: _logout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index,
      {Color iconColor = Colors.black, Color textColor = Colors
          .black, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      onTap: () {
        if (index >= 0) {
          _onItemTapped(index);
          Navigator.pop(context);
        } else {
          onTap?.call();
        }
      },
    );
  }

  Future<DocumentSnapshot> _getUserData() async {
    String phoneNumber = getPhone();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance.collection('Users').doc(
          phoneNumber).get();
    }
    throw Exception("User not logged in");
  }
}
