// //updation in screen 3 code
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sdk_connection_2/utils/colors.dart';
// import 'package:sdk_connection_2/utils/constants.dart';
// import 'package:sdk_connection_2/widget/sizedBox.dart';

// class TestScreen4 extends StatefulWidget {
//   const TestScreen4({super.key});

//   @override
//   State<TestScreen4> createState() => _TestScreen4State();
// }

// class _TestScreen4State extends State<TestScreen4> {
//   static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

//   String _weightData = 'No data received yet';
//   String _deviceName = 'No device connected';
//   String _weightCharacteristicUuid = '';
//   String _weightServiceUuid = '';
//   List<Map<String, String>> _deviceList = [];
//   FlutterBlue flutterBlue = FlutterBlue.instance;

//   // Known weight-related UUID patterns (add more if needed)
//   final List<String> _weightUuidPatterns = [
//     // 'weight',
//     // 'mass',
//     // 'scale',
//     // '1531', // Based on your specific UUIDs
//     // '1532',
//     // '1534',
// // updated new uuids
//  "weight", "mass", "scale", 
//         "1531", "1532", "1534", 
//         "ffb1", "ffb2", "ffb3"
//   ];

//   @override
//   void initState() {
//     super.initState();
//     platform.setMethodCallHandler(_handleNativeMethodCall);
//     _checkPermissions();
//   }

//   Future<void> _checkPermissions() async {
//     try {
//       // Request necessary permissions
//       await [
//         Permission.bluetooth,
//         Permission.bluetoothScan,
//         Permission.bluetoothConnect,
//         Permission.locationWhenInUse,
//       ].request();

//       await _startScan();
//     } catch (e) {
//       print("Permission error: $e");
//       setState(() {
//         _deviceName = "Permission error: $e";
//       });
//     }
//   }

//   Future<void> _startScan() async {
//     var state = await flutterBlue.state.first;
//     if (state != BluetoothState.on) {
//       print("Bluetooth is not on");
//       setState(() {
//         _deviceName = "Bluetooth is not enabled";
//       });
//       return;
//     }

//     setState(() {
//       _deviceList.clear();
//     });

//     try {
//       await platform.invokeMethod('startScan');
//       print('Scanning for devices...');
//     } on PlatformException catch (e) {
//       print("Failed to start scan: ${e.message}");
//       setState(() {
//         _deviceName = "Scan failed: ${e.message}";
//       });
//     }
//   }

//   Future<void> _connectToDevice(String deviceAddress) async {
//     try {
//       final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
//       print("Device connected to: $result");
//       setState(() {
//         _deviceName = result;
//       });

//       // After connecting, fetch services
//       await _discoverServices(deviceAddress);
//     } on PlatformException catch (e) {
//       setState(() {
//         _deviceName = "Failed to connect: ${e.message}";
//       });
//     }
//   }

//  Future<void> _discoverServices(String deviceAddress) async {
//   try {
//     final serviceInfo = await platform.invokeMethod<Map<String, dynamic>>('discoverServices', {'deviceAddress': deviceAddress});
//     if (serviceInfo != null) {
//       print("Discovered Services: $serviceInfo");
//       var result = _findWeightCharacteristic(serviceInfo);
//       if (result != null) {
//         setState(() {
//           _weightServiceUuid = result['serviceUuid']!;
//           _weightCharacteristicUuid = result['characteristicUuid']!;
//         });
//         print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");

//         // Enable notifications for the weight characteristic
//         await _enableNotifications(deviceAddress, _weightCharacteristicUuid);
//       } else {
//         setState(() {
//           _weightData = "No weight characteristic found";
//         });
//         print("No weight characteristic found");
//       }
//     } else {
//       setState(() {
//         _deviceName = "Service discovery returned null";
//       });
//       print("Service discovery returned null");
//     }
//   } on PlatformException catch (e) {
//     setState(() {
//       _deviceName = "Service discovery failed: ${e.message}";
//     });
//     print("Failed to discover services: ${e.message}");
//   }
// }

// Future<void> _enableNotifications(String deviceAddress, String characteristicUuid) async {
//   try {
//     await platform.invokeMethod('enableNotifications', {
//       'deviceAddress': deviceAddress,
//       'characteristicUuid': characteristicUuid,
//     });
//     print("Notifications enabled for characteristic: $characteristicUuid");
//   } on PlatformException catch (e) {
//     print("Failed to enable notifications: ${e.message}");
//   }
// }



//   Future<void> _getWeightData() async {
//     if (_weightCharacteristicUuid.isEmpty || _weightServiceUuid.isEmpty) {
//       setState(() {
//         _weightData = "Weight characteristic not found. Reconnect device.";
//       });
//       return;
//     }

//     try {
//       final result = await platform.invokeMethod('getWeightData', {
//         'serviceUuid': _weightServiceUuid,
//         'characteristicUuid': _weightCharacteristicUuid
//       });
//       print("Weight Data Retrieved: $result");
//       setState(() {
//         _weightData = result ?? "No weight data";
//       });
//     } catch (e) {
//       print("Error getting weight data: $e");
//       setState(() {
//         _weightData = "Failed to retrieve weight data: $e";
//       });
//     }
//   }


 
//  Future<void> _handleNativeMethodCall(MethodCall call) async {
//   switch (call.method) {
//     case "onDeviceFound":
//       Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
//       setState(() {
//         _deviceList.add(deviceInfo);
//       });
//       break;

//     case "onServicesDiscovered":
//       Map<String, dynamic> serviceInfo = Map<String, dynamic>.from(call.arguments);
//       print("Discovered Services and Characteristics: $serviceInfo");

//       var result = _findWeightCharacteristic(serviceInfo);
//       if (result != null) {
//         setState(() {
//           _weightServiceUuid = result['serviceUuid']!;
//           _weightCharacteristicUuid = result['characteristicUuid']!;
//         });
//         print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");

//         // Enable notifications for the weight characteristic
//         await _enableNotifications(result['deviceAddress']!, _weightCharacteristicUuid);
//       } else {
//         print("No weight characteristic found");
//       }
//       break;

//     case "onWeightDataReceived":
//       setState(() {
//         _weightData = call.arguments ?? "No data";
//       });
//       break;

//     default:
//       throw MissingPluginException("Not implemented: ${call.method}");
//   }
// }


//   Map<String, String>? _findWeightCharacteristic(Map<String, dynamic> serviceInfo) {
//     for (var serviceUuid in serviceInfo.keys) {
//       var characteristics = serviceInfo[serviceUuid];
      
//       for (var characteristic in characteristics) {
//         // Convert to string to handle potential type variations
//         String charString = characteristic.toString().toLowerCase();
        
//         // Check against known weight-related patterns
//         for (var pattern in _weightUuidPatterns) {
//           if (charString.contains(pattern)) {
//             return {
//               'serviceUuid': serviceUuid,
//               'characteristicUuid': characteristic.toString()
//             };
//           }
//         }
//       }
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: themeColor,
//         centerTitle: true,
//         title: Text('SDK Connection, Screen4', style: appBarTextStyle),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _startScan,
//           )
//         ],
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
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: _getWeightData,
//                   child: Text('Get Weight Data', style: buttonTextStyle),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: _startScan,
//                   child: Text('Rescan Devices', style: buttonTextStyle),
//                 ),
//               ],
//             ),
//             height20,
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _deviceList.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_deviceList[index]['name']!, style: blackHeadingStyle),
//                     subtitle: Text(_deviceList[index]['address']!, style: blackContentStyle),
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



//*********code with updated uuids*************************/
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sdk_connection_2/utils/colors.dart';
// import 'package:sdk_connection_2/utils/constants.dart';
// import 'package:sdk_connection_2/widget/sizedBox.dart';

// class TestScreen4 extends StatefulWidget {
//   const TestScreen4({super.key});

//   @override
//   State<TestScreen4> createState() => _TestScreen4State();
// }

// class _TestScreen4State extends State<TestScreen4> {
//   static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

//   String _weightData = 'No data received yet';
//   String _deviceName = 'No device connected';
//   String _weightCharacteristicUuid = '0000ffb2-0000-1000-8000-00805f9b34fb'; // weight characteristic
//   String _weightServiceUuid = '0000ffb0-0000-1000-8000-00805f9b34fb'; // UUID for weight service
//   List<Map<String, String>> _deviceList = [];
//   FlutterBlue flutterBlue = FlutterBlue.instance;

//   @override
//   void initState() {
//     super.initState();
//     platform.setMethodCallHandler(_handleNativeMethodCall);
//     _checkPermissions();
//   }

//   Future<void> _checkPermissions() async {
//     try {
//       // Request necessary permissions
//       await [
//         Permission.bluetooth,
//         Permission.bluetoothScan,
//         Permission.bluetoothConnect,
//         Permission.locationWhenInUse,
//       ].request();

//       await _startScan();
//     } catch (e) {
//       print("Permission error: $e");
//       setState(() {
//         _deviceName = "Permission error: $e";
//       });
//     }
//   }

//   Future<void> _startScan() async {
//     var state = await flutterBlue.state.first;
//     if (state != BluetoothState.on) {
//       print("Bluetooth is not on");
//       setState(() {
//         _deviceName = "Bluetooth is not enabled";
//       });
//       return;
//     }

//     setState(() {
//       _deviceList.clear();
//     });

//     try {
//       await platform.invokeMethod('startScan');
//       print('Scanning for devices...');
//     } on PlatformException catch (e) {
//       print("Failed to start scan: ${e.message}");
//       setState(() {
//         _deviceName = "Scan failed: ${e.message}";
//       });
//     }
//   }

//   Future<void> _connectToDevice(String deviceAddress) async {
//     print("********************_connectToDevice clicked*************************");
//     try {
//       final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
//       print("Device connected to: $result");
//       setState(() {
//         _deviceName = result;
//       });

//       // After connecting, fetch services
//       await _discoverServices(deviceAddress);
//     } on PlatformException catch (e) {
//       setState(() {
//         _deviceName = "Failed to connect: ${e.message}";
//       });
//     }
//   }

//   Future<void> _discoverServices(String deviceAddress) async {
//     try {
//       final serviceInfo = await platform.invokeMethod<Map<String, dynamic>>('discoverServices', {'deviceAddress': deviceAddress});
//       print("********************service info: $serviceInfo*****************************");
//       if (serviceInfo != null) {
//         print("Discovered Services: $serviceInfo");

//         // Use known UUIDs directly for matching
//         var result = _findWeightCharacteristic(serviceInfo);
//         if (result != null) {
//           setState(() {
//             _weightServiceUuid = result['serviceUuid']!;
//             _weightCharacteristicUuid = result['characteristicUuid']!;
//           });
//           print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");

//           // Enable notifications for the weight characteristic
//           print("Calling _enableNotifications with deviceAddress: $deviceAddress and characteristicUuid: $result['characteristicUuid']!");

//           await _enableNotifications(deviceAddress, _weightCharacteristicUuid);
//         } else {
//           setState(() {
//             _weightData = "No weight characteristic found";
//           });
//           print("No weight characteristic found");
//         }
//       } else {
//         setState(() {
//           _deviceName = "Service discovery returned null";
//         });
//         print("Service discovery returned null");
//       }
//     } on PlatformException catch (e) {
//       setState(() {
//         _deviceName = "Service discovery failed: ${e.message}";
//       });
//       print("Failed to discover services: ${e.message}");
//     }
//   }


//   Future<void> _getWeightData() async {
//     if (_weightCharacteristicUuid.isEmpty || _weightServiceUuid.isEmpty) {
//       setState(() {
//         _weightData = "Weight characteristic not found. Reconnect device.";
//       });
//       return;
//     }

//     try {
//       final result = await platform.invokeMethod('getWeightData', {
//         'serviceUuid': _weightServiceUuid,
//         'characteristicUuid': _weightCharacteristicUuid
//       });
//       print("Weight Data Retrieved: $result");
//       setState(() {
//         _weightData = result ?? "No weight data";
//       });
//     } catch (e) {
//       print("Error getting weight data: $e");
//       setState(() {
//         _weightData = "Failed to retrieve weight data: $e";
//       });
//     }
//   }

// //updated one to check the raw data

// Future<void> _enableNotifications(String deviceAddress, String characteristicUuid) async {

//   try {
//     print("Starting _enableNotifications for device: $deviceAddress and characteristic: $characteristicUuid");

//     // Get the connected devices
//     var connectedDevices = await flutterBlue.connectedDevices;
//     print("Connected devices: ${connectedDevices.map((d) => d.id.id).toList()}");

//     // Find the device with the matching address
//     BluetoothDevice? device;
//     for (var connectedDevice in connectedDevices) {
//       if (connectedDevice.id.id == deviceAddress) {
//         device = connectedDevice;
//         break;
//       }
//     }

//     if (device == null) {
//       print("Device with address $deviceAddress not found in connected devices.");
//       setState(() {
//         _deviceName = "Device not connected";
//       });
//       return;
//     }
//     print("Found device: ${device.name}");

//     // Discover services of the device
//     var services = await device.discoverServices();
//     print("Discovered services: ${services.map((s) => s.uuid.toString()).toList()}");

//     BluetoothCharacteristic? targetCharacteristic;

//     // Find the target characteristic by UUID
//     for (var service in services) {
//       print("Checking service: ${service.uuid}");
//       for (var characteristic in service.characteristics) {
//         print("Found characteristic: ${characteristic.uuid}");
//         if (characteristic.uuid.toString() == characteristicUuid) {
//           targetCharacteristic = characteristic;
//           break;
//         }
//       }
//       if (targetCharacteristic != null) break;
//     }

//     if (targetCharacteristic == null) {
//       print("Characteristic with UUID $characteristicUuid not found.");
//       setState(() {
//         _weightData = "Characteristic not found";
//       });
//       return;
//     }
//     print("Found target characteristic: ${targetCharacteristic.uuid}");

//     // Enable notifications for the characteristic
//     await targetCharacteristic.setNotifyValue(true);
//     bool isNotifying = await targetCharacteristic.isNotifying;
//     print("Notifications enabled for characteristic: ${targetCharacteristic.uuid}, isNotifying: $isNotifying");

//     if (!isNotifying) {
//       print("Failed to enable notifications for characteristic: ${targetCharacteristic.uuid}");
//       setState(() {
//         _weightData = "Failed to enable notifications.";
//       });
//       return;
//     }

//     // Listen for notifications
//     targetCharacteristic.value.listen((value) {
//       print("Raw data received: $value");

//       // Assuming the weight data is a 4-byte float (adjust if necessary)
//       if (value.length >= 4) {
//         var weight = ByteData.sublistView(Uint8List.fromList(value)).getFloat32(0, Endian.little);
//         setState(() {
//           _weightData = "${weight.toStringAsFixed(2)} kg";  // Update the weight data on the screen
//         });
//         print("Processed weight: $_weightData");
//       } else {
//         print("Unexpected data format: $value");
//       }
//     }).onError((error) {
//       print("Error in notification listener: $error");
//     });

//   } catch (e) {
//     print("Error in _enableNotifications: ${e.toString()}");
//     setState(() {
//       _weightData = "Error enabling notifications: ${e.toString()}";
//     });
//   }
// }

//   //updated one
//   Future<void> _handleNativeMethodCall(MethodCall call) async {
//   switch (call.method) {
//     case "onDeviceFound":
//       Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
//       setState(() {
//         _deviceList.add(deviceInfo);
//       });
//       break;

//     case "onServicesDiscovered":
//       Map<String, dynamic> serviceInfo = Map<String, dynamic>.from(call.arguments);
//       print("Discovered Services and Characteristics: $serviceInfo");

//       var result = _findWeightCharacteristic(serviceInfo);
//       print("*******************result for _findWeightCharacteristic: $result********************");
//       if (result != null) {
//         setState(() {
//           _weightServiceUuid = result['serviceUuid']!;
//           _weightCharacteristicUuid = result['characteristicUuid']!;
//         });
//         print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");

//         // Add debug log to ensure we are about to call _enableNotifications
//         print("Attempting to enable notifications for characteristic: $_weightCharacteristicUuid");

//         // Enable notifications for the weight characteristic
//         await _enableNotifications(result['deviceAddress']!, _weightCharacteristicUuid);
//       } else {
//         print("No weight characteristic found");
//       }
//       break;

//     case "onWeightDataReceived":
//       setState(() {
//         _weightData = call.arguments ?? "No data";
//       });
//       break;

//     default:
//       throw MissingPluginException("Not implemented: ${call.method}");
//   }
// }

//   Map<String, String>? _findWeightCharacteristic(Map<String, dynamic> serviceInfo) {
//   // Assuming that serviceInfo contains a list of services and characteristics
//   for (var service in serviceInfo['services']) {
//     if (service['uuid'] == '0000ffb0-0000-1000-8000-00805f9b34fb') { // Example service UUID
//       for (var characteristic in service['characteristics']) {
//         if (characteristic['uuid'] == '0000ffb2-0000-1000-8000-00805f9b34fb') { // Example characteristic UUID
//           return {
//             'deviceAddress': serviceInfo['deviceAddress'],
//             'serviceUuid': service['uuid'],
//             'characteristicUuid': characteristic['uuid'],
//           };
//         }else{
//           print("*********************_findWeightCharacteristic char uuid not matched***************");
//         }
//       }
//     }else{
//       print("***********************8_findWeightCharacteristic service uuid not matched********");
//     }
//   }
//   print("************************no matching characteristic is found************************");
//   return null; // Return null if no matching characteristic is found
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: themeColor,
//         centerTitle: true,
//         title: Text('SDK Connection, Screen4', style: appBarTextStyle),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _startScan,
//           )
//         ],
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
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: _getWeightData,
//                   child: Text('Get Weight Data', style: buttonTextStyle),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: _startScan,
//                   child: Text('Rescan Devices', style: buttonTextStyle),
//                 ),
//               ],
//             ),
//             height20,
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _deviceList.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_deviceList[index]['name']!, style: blackHeadingStyle),
//                     subtitle: Text(_deviceList[index]['address']!, style: blackContentStyle),
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



//****updated one with the solution of connect to device button */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_connection_2/utils/colors.dart';
import 'package:sdk_connection_2/utils/constants.dart';
import 'package:sdk_connection_2/widget/sizedBox.dart';

class TestScreen4 extends StatefulWidget {
  const TestScreen4({super.key});

  @override
  State<TestScreen4> createState() => _TestScreen4State();
}

class _TestScreen4State extends State<TestScreen4> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';
  String _weightCharacteristicUuid = '0000ffb2-0000-1000-8000-00805f9b34fb'; // weight characteristic
  String _weightServiceUuid = '0000ffb0-0000-1000-8000-00805f9b34fb'; // UUID for weight service
  List<Map<String, String>> _deviceList = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleNativeMethodCall);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
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
      print("Bluetooth is not enabled");
      setState(() {
        _deviceName = "Bluetooth is not enabled";
      });
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
      setState(() {
        _deviceName = "Scan failed: ${e.message}";
      });
    }
  }

  Future<void> _connectToDevice(String deviceAddress) async {
    try {
      final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
      print("Device connected to: $result");
      setState(() {
        _deviceName = result;
      });
      print("***************_discoverServices called*********************");

      await _discoverServices(deviceAddress);
    } on PlatformException catch (e) {
      setState(() {
        _deviceName = "Failed to connect: ${e.message}";
      });
    }
  }

  Future<void> _discoverServices(String deviceAddress) async {
    try {
      final serviceInfo = await platform.invokeMethod<Map<String, dynamic>>('discoverServices', {'deviceAddress': deviceAddress});
      if (serviceInfo != null) {
        var result = _findWeightCharacteristic(serviceInfo);
        if (result != null) {
          setState(() {
            _weightServiceUuid = result['serviceUuid']!;
            _weightCharacteristicUuid = result['characteristicUuid']!;
          });
          await _enableNotifications(deviceAddress, _weightCharacteristicUuid);
        } else {
          setState(() {
            _weightData = "No weight characteristic found";
          });
        }
      } else {
        setState(() {
          _deviceName = "Service discovery returned null";
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _deviceName = "Service discovery failed: ${e.message}";
      });
    }
  }

  Future<void> _enableNotifications(String deviceAddress, String characteristicUuid) async {

  try {
    print("Starting _enableNotifications for device: $deviceAddress and characteristic: $characteristicUuid");

    // Get the connected devices
    var connectedDevices = await flutterBlue.connectedDevices;
    print("Connected devices: ${connectedDevices.map((d) => d.id.id).toList()}");

    // Find the device with the matching address
    BluetoothDevice? device;
    for (var connectedDevice in connectedDevices) {
      if (connectedDevice.id.id == deviceAddress) {
        device = connectedDevice;
        break;
      }
    }

    if (device == null) {
      print("Device with address $deviceAddress not found in connected devices.");
      setState(() {
        _deviceName = "Device not connected";
      });
      return;
    }
    print("Found device: ${device.name}");

    // Discover services of the device
    var services = await device.discoverServices();
    print("Discovered services: ${services.map((s) => s.uuid.toString()).toList()}");

    BluetoothCharacteristic? targetCharacteristic;

    // Find the target characteristic by UUID
    for (var service in services) {
      print("Checking service: ${service.uuid}");
      for (var characteristic in service.characteristics) {
        print("Found characteristic: ${characteristic.uuid}");
        if (characteristic.uuid.toString() == characteristicUuid) {
          targetCharacteristic = characteristic;
          break;
        }
      }
      if (targetCharacteristic != null) break;
    }

    if (targetCharacteristic == null) {
      print("Characteristic with UUID $characteristicUuid not found.");
      setState(() {
        _weightData = "Characteristic not found";
      });
      return;
    }
    print("Found target characteristic: ${targetCharacteristic.uuid}");

    // Enable notifications for the characteristic
    await targetCharacteristic.setNotifyValue(true);
    bool isNotifying = await targetCharacteristic.isNotifying;
    print("Notifications enabled for characteristic: ${targetCharacteristic.uuid}, isNotifying: $isNotifying");

    if (!isNotifying) {
      print("Failed to enable notifications for characteristic: ${targetCharacteristic.uuid}");
      setState(() {
        _weightData = "Failed to enable notifications.";
      });
      return;
    }

    // Listen for notifications
    targetCharacteristic.value.listen((value) {
      print("Raw data received: $value");

      // Assuming the weight data is a 4-byte float (adjust if necessary)
      if (value.length >= 4) {
        var weight = ByteData.sublistView(Uint8List.fromList(value)).getFloat32(0, Endian.little);
        setState(() {
          _weightData = "${weight.toStringAsFixed(2)} kg";  // Update the weight data on the screen
        });
        print("Processed weight: $_weightData");
      } else {
        print("Unexpected data format: $value");
      }
    }).onError((error) {
      print("Error in notification listener: $error");
    });

  } catch (e) {
    print("Error in _enableNotifications: ${e.toString()}");
    setState(() {
      _weightData = "Error enabling notifications: ${e.toString()}";
    });
  }
}

  Future<void> _getWeightData() async {
    if (_weightCharacteristicUuid.isEmpty || _weightServiceUuid.isEmpty) {
      setState(() {
        _weightData = "Weight characteristic not found. Reconnect device.";
      });
      return;
    }

    try {
      final result = await platform.invokeMethod('getWeightData', {
        'serviceUuid': _weightServiceUuid,
        'characteristicUuid': _weightCharacteristicUuid
      });
      setState(() {
        _weightData = result ?? "No weight data";
      });
    } catch (e) {
      setState(() {
        _weightData = "Failed to retrieve weight data: $e";
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
        print("************************service info: $serviceInfo********************");
        var result = _findWeightCharacteristic(serviceInfo);
        print("*********************************");
        print("***************************result for _findWeightCharacteristic is: $result*********************");
        if (result != null) {
          setState(() {
            _weightServiceUuid = result['serviceUuid']!;
            _weightCharacteristicUuid = result['characteristicUuid']!;
          });
          print("****************************_enableNotifications called*********************");
          await _enableNotifications(result['deviceAddress']!, _weightCharacteristicUuid);
        }
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

  Map<String, String>? _findWeightCharacteristic(Map<String, dynamic> serviceInfo) {
    for (var service in serviceInfo['services']) {
      if (service['uuid'] == _weightServiceUuid) {
        for (var characteristic in service['characteristics']) {
          if (characteristic['uuid'] == _weightCharacteristicUuid) {
            return {
              'deviceAddress': serviceInfo['deviceAddress'],
              'serviceUuid': service['uuid'],
              'characteristicUuid': characteristic['uuid'],
            };
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        centerTitle: true,
        title: Text('SDK Connection, Screen4', style: appBarTextStyle),
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
}
