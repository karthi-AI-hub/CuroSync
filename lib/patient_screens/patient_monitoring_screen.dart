import 'package:flutter/material.dart';

class RemoteMonitoringScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Real-time Health Monitoring", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          Text("Heart Rate: -- bpm",style: TextStyle(color: Colors.white)),
          Text("Blood Pressure: -- / -- mmHg",style: TextStyle(color: Colors.white)),
          Text("Blood Sugar: -- mg/dL",style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}