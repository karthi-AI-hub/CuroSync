import 'package:curosync/patient_screens/patient_home_screen.dart';
import 'package:curosync/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'admin_screens/admin_home_screeen.dart';
import 'doctor_screens/doctor_home_screen.dart';
import 'providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CuroSyncApp());
}

class CuroSyncApp extends StatelessWidget {
  const CuroSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CuroSync - Health App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

// AuthWrapper to check login status and redirect users
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return RoleBasedRedirect(); // Redirect users based on role
        }
        return SplashScreen(); // Show login screen if not logged in
      },
    );
  }
}

// Determines where to redirect after login
class RoleBasedRedirect extends StatefulWidget {
  @override
  _RoleBasedRedirectState createState() => _RoleBasedRedirectState();
}

class _RoleBasedRedirectState extends State<RoleBasedRedirect> {
  bool isLoading = true;
  Widget? nextScreen;

  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  Future<void> _redirectUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('userRole');
    String? phno = prefs.getString('phno');
    setPhone(phno!);

    if (role == 'Admin') {
      setState(() {
        nextScreen = AdminHomeScreeen();
        isLoading = false;
      });
      return;
    } else if (role == 'Doctor') {
      setState(() {
        nextScreen = DoctorHomePage();
        isLoading = false;
      });
      return;
    } else if (role == 'Patient') {
      setState(() {
        nextScreen = PatientHomePage();
        isLoading = false;
      });
      return;
    }

    await _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        nextScreen = SplashScreen();
        isLoading = false;
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(phno)
          .get();
      if (adminDoc.exists) {
        await prefs.setString('userRole', 'Admin');
        setState(() {
          nextScreen = AdminHomeScreeen();
          isLoading = false;
        });
        return;
      }

      // Check Doctor
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(phno)
          .get();
      if (doctorDoc.exists) {
        await prefs.setString('userRole', 'Doctor');
        setState(() {
          nextScreen = DoctorHomePage();
          isLoading = false;
        });
        return;
      }

      // Check Patient
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(phno)
          .get();
      if (userDoc.exists) {
        await prefs.setString('userRole', 'Patient');
        setState(() {
          nextScreen = PatientHomePage();
          isLoading = false;
        });
        return;
      }

      await FirebaseAuth.instance.signOut();
      await prefs.remove('userRole');
      setState(() {
        nextScreen = SplashScreen();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user role: $e");
      setState(() {
        nextScreen = SplashScreen();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : nextScreen!;
  }
}