import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../utils/constants.dart';
import '../widget/sizedBox.dart';

class TestScreen4 extends StatefulWidget {
  @override
  _TestScreen4State createState() =>
      _TestScreen4State();
}

class _TestScreen4State extends State<TestScreen4> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  List<Map<String, String>> _deviceList = [];
  String _deviceName = "Unknown";
  String _weightData = "No data";
  String _weightServiceUuid = "";
  String _weightCharacteristicUuid = "";
  static const platform = const MethodChannel('com.example.ble_sdk_connection/ble');

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeMethodCall);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      // Request necessary permissions
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      await _startScan();
    } catch (e) {
      print("Permission error: $e");
      setState(() {
        _deviceName = "Permission error: $e";
      });
    }
  }

  Future<void> _startScan() async {
    var state = await flutterBlue.state.first;
    if (state != BluetoothState.on) {
      print("Bluetooth is not on");
      setState(() {
        _deviceName = "Bluetooth is not enabled";
      });
      return;
    }

    setState(() {
      _deviceList.clear(); // Clear the list before scanning
    });

    try {
      await platform.invokeMethod('startScan');
      print('Scanning for devices...');
    } on PlatformException catch (e) {
      print("Failed to start scan: ${e.message}");
      setState(() {
        _deviceName = "Scan failed: ${e.message}";
      });
    }
  }

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onDeviceFound":
        Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
        setState(() {
          _deviceList.add(deviceInfo); // Add the found device to the list
        });
        break;

      case "onServicesDiscovered":
        Map<String, dynamic> serviceInfo = Map<String, dynamic>.from(call.arguments);
        print("Discovered Services and Characteristics: $serviceInfo");

        // Safely access weight characteristic
        _findWeightCharacteristic(serviceInfo).then((result) {
          if (result != null) {
            setState(() {
              _weightServiceUuid = result['serviceUuid'] ?? "";
              _weightCharacteristicUuid = result['characteristicUuid'] ?? "";
            });
            print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");
          } else {
            print("No weight characteristic found");
          }
        });
        break;

      case "onWeightDataReceived":
        setState(() {
          _weightData = call.arguments ?? "No data";
        });
        break;

      default:
        throw MissingPluginException("Not implemented: ${call.method}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade200,
        centerTitle: true,
        title: Text('SDK Connection, Screen3', style: appBarTextStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _startScan,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            detailsRow("Connected Device:  ", _deviceName),
            height20,
            detailsRow("Weight Data:  ", _weightData),
            height20,
            Row(
              children: [
                ElevatedButton(
                  onPressed: _getWeightData,
                  child: Text('Get Weight Data', style: buttonTextStyle),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _startScan,
                  child: Text('Rescan Devices', style: buttonTextStyle),
                ),
              ],
            ),
            height20,
            Expanded(
              child: ListView.builder(
                itemCount: _deviceList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_deviceList[index]['name']!, style: blackHeadingStyle),
                    subtitle: Text(_deviceList[index]['address']!, style: blackContentStyle),
                    onTap: () async {
                      await _connectToDevice(_deviceList[index]['address']!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailsRow(String ques, String res) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: ques, style: blackContentStyle),
          TextSpan(text: res, style: blackHeadingStyle),
        ],
      ),
    );
  }

  Future<void> _connectToDevice(String address) async {
    try {
      await platform.invokeMethod('connectDevice', {'address': address});
      setState(() {
        _deviceName = "Connecting...";
      });
    } catch (e) {
      print("Failed to connect to device: $e");
      setState(() {
        _deviceName = "Connection failed: $e";
      });
    }
  }

  Future<void> _getWeightData() async {
    try {
      await platform.invokeMethod('getWeightData');
    } catch (e) {
      print("Failed to get weight data: $e");
      setState(() {
        _weightData = "Failed to get weight data: $e";
      });
    }
  }

  Future<Map<String, String>?> _findWeightCharacteristic(Map<String, dynamic> serviceInfo) async {
    var services = serviceInfo['services'] as List<dynamic>;
    for (var service in services) {
      var characteristics = service['characteristics'] as List<dynamic>;
      for (var characteristic in characteristics) {
        if (characteristic['uuid'] == _weightCharacteristicUuid) {
          return {
            'serviceUuid': service['uuid'] as String,
            'characteristicUuid': characteristic['uuid'] as String
          };
        }
      }
    }
    return null;
  }
}
