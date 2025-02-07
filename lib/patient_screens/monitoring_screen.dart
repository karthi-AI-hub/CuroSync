import 'package:flutter/material.dart';

class RemoteMonitoringScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Real-time Health Monitoring", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Heart Rate: -- bpm"),
          Text("Blood Pressure: -- / -- mmHg"),
          Text("Blood Sugar: -- mg/dL"),
        ],
      ),
    );
  }
}