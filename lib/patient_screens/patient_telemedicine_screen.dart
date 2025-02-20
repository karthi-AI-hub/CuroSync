import 'package:flutter/material.dart';

class TelemedicineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          print("Starting telemedicine session...");
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: Text("Start Telemedicine Consultation", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}