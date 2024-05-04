import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/ui/components/report_type.dart';

class DashboardScreen extends StatefulWidget {
  final String name;
  final String uid;
  const DashboardScreen({super.key, required this.name, required this.uid});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //String name = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Welcome , ${widget.name}',
                style: const TextStyle(color: Colors.blueAccent, fontSize: 18)),
          ),
          const SizedBox(
            height: 15,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('You Can Make a report about ',
                style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
          ),
          const SizedBox(
            height: 15,
          ),
          ReportType(uid: widget.uid, name: widget.name),
        ],
      ),
    );
  }
}
