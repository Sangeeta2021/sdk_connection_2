import 'package:flutter/material.dart';
import 'package:sdk_connection_2/Screen/Testing/ble_service.dart';

class TestScreen2 extends StatefulWidget {
  @override
  _TestScreen2State createState() => _TestScreen2State();
}

class _TestScreen2State extends State<TestScreen2> {
  @override
  void initState() {
    super.initState();
    BleService bleService = BleService();
    bleService.scanAndTestCharacteristics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Weight Data Scanner'),
      ),
      body: Center(
        child: Text('Scanning for BLE devices...'),
      ),
    );
  }
}