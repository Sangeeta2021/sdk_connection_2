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




//updated
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_connection_2/utils/constants.dart';
import 'package:sdk_connection_2/widget/sizedBox.dart';

class TestScreen3 extends StatefulWidget {
  const TestScreen3({super.key});

  @override
  State<TestScreen3> createState() => _TestScreen3State();
}

class _TestScreen3State extends State<TestScreen3> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';
  String _weightCharacteristicUuid = '';  // To store the weight characteristic UUID
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

    await _startScan();
  }

  Future<void> _startScan() async  {
    var state = await flutterBlue.state.first;
    if (state != BluetoothState.on) {
      print("Bluetooth is not on");
      return;
    }

    setState(() {
      _deviceList.clear();
    });

    try {
      await platform.invokeMethod('startScan');
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
      print("Weight Data Retrieved: $result");
      setState(() {
        _weightData = result;
      });
    } catch (e) {
      print("Error getting weight data: $e");
      setState(() {
        _weightData = "Failed to retrieve weight data.";
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

      case "onServicesDiscovered":
        Map<String, dynamic> serviceInfo = Map<String, dynamic>.from(call.arguments);
        print("Discovered Services and Characteristics: $serviceInfo");

        String weightUuid = _extractWeightUuid(serviceInfo);
        if (weightUuid.isNotEmpty) {
          setState(() {
            _weightCharacteristicUuid = weightUuid;
          });
          print("Weight UUID found: $_weightCharacteristicUuid");
        }

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

  String _extractWeightUuid(Map<String, dynamic> serviceInfo) {
    // Loop through the services and their characteristics
    for (var serviceUuid in serviceInfo.keys) {
      var characteristics = serviceInfo[serviceUuid];
      for (var characteristic in characteristics) {
        if (characteristic.toString().contains("weight")) {
          return characteristic;
        }
      }
    }
    return 'No weight uuid is found';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade200,
        centerTitle: true,
        title: Text('BLE SDK Connection, Home Screen', style: appBarTextStyle),
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
            ElevatedButton(
              onPressed: _getWeightData,
              child: Text('Get Weight Data', style: buttonTextStyle),
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
}
