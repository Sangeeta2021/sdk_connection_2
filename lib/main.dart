import 'package:flutter/material.dart';
import 'package:sdk_connection_2/Screen/deviceManager_screen.dart';
import 'package:sdk_connection_2/Screen/testScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.purple,
      ),
      home: DeviceManagerScreen(),
      
    );
  }
}

