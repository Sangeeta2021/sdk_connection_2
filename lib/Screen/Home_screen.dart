

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:sdk_connection_2/Screen/customBluetoothDevice.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<CustomBluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    _initializeMethodChannel();
    startScan();
  }

  // Set up the MethodChannel to receive device updates from Android
  void _initializeMethodChannel() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onDeviceFound') {
        final String deviceId = call.arguments['deviceId'];
        final String deviceName = call.arguments['deviceName'] ?? 'Unknown Device';
        _handleDeviceFound(deviceId, deviceName);
      }
      return null;
    });
  }

  // Handle the device found callback by adding the device to the list
  void _handleDeviceFound(String deviceId, String deviceName) {
    setState(() {
      devicesList.add(CustomBluetoothDevice(id: deviceId, name: deviceName));
    });
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devicesList.any((device) => device.id == result.device.id.toString())) {
          setState(() {
            devicesList.add(CustomBluetoothDevice(
              id: result.device.id.toString(),
              name: result.device.name.isEmpty ? 'Unknown Device' : result.device.name,
            ));
          });
        }
      }
    });
  }

  Future<void> _initializeAndAddDevice(String deviceId) async {
    try {
      await platform.invokeMethod('initializeAndAddDevice', {"deviceId": deviceId});
      print('Device added successfully.');
    } on PlatformException catch (e) {
      print("Failed to add device: '${e.message}'");
    }
  }

 
 Future<void> _connectToDevice(CustomBluetoothDevice device) async {
  // Start scanning for Bluetooth devices
  flutterBlue.startScan(timeout: Duration(seconds: 5));

  flutterBlue.scanResults.listen((results) async {
    for (ScanResult result in results) {
      // Check if the device ID matches
      if (result.device.id.toString() == device.id) {
        // Stop scanning once we find the device
        flutterBlue.stopScan();

        try {
          // Connect to the device
          await result.device.connect();
          setState(() {
            connectedDevice = result.device;
          });
          _initializeAndAddDevice(device.id);
          print("Device connected successfully.");
        } catch (e) {
          print("Failed to connect to device: $e");
        }
        break;
      }
    }
  });
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.purple.shade100,
        title: Text("BLE SDK Connection Method 2",
       ),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          final device = devicesList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
            child: ListTile(
              title: Text(device.name),
              subtitle: Text(device.id),
              trailing: ElevatedButton(
                onPressed: () => _connectToDevice(device),
                child: Text('Connect'),
              ),
            ),
          );
        },
      ),
    );
  }
}
