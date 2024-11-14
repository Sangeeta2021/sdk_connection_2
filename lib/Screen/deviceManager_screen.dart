
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class DeviceManagerScreen extends StatefulWidget {
//   @override
//   _DeviceManagerScreenState createState() => _DeviceManagerScreenState();
// }

// class _DeviceManagerScreenState extends State<DeviceManagerScreen> {
//   static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

//   String _weightData = 'No data received yet';
//   String _deviceName = 'No device connected';
//   List<Map<String, String>> _deviceList = [];

//   @override
//   void initState() {
//     super.initState();
//     platform.setMethodCallHandler(_handleNativeMethodCall);
//     _startScan();
//   }

//   Future<void> _startScan() async {
//     try {
//       final result = await platform.invokeMethod('startScan');
//       print('Scanning for devices...');
//     } on PlatformException catch (e) {
//       print("Failed to start scan: ${e.message}");
//     }
//   }

//   Future<void> _connectToDevice(String deviceAddress) async {
//     try {
//       final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
//       print("device got connected to : $result");
//       setState(() {
//         _deviceName = result;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         _deviceName = "Failed to connect: ${e.message}";
//       });
//     }
//   }

//   Future<void> _getWeightData() async {
//     try {
//       final result = await platform.invokeMethod('getWeightData');
//       setState(() {
//         _weightData = result;
//       });
//     } on PlatformException catch (e) {
//       setState(() {
//         _weightData = "Failed to get weight: ${e.message}";
//       });
//     }
//   }

//   Future<void> _handleNativeMethodCall(MethodCall call) async {
//     switch (call.method) {
//       case "onDeviceFound":
//         Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
//         setState(() {
//           _deviceList.add(deviceInfo);
//         });
//         break;
//       case "onWeightDataReceived":
//         setState(() {
//           _weightData = call.arguments;
//         });
//         break;
//       default:
//         throw MissingPluginException("Not implemented: ${call.method}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple.shade200,
//         centerTitle: true,
//         title: Text('BLE SDK Connection'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               'Connected Device: $_deviceName',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Weight Data: $_weightData',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _getWeightData,
//               child: Text('Get Weight Data'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_deviceList.isNotEmpty) {
//                   await _connectToDevice(_deviceList.first['address']!);
//                 }
//               },
//               child: Text('Connect to Device'),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _deviceList.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_deviceList[index]['name']!),
//                     subtitle: Text(_deviceList[index]['address']!),
//                     onTap: () async {
//                       await _connectToDevice(_deviceList[index]['address']!);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



//*******************8Updated Code******************************/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceManagerScreen extends StatefulWidget {
  @override
  _DeviceManagerScreenState createState() => _DeviceManagerScreenState();
}

class _DeviceManagerScreenState extends State<DeviceManagerScreen> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';
  List<Map<String, String>> _deviceList = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeMethodCall);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
    PermissionStatus locationStatus = await Permission.locationWhenInUse.status;

    if (!bluetoothStatus.isGranted) {
      await Permission.bluetooth.request();
    }

    if (!locationStatus.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    // Start scanning once permissions are granted
    await _startScan();
  }

  Future<void> _startScan() async {
    // Check Bluetooth status before starting the scan
    var state = await flutterBlue.state.first;
    if (state != BluetoothState.on) {
      print("Bluetooth is not on");
      return;
    }

    // Clear previous device list and start scanning
    setState(() {
      _deviceList.clear();
    });

    try {
      final result = await platform.invokeMethod('startScan');
      print('Scanning for devices...');
    } on PlatformException catch (e) {
      print("Failed to start scan: ${e.message}");
    }
  }

  Future<void> _connectToDevice(String deviceAddress) async {
    try {
      final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
      print("Device connected to: $result");
      setState(() {
        _deviceName = result;
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
        _weightData = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _weightData = "Failed to get weight: ${e.message}";
      });
    }
  }

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onDeviceFound":
        Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
        setState(() {
          _deviceList.add(deviceInfo);
        });
        break;
      case "onWeightDataReceived":
        setState(() {
          _weightData = call.arguments;
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
        title: Text('BLE SDK Connection, DM Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              onPressed: _getWeightData,
              child: Text('Get Weight Data'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_deviceList.isNotEmpty) {
                  await _connectToDevice(_deviceList.first['address']!);
                }
              },
              child: Text('Connect to Device'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _deviceList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_deviceList[index]['name']!),
                    subtitle: Text(_deviceList[index]['address']!),
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
}
