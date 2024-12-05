//this code is to discover services  & get the uuids

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';


// class TestScreen3 extends StatefulWidget {
//   const TestScreen3({Key? key}) : super(key: key);

//   @override
//   _TestScreen3State createState() => _TestScreen3State();
// }

// class _TestScreen3State extends State<TestScreen3> {
//   static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');
//   List<Map<String, String>> scannedDevices = [];
//   List<Map<String, dynamic>> servicesAndCharacteristics = [];
//   bool permissionsGranted = false;
//   bool isScanning = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//   }

//   // Future<void> _checkPermissions() async {
//   //   try {
//   //     final result = await platform.invokeMethod('checkPermissions');
//   //     setState(() {
//   //       permissionsGranted = result;
//   //     });
//   //     if (permissionsGranted) {
//   //       _startScan();
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Error checking permissions: $e');
//   //   }
//   // }
//   Future<void> _checkPermissions() async {
//   try {
//     final result = await platform.invokeMethod('checkPermissions');
//     setState(() {
//       permissionsGranted = result;
//     });
//     if (permissionsGranted) {
//       _startScan();
//     } else {
//       debugPrint('Permissions not granted.');
//     }
//   } catch (e) {
//     debugPrint('Error checking permissions: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to check permissions: $e')),
//     );
//   }
// }

//   // Future<void> _startScan() async {
//   //   try {
//   //     setState(() {
//   //       isScanning = true;
//   //     });
//   //     await platform.invokeMethod('startScan');
//   //     platform.setMethodCallHandler((call) async {
//   //       if (call.method == 'onScanResult') {
//   //         final devices = List<Map<String, String>>.from(call.arguments);
//   //         setState(() {
//   //           scannedDevices = devices;
//   //           isScanning = false;
//   //         });
//   //       }
//   //     });
//   //   } catch (e) {
//   //     debugPrint('Error starting scan: $e');
//   //   }
//   // }
// Future<void> _startScan() async {
//   try {
//     setState(() {
//       isScanning = true;
//     });
//     await platform.invokeMethod('startScan');
//     platform.setMethodCallHandler((call) async {
//       if (call.method == 'onScanResult') {
//         final devices = List<Map<String, String>>.from(call.arguments);
//         setState(() {
//           scannedDevices = devices;
//           isScanning = false;
//         });
//       }
//     });
//   } catch (e) {
//     debugPrint('Error starting scan: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to start scan: $e')),
//     );
//     setState(() {
//       isScanning = false;
//     });
//   }
// }
//   Future<void> _connectToDevice(String address) async {
//     try {
//       await platform.invokeMethod('connectToDevice', {"deviceAddress": address});
//       _discoverServices();
//     } catch (e) {
//       debugPrint('Error connecting to device: $e');
//     }
//   }

//   Future<void> _discoverServices() async {
//     try {
//       await platform.invokeMethod('discoverServices');
//       platform.setMethodCallHandler((call) async {
//         if (call.method == 'onServicesDiscovered') {
//           final services = List<Map<String, dynamic>>.from(call.arguments);
//           setState(() {
//             servicesAndCharacteristics = services;
//           });
//         }
//       });
//     } catch (e) {
//       debugPrint('Error discovering services: $e');
//     }
//   }

//   Widget _buildDeviceList() {
//     return ListView.builder(
//       itemCount: scannedDevices.length,
//       itemBuilder: (context, index) {
//         final device = scannedDevices[index];
//         return ListTile(
//           title: Text(device['name'] ?? 'Unknown Device'),
//           subtitle: Text(device['address'] ?? ''),
//           trailing: ElevatedButton(
//             onPressed: () {
//               _connectToDevice(device['address']!);
//             },
//             child: const Text('Connect'),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildServiceList() {
//     return ListView.builder(
//       itemCount: servicesAndCharacteristics.length,
//       itemBuilder: (context, index) {
//         final service = servicesAndCharacteristics[index];
//         return ExpansionTile(
//           title: Text('Service: ${service['serviceUuid']}'),
//           children: (service['characteristics'] as List<dynamic>)
//               .map((characteristic) => ListTile(
//                     title: Text('Characteristic: ${characteristic['characteristicUuid']}'),
//                   ))
//               .toList(),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple.shade200,
//         centerTitle: true,
//         title: const Text('SDK Connection 2, Test screen3'),
//       ),
//       body: permissionsGranted
//           ? Column(
//               children: [
//                 Expanded(
//                   child: isScanning
//                       ? const Center(child: CircularProgressIndicator())
//                       : scannedDevices.isNotEmpty
//                           ? _buildDeviceList()
//                           : const Center(child: Text('No devices found.')),
//                 ),
//                 const Divider(),
//                 Expanded(
//                   child: servicesAndCharacteristics.isNotEmpty
//                       ? _buildServiceList()
//                       : const Center(child: Text('No services discovered.')),
//                 ),
//               ],
//             )
//           : const Center(child: Text('Permissions not granted.')),
//     );
//   }
// }




//updated one:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestScreen3 extends StatefulWidget {
  const TestScreen3({Key? key}) : super(key: key);

  @override
  State<TestScreen3> createState() => _TestScreen3State();
}

class _TestScreen3State extends State<TestScreen3> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

  String _weightData = 'No data received yet';
  List<Map<String, String>> _deviceList = [];
  String _connectedDevice = 'No device connected';

  Future<void> _startScan() async {
    try {
      await platform.invokeMethod('startScan');
    } on PlatformException catch (e) {
      print("Error starting scan: ${e.message}");
    }
  }

  Future<void> _connectToDevice(String deviceAddress) async {
    try {
      await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
      setState(() {
        _connectedDevice = deviceAddress;
      });
    } on PlatformException catch (e) {
      print("Error connecting to device: ${e.message}");
    }
  }

  Future<void> _getWeightData() async {
    try {
      final result = await platform.invokeMethod('getWeightData');
      setState(() {
        _weightData = result;
      });
    } on PlatformException catch (e) {
      print("Error fetching weight data: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Weight Scale")),
      body: Column(
        children: [
          Text("Connected Device: $_connectedDevice"),
          Text("Weight Data: $_weightData"),
          ElevatedButton(onPressed: _startScan, child: const Text("Start Scan")),
          ElevatedButton(onPressed: _getWeightData, child: const Text("Get Weight Data")),
        ],
      ),
    );
  }
}
