
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
//         title: Text('BLE SDK Connection, Test Screen', style: appBarTextStyle,),
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




//********************updated code for getting uuid**************/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_connection_2/utils/constants.dart';
import 'package:sdk_connection_2/widget/sizedBox.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';
  String _serviceUuid = 'No service UUID';
  String _characteristicUuid = 'No characteristic UUID';
  List<Map<String, String>> _deviceList = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeMethodCall);
    _checkPermissions();
    _listenToBluetoothState();
  }

  // Check permissions for Bluetooth and Location
  Future<void> _checkPermissions() async {
    PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
    PermissionStatus locationStatus = await Permission.locationWhenInUse.status;

    if (!bluetoothStatus.isGranted) {
      bluetoothStatus = await Permission.bluetooth.request();
    }

    if (!locationStatus.isGranted) {
      locationStatus = await Permission.locationWhenInUse.request();
    }

    if (bluetoothStatus.isGranted && locationStatus.isGranted) {
      _startScan();
    } else {
      // Display permission error if not granted
      _showPermissionError();
    }
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Error'),
          content: Text('Please grant Bluetooth and Location permissions to proceed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Listen for Bluetooth state changes
  void _listenToBluetoothState() {
    flutterBlue.state.listen((state) {
      print('Bluetooth state: $state');
      if (state == BluetoothState.on) {
        if (!_isScanning) {
          _startScan();
        }
      } else {
        print("Bluetooth is not enabled");
      }
    });
  }

  // // Start Bluetooth scan
  // Future<void> _startScan() async {
  //   var state = await flutterBlue.state.first;
  //   if (state != BluetoothState.on) {
  //     print("Bluetooth is not on");
  //     return;
  //   }

  //   setState(() {
  //     _isScanning = true; // Start scanning
  //     _deviceList.clear(); // Clear previous scan results
  //   });

  //   try {
  //     // Start Native BLE Scan
  //     await platform.invokeMethod('startScan');
  //     print('Native scanning for devices...');

  //     // Start FlutterBlue Scan
  //     flutterBlue.scanResults.listen((results) {
  //       for (var r in results) {
  //         print('Found device: ${r.device.name} (${r.device.id})');
  //         setState(() {
  //           _deviceList.add({'name': r.device.name, 'address': r.device.id.toString()});
  //         });
  //       }
  //     });

  //     await flutterBlue.startScan(timeout: const Duration(seconds: 5));
  //   } on PlatformException catch (e) {
  //     print("Failed to start scan: ${e.message}");
  //   }

  //   setState(() {
  //     _isScanning = false; // Stop scanning after timeout
  //   });
  // }

 Future<void> _startScan() async {
  var state = await flutterBlue.state.first;
  if (state != BluetoothState.on) {
    print("Bluetooth is not on");
    return;
  }

  setState(() {
    _isScanning = true; // Start scanning
    _deviceList.clear(); // Clear previous scan results
  });

  try {
    // Stop FlutterBlue scanning to prevent overlap
    await flutterBlue.stopScan();
    print('FlutterBlue scanning stopped.');

    // Start Native BLE Scan
    await platform.invokeMethod('startScan');
    print('Native scanning for devices...');

    // Listen to FlutterBlue scan results after native scan
    flutterBlue.scanResults.listen((results) {
      for (var r in results) {
        // Prevent duplicate device entries in the list
        if (!_deviceList.any((device) => device['address'] == r.device.id.toString())) {
          print('Found device: ${r.device.name} (${r.device.id})');
          setState(() {
            _deviceList.add({'name': r.device.name, 'address': r.device.id.toString()});
          });
        }
      }
    });

    // Start FlutterBlue scan with a timeout
    await flutterBlue.startScan(timeout: const Duration(seconds: 5));

  } on PlatformException catch (e) {
    print("Failed to start scan: ${e.message}");
  }

  setState(() {
    _isScanning = false; // Stop scanning after timeout
  });
}


  // Connect to a selected device
  Future<void> _connectToDevice(String deviceAddress) async {
    try {
      final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
      print("Device connected: $result");

      setState(() {
        _deviceName = result;
      });

      // Fetch UUIDs once the device is connected
      await _fetchUUIDs();

      // Once connected, get weight data
      _getWeightData();
    } on PlatformException catch (e) {
      setState(() {
        _deviceName = "Failed to connect: ${e.message}";
      });
    }
  }

  // Fetch service and characteristic UUIDs from the native side
  Future<void> _fetchUUIDs() async {
    try {
      final result = await platform.invokeMethod('getServiceAndCharacteristicUUIDs');
      setState(() {
        _serviceUuid = result['serviceUuid'];
        _characteristicUuid = result['characteristicUuid'];
      });
    } on PlatformException catch (e) {
      setState(() {
        _serviceUuid = 'Failed to fetch UUID: ${e.message}';
        _characteristicUuid = 'Failed to fetch UUID: ${e.message}';
      });
    }
  }

  // Fetch weight data from the device
  Future<void> _getWeightData() async {
    try {
      final result = await platform.invokeMethod('getWeightData');
      setState(() {
        _weightData = result;
        print("Weight data received: $_weightData");
      });
    } on PlatformException catch (e) {
      setState(() {
        _weightData = "Failed to get weight: ${e.message}";
      });
    }
  }

  // Handle native method calls (e.g., device found, weight data received)
  Future<void> _handleNativeMethodCall(MethodCall call) async {
    print("Received native method call: ${call.method}");
    switch (call.method) {
      case "onDeviceFound":
        Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
        print("Device found: $deviceInfo");
        setState(() {
          _deviceList.add(deviceInfo);
        });
        break;
      case "onServiceAndCharacteristicInfo":
        setState(() {
          _serviceUuid = call.arguments['serviceUuid'];
          _characteristicUuid = call.arguments['characteristicUuid'];
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
        title: Text('SDK Connection2, Test Screen', style: appBarTextStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            detailsRow("Connected Device:  ", _deviceName),
            height20,
            detailsRow("Service UUID:  ", _serviceUuid),
            height20,
            detailsRow("Characteristic UUID:  ", _characteristicUuid),
            height20,
            detailsRow("Weight Data:  ", _weightData),
            height20,
            ElevatedButton(
              onPressed: _getWeightData,
              child: Text('Get Weight Data', style: buttonTextStyle),
            ),
            height20,
            _isScanning
                ? CircularProgressIndicator() // Show loading when scanning
                : ElevatedButton(
                    onPressed: _startScan,
                    child: Text('Start Scan', style: buttonTextStyle),
                  ),
            height20,
            Expanded(
              child: ListView.builder(
                itemCount: _deviceList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_deviceList[index]['name'] ?? 'Unknown', style: blackHeadingStyle),
                    subtitle: Text(_deviceList[index]['address'] ?? 'Unknown', style: blackContentStyle),
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

  // Helper function to display key-value pairs
  Widget detailsRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: label, style: blackContentStyle),
          TextSpan(text: value, style: blackHeadingStyle),
        ],
      ),
    );
  }
}
