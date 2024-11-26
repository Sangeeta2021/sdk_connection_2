
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sdk_connection_2/utils/constants.dart';
// import 'package:sdk_connection_2/widget/sizedBox.dart';

// class TestScreen2 extends StatefulWidget {
//   const TestScreen2({super.key});

//   @override
//   State<TestScreen2> createState() => _TestScreen2State();
// }

// class _TestScreen2State extends State<TestScreen2> {
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

//   // Method to check and request permissions
//   Future<void> _checkPermissions() async {
//     // Check Bluetooth and location permissions
//     PermissionStatus bluetoothScanStatus = await Permission.bluetoothScan.status;
//     PermissionStatus bluetoothConnectStatus = await Permission.bluetoothConnect.status;
//     PermissionStatus locationStatus = await Permission.locationWhenInUse.status;

//     // Request permissions if not already granted
//     if (!bluetoothScanStatus.isGranted) {
//       await Permission.bluetoothScan.request();
//     }

//     if (!bluetoothConnectStatus.isGranted) {
//       await Permission.bluetoothConnect.request();
//     }

//     if (!locationStatus.isGranted) {
//       await Permission.locationWhenInUse.request();
//     }

//     // Verify permissions after requests
//     if (await Permission.bluetoothScan.isGranted &&
//         await Permission.bluetoothConnect.isGranted &&
//         await Permission.locationWhenInUse.isGranted) {
//       // Start scanning once permissions are granted
//       await _startScan();
//     } else {
//       print("Required permissions are not granted.");
//     }
//   }

//   // Method to start scanning for devices
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

//     print("Starting FlutterBlue scan...");
//     flutterBlue.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         setState(() {
//           _deviceList.add({
//             'name': result.device.name,
//             'address': result.device.id.toString(),
//           });
//         });
//       }
//     });

//     flutterBlue.startScan(timeout: Duration(seconds: 5));
//   }

//   // Method to connect to a selected device
//   Future<void> _connectToDevice(String deviceAddress) async {
//   try {
//     BluetoothDevice? device;

//     // Check if the device is in the connected devices list
//     List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;

//     // Find the device by address in the connected devices list
//     for (var connectedDevice in connectedDevices) {
//       if (connectedDevice.id.toString() == deviceAddress) {
//         device = connectedDevice;
//         break; // Device found, break out of the loop
//       }
//     }

//     if (device == null) {
//       // If the device is not found, handle accordingly
//       print("Device not found.");
//       setState(() {
//         _deviceName = "Device not found";
//       });
//     } else {
//       // Connect to the device if found
//       await device.connect();
//       setState(() {
//         _deviceName = device!.name;
//       });
//       print("Connected to device: ${device.name}");
//     }
//   } catch (e) {
//     print("Error connecting to device: $e");
//     setState(() {
//       _deviceName = "Failed to connect";
//     });
//   }
// }



//   // Method to get weight data
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

//   // Native method call handler
//   Future<void> _handleNativeMethodCall(MethodCall call) async {
//     switch (call.method) {
//       case "onDeviceFound":
//         Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
//         setState(() {
//           _deviceList.add(deviceInfo);
//         });
//         break;
//       case "onDeviceDetailsReceived":
//         Map<String, String> serviceInfo = Map<String, String>.from(call.arguments);
//         print("Service UUID: ${serviceInfo['serviceUuid']}, Characteristic UUID: ${serviceInfo['characteristicUuid']}");
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
//         title: Text('BLE SDK Connection, Test Screen 2', style: appBarTextStyle),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             detailsRow("Connected Device:  ", _deviceName),
//             height20,
//             detailsRow("Weight Data:  ", _weightData),
//             height20,
//             ElevatedButton(
//               onPressed: _getWeightData,
//               child: Text('Get Weight Data', style: buttonTextStyle),
//             ),
//             height20,
//             ElevatedButton(
//               onPressed: () async {
//                 if (_deviceList.isNotEmpty) {
//                   await _connectToDevice(_deviceList.first['address']!);
//                 }
//               },
//               child: Text('Connect to Device', style: buttonTextStyle),
//             ),
//             height20,
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _deviceList.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(
//                       _deviceList[index]['name']!,
//                       style: blackHeadingStyle,
//                     ),
//                     subtitle: Text(
//                       _deviceList[index]['address']!,
//                       style: blackContentStyle,
//                     ),
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
//     return RichText(
//       text: TextSpan(
//         children: [
//           TextSpan(text: ques, style: blackContentStyle),
//           TextSpan(text: res, style: blackHeadingStyle),
//         ],
//       ),
//     );
//   }
// }




//**************8updated code  with updated java file for resolving uuid issue */
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_connection_2/utils/colors.dart';
import 'package:sdk_connection_2/utils/constants.dart';

class TestScreen2 extends StatefulWidget {
  @override
  _TestScreen2State createState() => _TestScreen2State();
}

class _TestScreen2State extends State<TestScreen2> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> _deviceList = [];
  String _outputData = '';
  bool isScanning = false;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? weightCharacteristic;
  String _deviceName = "Not Connected";

  // Checking permissions and starting the scan
  // Future<void> _checkPermissionsAndStartScan() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.bluetoothScan,
  //     Permission.bluetoothConnect,
  //     Permission.location,
  //   ].request();

  //   if (statuses[Permission.bluetoothScan]?.isGranted == true &&
  //       statuses[Permission.bluetoothConnect]?.isGranted == true &&
  //       statuses[Permission.location]?.isGranted == true) {
  //     _startScan();
  //   } else {
  //     setState(() {
  //       _outputData = "Permissions denied. Please grant permissions.";
  //     });
  //   }
  // }


  Future<void> _checkPermissionsAndStartScan() async {
  // Request required permissions
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location, // For backward compatibility with Android < 12
  ].request();

  if (statuses.values.every((status) => status.isGranted)) {
    _startScan();
  } else if (statuses.values.any((status) => status.isPermanentlyDenied)) {
    // Open app settings to enable permissions manually
    await openAppSettings();
    setState(() {
      _outputData = "Please enable permissions from the app settings.";
    });
  } else {
    setState(() {
      _outputData = "Permissions denied. Please grant permissions.";
    });
  }
}


  // Start scanning for Bluetooth devices
  // Future<void> _startScan() async {
  //   if (isScanning) return;

  //   setState(() {
  //     _deviceList.clear();
  //     isScanning = true;
  //   });

  //   flutterBlue.scanResults.listen((results) {
  //     for (ScanResult result in results) {
  //       if (!_deviceList.any((device) => device.id == result.device.id)) {
  //         setState(() {
  //           _deviceList.add(result.device);
  //         });
  //       }
  //     }
  //   });

  //   flutterBlue.startScan(timeout: const Duration(seconds: 5)).whenComplete(() {
  //     setState(() {
  //       isScanning = false;
  //     });
  //   });
  // }


  Future<void> _startScan() async {
  if (isScanning) return;

  // Check if Bluetooth is enabled
  bool isOn = await flutterBlue.isOn;
  if (!isOn) {
    setState(() {
      _outputData = "Bluetooth is off. Please enable Bluetooth.";
    });
    return;
  }

  setState(() {
    _deviceList.clear();
    isScanning = true;
  });

  // Start scanning for devices
  flutterBlue.scanResults.listen((results) {
    for (ScanResult result in results) {
      if (!_deviceList.any((device) => device.id == result.device.id)) {
        setState(() {
          _deviceList.add(result.device);
        });
      }
    }
  });

  flutterBlue.startScan(timeout: const Duration(seconds: 5)).whenComplete(() {
    setState(() {
      isScanning = false;
    });
  });
}


  // Stop scanning for devices
  Future<void> _stopScan() async {
    if (isScanning) {
      await flutterBlue.stopScan();
      setState(() {
        isScanning = false;
      });
    }
  }

  // Connect to the device and fetch UUIDs and weight data
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();

      setState(() {
        _deviceName = device.name.isNotEmpty ? device.name : "Unknown Device";
      });

      // Fetch UUIDs once the device is connected
      await _fetchUUIDs(device);

      // Once connected, get weight data
      _getWeightData();
    } catch (e) {
      setState(() {
        _deviceName = "Failed to connect: $e";
      });
    }
  }

  // Fetch UUIDs dynamically after the device is connected
  Future<void> _fetchUUIDs(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      for (BluetoothService service in services) {
        _outputData += '\nService UUID: ${service.uuid}';

        for (BluetoothCharacteristic characteristic in service.characteristics) {
          _outputData += '\n  Characteristic UUID: ${characteristic.uuid}';

          // Identify the characteristic for weight data (based on BLE specs or your device's documentation)
          if (characteristic.properties.read && characteristic.properties.notify) {
            weightCharacteristic = characteristic;
          }
        }
      }

      setState(() {
        _outputData += '\nService discovery complete. Ready to fetch weight data.';
      });

      if (weightCharacteristic != null) {
        _getWeightData();
      } else {
        setState(() {
          _outputData += '\nNo weight characteristic found.';
        });
      }
    } catch (e) {
      setState(() {
        _outputData = 'Failed to discover services: $e';
      });
    }
  }

  // Get weight data from the connected device
  Future<void> _getWeightData() async {
    try {
      if (weightCharacteristic == null) return;

      // Enable notifications for real-time data updates
      await weightCharacteristic!.setNotifyValue(true);

      weightCharacteristic!.value.listen((data) {
        // Convert raw byte data to weight (customize based on BLE device specifications)
        final weight = _parseWeightData(data);
        setState(() {
          _outputData = 'Weight: $weight kg';
        });
      });
    } catch (e) {
      setState(() {
        _outputData = 'Failed to fetch weight data: $e';
      });
    }
  }

  double _parseWeightData(List<int> data) {
    // Example: Parse data into a readable format
    if (data.isNotEmpty) {
      return data[0] / 10; // Customize based on your device's data format
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        centerTitle: true,
        title: const Text('SDK Connection 2, Test screen2', style: appBarTextStyle,),
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.stop : Icons.search),
            onPressed: isScanning ? _stopScan : _checkPermissionsAndStartScan,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _deviceList.length,
              itemBuilder: (context, index) {
                final device = _deviceList[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
                  subtitle: Text(device.id.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToDevice(device),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(
                _outputData,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
