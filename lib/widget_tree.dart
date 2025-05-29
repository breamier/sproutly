import 'package:sproutly/auth.dart';
import 'package:sproutly/screens/dashboard_screen.dart';
import 'package:sproutly/screens/login_register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        print('Auth snapshot: ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginPage();
          } else {
            return DashboardScreen();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
