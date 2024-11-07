import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceManagerScreen extends StatefulWidget {
  @override
  _DeviceManagerScreenState createState() => _DeviceManagerScreenState();
}

class _DeviceManagerScreenState extends State<DeviceManagerScreen> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_channel');
  
  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeMethodCall);
  }

  Future<void> _connectToDevice() async {
    try {
      final result = await platform.invokeMethod('connectToDevice');
      setState(() {
        _deviceName = result; // Set the device name after connecting
      });
    } on PlatformException catch (e) {
      setState(() {
        _deviceName = "Failed to connect: ${e.message}";
      });
    }
  }

  Future<void> _getWeightData() async {
    try {
      final result = await platform.invokeMethod('getWeightData');
      setState(() {
        _weightData = result; // Update the weight data
      });
    } on PlatformException catch (e) {
      setState(() {
        _weightData = "Failed to get weight: ${e.message}";
      });
    }
  }

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onWeightDataReceived":
        setState(() {
          _weightData = call.arguments;
        });
        break;
      case "onDeviceNameReceived":
        setState(() {
          _deviceName = call.arguments; // Set the device name received from native code
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
        title: Text('BLE SDK Connection Method 2a'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Connected Device: $_deviceName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Weight Data: $_weightData',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectToDevice,
              child: Text('Connect to Device'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getWeightData,
              child: Text('Get Weight Data'),
            ),
          ],
        ),
      ),
    );
  }
}
