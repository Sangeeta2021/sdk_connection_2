// //get list of all available devices
// // able to connect to the devices
// // getting list of all uuids
// //copy of TestScreen to check the uuids & identify which one is for weight
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sdk_connection_2/utils/constants.dart';
// import 'package:sdk_connection_2/widget/sizedBox.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
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
//   try {
//     print("Invoking getWeightData method...");
//     final result = await platform.invokeMethod('getWeightData');
//     print("Result from native: $result");

//     setState(() {
//       _weightData = result;
//       print("Your measured weight is: $result");
//     });
//   } on PlatformException catch (e) {
//     print("PlatformException occurred: ${e.message}");
//     setState(() {
//       _weightData = "Failed to get weight: ${e.message}";
//     });
//   } catch (e) {
//     print("Unexpected error: $e");
//     setState(() {
//       _weightData = "Failed to get weight: Unexpected error.";
//     });
//   }
// }


// Future<void> _handleNativeMethodCall(MethodCall call) async {
//   switch (call.method) {
//     case "onDeviceFound":
//       // Handle device discovery
//       Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
//       setState(() {
//         _deviceList.add(deviceInfo);
//       });
//       break;

//     case "onServicesDiscovered":
//       // Handle services and characteristics discovery
//       Map<String, dynamic> serviceInfo = Map<String, dynamic>.from(call.arguments);
//       print("Discovered Services and Characteristics: $serviceInfo");

//       // Log and set the first discovered service and characteristic (for display/debugging purposes)
//       final serviceUuid = serviceInfo.keys.first; // Get the first service UUID
//       final characteristicUuid = serviceInfo[serviceUuid][0]; // Get the first characteristic UUID
//       setState(() {
//         _weightData = "Service: $serviceUuid, Characteristic: $characteristicUuid";
//       });

//       // Log testing of each UUID (optional)
//       for (var service in serviceInfo.entries) {
//         final serviceId = service.key;
//         for (var charId in service.value) {
//           print("Testing UUIDs: Service: $serviceId, Characteristic: $charId");
//         }
//       }
//       break;

//     case "onCharacteristicTest":
//       // Handle UUID testing logs
//       print("Testing UUIDs: ${call.arguments}");
//       break;

//     case "onWeightDataReceived":
//       // Handle real-time weight data updates
//       setState(() {
//         _weightData = call.arguments;
//       });
//       break;

//     default:
//       // Handle unknown method calls
//       throw MissingPluginException("Not implemented: ${call.method}");
//   }
// }


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
//             // ElevatedButton(
//             //   onPressed: () async {
//             //     if (_deviceList.isNotEmpty) {
//             //       await _connectToDevice(_deviceList.first['address']!);
//             //     }
//             //   },
//             //   child: Text('Connect to Device', style: buttonTextStyle,),
//             // ),
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










//******************************************************************************/
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sdk_connection_2/utils/constants.dart';
// import 'package:sdk_connection_2/widget/sizedBox.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
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
//       await platform.invokeMethod('startScan');
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
//   try {
//     print("Invoking getWeightData method...");
//     final result = await platform.invokeMethod('getWeightData');
//     print("Result from native: $result");

//     setState(() {
//       _weightData = result;
//       print("You measured weight is: $result");
//     });
//   } on PlatformException catch (e) {
//     print("PlatformException occurred: ${e.message}");
//     setState(() {
//       _weightData = "Failed to get weight: ${e.message}";
//     });
//   } catch (e) {
//     print("Unexpected error: $e");
//     setState(() {
//       _weightData = "Failed to get weight: Unexpected error.";
//     });
//   }
// }


// // updated one
// Future<void> _handleNativeMethodCall(MethodCall call) async {
//   switch (call.method) {
//     case "onDeviceFound":
//       // Handle device discovery
//       Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
//       setState(() {
//         _deviceList.add(deviceInfo);
//       });
//       break;

//     case "onServicesDiscovered":
//       // Handle services and characteristics discovery
//       Map<String, dynamic> serviceInfo = Map<String, dynamic>.from(call.arguments);
//       print("Discovered Services and Characteristics: $serviceInfo");

//       // Prepare a string to display the UUIDs of services and characteristics
//       String uuids = "";
//       serviceInfo.forEach((serviceUuid, characteristics) {
//         uuids += "Service UUID: $serviceUuid\n";
//         for (var characteristic in characteristics) {
//           uuids += "  Characteristic UUID: $characteristic\n";
//         }
//       });

//       setState(() {
//         _weightData = uuids;  // Display UUIDs in the weight data field for now
//       });
//       break;

//     case "onCharacteristicTest":
//       // Handle UUID testing logs
//       print("Testing UUIDs: ${call.arguments}");
//       break;

//     case "onWeightDataReceived":
//       // Handle real-time weight data updates
//       setState(() {
//         _weightData = call.arguments;
//       });
//       break;

//     default:
//       // Handle unknown method calls
//       throw MissingPluginException("Not implemented: ${call.method}");
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.purple.shade200,
//         centerTitle: true,
//         title: Text('BLE SDK Connection, Home Screen', style: appBarTextStyle),
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



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_connection_2/utils/constants.dart';
import 'package:sdk_connection_2/widget/sizedBox.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<void> _startScan() async {
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
    if (_weightCharacteristicUuid.isEmpty) {
      setState(() {
        _weightData = 'Weight UUID not found!';
      });
      return;
    }

    try {
      print("Invoking getWeightData with UUID: $_weightCharacteristicUuid...");
      final result = await platform.invokeMethod('getWeightData', {'uuid': _weightCharacteristicUuid});
      print("Result from native: $result");

      setState(() {
        _weightData = result;
        print("You measured weight is: $result");
      });
    } on PlatformException catch (e) {
      print("PlatformException occurred: ${e.message}");
      setState(() {
        _weightData = "Failed to get weight: ${e.message}";
      });
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        _weightData = "Failed to get weight: Unexpected error.";
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

        // Extract the weight characteristic UUID from the discovered services
        String weightUuid = _extractWeightUuid(serviceInfo);
        if (weightUuid.isNotEmpty) {
          setState(() {
            _weightCharacteristicUuid = weightUuid;
          });
          print("Weight UUID found: $_weightCharacteristicUuid");
        }

        break;

      case "onCharacteristicTest":
        print("Testing UUIDs: ${call.arguments}");
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

  // String _extractWeightUuid(Map<String, dynamic> serviceInfo) {
  //   // Logic to extract the weight UUID (this is where you would look for a known pattern or UUID)
  //   for (var serviceUuid in serviceInfo.keys) {
  //     var characteristics = serviceInfo[serviceUuid];
  //     for (var characteristic in characteristics) {
  //       if (characteristic.toString().contains("weight")) {  // Replace with your own condition
  //         return characteristic;
  //       }
  //     }
  //   }
  //   return 'no weight UUID is found'; // Return an empty string if no weight UUID is found
  // }


  String _extractWeightUuid(Map<String, dynamic> serviceInfo) {
  // Check for custom service UUID and characteristics
  for (var serviceUuid in serviceInfo.keys) {
    var characteristics = serviceInfo[serviceUuid];
    
    //using set of uuids which i am getting from output
    if (serviceUuid == "00001801-0000-1000-8000-00805f9b34fb") {
      for (var characteristic in characteristics) {
        // If the characteristic matches any of the known weight-related UUIDs
        if (
          // characteristic == "0000ffb1-0000-1000-8000-00805f9b34fb" ||
          //   characteristic == "0000ffb2-0000-1000-8000-00805f9b34fb" ||
            characteristic == "00002a05-0000-1000-8000-00805f9b34fb") {
          return characteristic;  // Return the weight characteristic UUID
        }
      }
    }
  }
  return 'No weight uuid is found'; // Return an empty string if no weight UUID is found
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
