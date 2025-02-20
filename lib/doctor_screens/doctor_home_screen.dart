import 'package:curosync/splash_screen.dart';
import 'package:curosync/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_dashboard_screen.dart';
import 'patient_appointments_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorHomePage extends StatefulWidget {
  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 1;
  String userName = getPhone();
  String profilePicUrl = "";
  String hospitalName = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String phoneNumber = getPhone() ?? "Unknown";
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('Doctors').doc(phoneNumber).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc["Name"] ?? "Patient";
          hospitalName = userDoc['Hospital'] ?? "Unknown Hospital";
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  static final List<Widget> _pages = <Widget>[
    AppointmentsScreen(),
    DoctorDashboardScreen(),
    DoctorProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        elevation: 5,

        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: AssetImage("assets/logo.jpeg"),
            ),
            SizedBox(width: 10),
            Text(
              userName.isNotEmpty ? userName : "CSD-ADMIN",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),

      drawer: _buildDrawer(),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),



      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          backgroundColor: Colors.blueGrey[800],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.video_call),
              label: 'Appoinments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.grey[400],
          selectedItemColor: Colors.tealAccent[700],
          onTap: _onItemTapped,
          elevation: 10,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.teal[700]),
            accountName: Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              hospitalName.isNotEmpty ? hospitalName : "Hospital",
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
                )
            ),
          ),

          // Home & Profile
          _buildDrawerItem(Icons.person, "Profile", 2),
          _buildDrawerItem(Icons.home, "Dashboard", 1),
          _buildDrawerItem(Icons.video_call, "Appoinments", 0),

          _buildDrawerItem(Icons.info, "About us", -1),
          _buildDrawerItem(Icons.help, "Help", -2),
          const Divider(),

          // Logout Option
          _buildDrawerItem(Icons.logout, "Logout", -3, iconColor: Colors.red,
              textColor: Colors.red,
              onTap: _logout),
        ],
      ),
    );
  }
  Widget _buildDrawerItem(IconData icon, String title, int index,
      {Color iconColor = Colors.black, Color textColor = Colors.black, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
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

}




