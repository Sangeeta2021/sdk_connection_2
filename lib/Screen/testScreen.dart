
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sdk_connection_2/utils/constants.dart';
// import 'package:sdk_connection_2/widget/sizedBox.dart';

// class TestScreen extends StatefulWidget {
//   const TestScreen({super.key});

//   @override
//   State<TestScreen> createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

//   String _weightData = 'No data received yet';
//   String _deviceName = 'No device connected';
//   List<Map<String, String>> _deviceList = [];
//   FlutterBlue flutterBlue = FlutterBlue.instance;

//   @override
//   void initState() {
//     super.initState();
//     platform.setMethodCallHandler(_handleNativeMethodCall);
//     _checkPermissions();
//   }

//   Future<void> _checkPermissions() async {
//     PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
//     PermissionStatus locationStatus = await Permission.locationWhenInUse.status;

//     if (!bluetoothStatus.isGranted) {
//       await Permission.bluetooth.request();
//     }

//     if (!locationStatus.isGranted) {
//       await Permission.locationWhenInUse.request();
//     }

//     // Start scanning once permissions are granted
//     await _startScan();
//   }

//   Future<void> _startScan() async {
//     // Check Bluetooth status before starting the scan
//     var state = await flutterBlue.state.first;
//     if (state != BluetoothState.on) {
//       print("Bluetooth is not on");
//       return;
//     }

//     // Clear previous device list and start scanning
//     setState(() {
//       _deviceList.clear();
//     });

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
//       print("Device connected to: $result");
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
//      return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple.shade200,
//         centerTitle: true,
//         title: Text('BLE SDK Connection, DM Screen', style: appBarTextStyle,),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[

//             detailsRow("Connected Device:  ",_deviceName),
//             height20, 
//             detailsRow("Weight Data:  ",_weightData),          
//              height20,
//             ElevatedButton(
//               onPressed: _getWeightData,
//               child: Text('Get Weight Data', style: buttonTextStyle,),
//             ),
//             height20,
//             ElevatedButton(
//               onPressed: () async {
//                 if (_deviceList.isNotEmpty) {
//                   await _connectToDevice(_deviceList.first['address']!);
//                 }
//               },
//               child: Text('Connect to Device', style: buttonTextStyle,),
//             ),
//             height20,
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _deviceList.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_deviceList[index]['name']!, style: blackHeadingStyle,),
//                     subtitle: Text(_deviceList[index]['address']!, style: blackContentStyle,),
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

//   Widget detailsRow(String ques, String res) {
//     return RichText(text: TextSpan(
//             children: [
//               TextSpan(text: ques, style: blackContentStyle),
//               TextSpan(text: res, style: blackHeadingStyle)
//             ],
//           ),);
//   }
// }


//***************Updated code for fetching weight with GATT********************/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');
  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';
  List<Map<String, String>> _deviceList = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeMethodCall);
    _checkPermissions();
  }

  // Future<void> _checkPermissions() async {
  //   final bluetoothStatus = await Permission.bluetooth.status;
  //   final locationStatus = await Permission.locationWhenInUse.status;

  //   if (!bluetoothStatus.isGranted) {
  //     await Permission.bluetooth.request();
  //   }
  //   if (!locationStatus.isGranted) {
  //     await Permission.locationWhenInUse.request();
  //   }

  //   if (bluetoothStatus.isGranted && locationStatus.isGranted) {
  //     _startScan();
  //   } else {
  //     setState(() {
  //       _weightData = "Permissions denied!";
  //     });
  //   }
  // }


  Future<void> _checkPermissions() async {
  final bluetoothStatus = await Permission.bluetoothScan.status;
  final connectStatus = await Permission.bluetoothConnect.status;
  final locationStatus = await Permission.locationWhenInUse.status;

  if (!bluetoothStatus.isGranted) {
    await Permission.bluetoothScan.request();
  }
  if (!connectStatus.isGranted) {
    await Permission.bluetoothConnect.request();
  }
  if (!locationStatus.isGranted) {
    await Permission.locationWhenInUse.request();
  }

  if (bluetoothStatus.isGranted && connectStatus.isGranted && locationStatus.isGranted) {
    _startScan();
  } else {
    setState(() {
      _weightData = "Permissions denied!";
    });
  }
}


  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _deviceList.clear();
    });
    try {
      await platform.invokeMethod('startScan');
    } on PlatformException catch (e) {
      setState(() {
        _weightData = "Failed to start scan: ${e.message}";
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  // Future<void> _connectToDevice(String deviceAddress) async {
  //   try {
  //     await platform.invokeMethod('connectToDevice', {'deviceId': deviceAddress});
  //     setState(() {
  //       _deviceName = "Connected to $deviceAddress";
  //     });
  //   } on PlatformException catch (e) {
  //     setState(() {
  //       _deviceName = "Failed to connect: ${e.message}";
  //     });
  //   }
  // }
  Future<void> _connectToDevice(String? deviceAddress) async {
  if (deviceAddress == null || deviceAddress.isEmpty) {
    setState(() {
      _deviceName = "Invalid device address";
    });
    return;
  }

  try {
    await platform.invokeMethod('connectToDevice', {'deviceId': deviceAddress});
    setState(() {
      _deviceName = "Connected to $deviceAddress";
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
        _weightData = result ?? "Failed to get weight: Unknown error";
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
        final deviceInfo = Map<String, String>.from(call.arguments);
        setState(() {
          _deviceList.add(deviceInfo);
        });
        break;
      case "onWeightDataReceived":
        setState(() {
          _weightData = call.arguments;
        });
        break;
      case "onError":
        setState(() {
          _weightData = "Error: ${call.arguments}";
        });
        break;
      default:
        print("Unrecognized method: ${call.method}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SDK Connection 2, Test Screen')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Device: $_deviceName", style: const TextStyle(fontSize: 16)),
            Text("Weight Data: $_weightData", style: const TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: _getWeightData,
              child: const Text('Fetch Weight Data'),
            ),
            const SizedBox(height: 10),
            _isScanning
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _startScan,
                    child: const Text('Start Scan'),
                  ),
            const SizedBox(height: 10),
            Expanded(
              child: _deviceList.isNotEmpty
                  ? ListView.builder(
                      itemCount: _deviceList.length,
                      itemBuilder: (context, index) {
                        final device = _deviceList[index];
                        return ListTile(
                          title: Text(device['name'] ?? "Unknown device"),
                          subtitle: Text(device['address'] ?? "No address"),
                          trailing: ElevatedButton(
                            onPressed:(){
                              _connectToDevice(device['address']!);
                              print("connect button clicked: ${device['name']}");
                              print("connected device address: ${device['address']}");

                            } ,
                            child: const Text('Connect'),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text("No devices found"),
                    ),
            ),
            if (_weightData.contains('Permissions denied'))
              const Center(
                child: Text(
                  "Please grant Bluetooth and location permissions.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
