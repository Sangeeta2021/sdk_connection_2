// updated code to resolve error in discover services, modification of screen 4
// all the error resolved but getting weight still as 0kg
// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sdk_connection_2/utils/colors.dart';
// import 'package:sdk_connection_2/utils/constants.dart';
// import 'package:sdk_connection_2/widget/sizedBox.dart';

// class TestScreen5 extends StatefulWidget {
//   const TestScreen5({super.key});

//   @override
//   State<TestScreen5> createState() => _TestScreen5State();
// }

// class _TestScreen5State extends State<TestScreen5> {
//   static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

//   String _weightData = 'No data received yet';
//   String _deviceName = 'No device connected';
//   String _weightCharacteristicUuid = '00001531-1212-efde-1523-785feabcd123'; // weight characteristic
//   String _weightServiceUuid = '00001530-1212-efde-1523-785feabcd123'; // UUID for weight service
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
//     try {
//       final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
//       print("Device connected to: $result");
//       setState(() {
//         _deviceName = result;
//       });

//       // After connecting, fetch services
//       print("_discoverServices function is called............................");
//       await _discoverServices(deviceAddress);
//     } on PlatformException catch (e) {
//       setState(() {
//         _deviceName = "Failed to connect: ${e.message}";
//       });
//     }
//   }



// //updated one

// // Future<void> _discoverServices(String deviceAddress) async {
// //   try {
// //     print("////////////////////////////////////////////////////////////////////////////////");

// //     // Call the platform method to discover services
// //     final serviceInfo = await platform.invokeMethod('discoverServices', {'deviceAddress': deviceAddress});
// //     print("Service Info: $serviceInfo");

// //     // Check if serviceInfo is a String
// //     if (serviceInfo is String) {
// //       try {
// //         // Log the serviceInfo string to see its actual content
// //         print("Raw serviceInfo string: $serviceInfo");

// //         // Try to convert the string into a Map<String, dynamic> using jsonDecode
// //         final serviceInfoMap = jsonDecode(serviceInfo);

// //         // Now serviceInfoMap is a Map<String, dynamic>, and you can proceed with your logic
// //         print("Discovered Services: $serviceInfoMap");

// //         // Call your _findWeightCharacteristic method
// //         var result = _findWeightCharacteristic(serviceInfoMap);
// //         print("result: $result");

// //         if (result != null) {
// //           setState(() {
// //             _weightServiceUuid = result['serviceUuid']!;
// //             _weightCharacteristicUuid = result['characteristicUuid']!;
// //           });
// //           print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");

// //           // Enable notifications using the weight characteristic UUID
// //           await _enableNotifications(deviceAddress, _weightCharacteristicUuid);
// //         } else {
// //           setState(() {
// //             _weightData = "No weight characteristic found";
// //           });
// //           print("No weight characteristic found");
// //         }
// //       } catch (e) {
// //         // Handle JSON parsing errors
// //         setState(() {
// //           _weightData = "Error parsing service info: $e";
// //         });
// //         print("Error parsing service info: $e");
// //       }
// //     } else {
// //       // If serviceInfo is not a string, handle it accordingly
// //       setState(() {
// //         _weightData = "Invalid service info format";
// //       });
// //       print("Invalid service info format");
// //     }
// //   } on PlatformException catch (e) {
// //     // Handle platform-specific errors
// //     print("Error during service discovery: ${e.message}");
// //     setState(() {
// //       _weightData = "Service discovery failed: ${e.message}";
// //     });
// //   }
// // }

// //updated one with known uuids

// Future<void> _discoverServices(String deviceAddress) async {
//   try {
//     // Instead of calling the platform method to discover services, 
//     // we directly attempt to enable notifications with the known UUIDs.
//     print("////////////////////////////////////////////////////////////////////////////////");
//     print("address is ............: $deviceAddress");

//     // Call _findWeightCharacteristic directly with the known UUIDs
//     var result = await _findWeightCharacteristic(deviceAddress);
//     print("Result from _findWeightCharacteristic: $result");

//     if (result != null) {
//       setState(() {
//         _weightServiceUuid = result['serviceUuid']!;
//         _weightCharacteristicUuid = result['characteristicUuid']!;
//       });
//       print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");

//       // Enable notifications using the weight characteristic UUID
//       await _enableNotifications(deviceAddress, _weightCharacteristicUuid);
//     } else {
//       setState(() {
//         _weightData = "No weight characteristic found";
//       });
//       print("No weight characteristic found");
//     }
//   } catch (e) {
//     // Handle any exceptions that may occur
//     print("Error during service discovery: $e");
//     setState(() {
//       _weightData = "Service discovery failed: $e";
//     });
//   }
// }



//   Future<void> _enableNotifications(String deviceAddress, String characteristicUuid) async {
//     print("Inside _enableNotifications method");

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


//   Future<void> _handleNativeMethodCall(MethodCall call) async {
//   switch (call.method) {
//     case "onDeviceFound":
//       Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
//       setState(() {
//         _deviceList.add(deviceInfo);
//       });
//       break;

//     case "onServicesDiscovered":
//       // No need to process serviceInfo, just use the deviceAddress directly
//       String deviceAddress = call.arguments['deviceAddress'];
      
//       print("Discovered device address: $deviceAddress");

//       // Directly use the known UUIDs to find the weight characteristic
//       var result = await _findWeightCharacteristic(deviceAddress);
//       print("on handle method result: $result");

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


//   // Map<String, String>? _findWeightCharacteristic(Map<String, dynamic> serviceInfo) {
//   //   // Assuming that serviceInfo contains a list of services and characteristics
//   //   for (var service in serviceInfo['services']) {
//   //     if (service['uuid'] == '00001530-1212-efde-1523-785feabcd123') { 
//   //       print("line no 280,checking service uuid 00001530-1212-efde-1523-785feabcd123................................................" );
//   //       for (var characteristic in service['characteristics']) {
//   //         if (characteristic['uuid'] == '00001531-1212-efde-1523-785feabcd123') {
//   //             print(" line no 283 checking char uuid 00001531-1212-efde-1523-785feabcd123................................................" );

//   //            // Example characteristic UUID
//   //           return {
//   //             'deviceAddress': serviceInfo['deviceAddress'],
//   //             'serviceUuid': service['uuid'],
//   //             'characteristicUuid': characteristic['uuid'],
//   //           };
//   //         }
//   //       }
//   //     }
//   //   }
//   //   return null; // Return null if no matching characteristic is found
//   // }


// //updated one
// // Future<Map<String, String>?> _findWeightCharacteristic(String deviceAddress) async {
// //   try {
// //     // Get the connected devices
// //     var connectedDevices = await flutterBlue.connectedDevices;
// //     print("Connected devices: ${connectedDevices.map((d) => d.id.id).toList()}");

// //     // Find the device with the matching address
// //     BluetoothDevice? device;
// //     for (var connectedDevice in connectedDevices) {
// //       if (connectedDevice.id.id == deviceAddress) {
// //         device = connectedDevice;
// //         break;
// //       }
// //     }

// //     if (device == null) {
// //       print("Device with address $deviceAddress not found in connected devices.");
// //       setState(() {
// //         _weightData = "Device not connected";
// //       });
// //       return null;
// //     }

// //     print("Found device: ${device.name}");

// //     // Discover services of the device
// //     var services = await device.discoverServices();
// //     print("Discovered services: ${services.map((s) => s.uuid.toString()).toList()}");

// //     // Look for the weight service and characteristic by UUID
// //     for (var service in services) {
// //       if (service.uuid.toString() == _weightServiceUuid) {
// //         print("Found weight service with UUID: $_weightServiceUuid");

// //         for (var characteristic in service.characteristics) {
// //           if (characteristic.uuid.toString() == _weightCharacteristicUuid) {
// //             print("Found weight characteristic with UUID: $_weightCharacteristicUuid");

// //             return {
// //               'deviceAddress': deviceAddress,
// //               'serviceUuid': service.uuid.toString(),
// //               'characteristicUuid': characteristic.uuid.toString(),
// //             };
// //           }
// //         }
// //       }
// //     }

// //     // If no matching service or characteristic is found
// //     return null;
// //   } catch (e) {
// //     print("Error in _findWeightCharacteristic: $e");
// //     setState(() {
// //       _weightData = "Error finding weight characteristic: $e";
// //     });
// //     return null;
// //   }
// // }


// Future<Map<String, String>?> _findWeightCharacteristic(String deviceAddress) async {
//   try {
//     // Get the connected devices
//     var connectedDevices = await flutterBlue.connectedDevices;
//     print("Connected devices: ${connectedDevices.map((d) => d.id.id).toList()}");

//     // Ensure the device address is in lowercase for comparison
//     String deviceAddressLower = deviceAddress.toLowerCase();

//     // Find the device with the matching address
//     BluetoothDevice? device;
//     for (var connectedDevice in connectedDevices) {
//       if (connectedDevice.id.id.toLowerCase() == deviceAddressLower) {
//         device = connectedDevice;
//         break;
//       }
//     }

//     if (device == null) {
//       print("Device with address $deviceAddress not found in connected devices.");
//       setState(() {
//         _weightData = "Device not connected";
//       });
//       return null;
//     }

//     print("Found device: ${device.name}");

//     // Discover services of the device
//     var services = await device.discoverServices();
//     print("Discovered services: ${services.map((s) => s.uuid.toString()).toList()}");

//     // Look for the weight service and characteristic by UUID
//     for (var service in services) {
//       if (service.uuid.toString() == _weightServiceUuid) {
//         print("Found weight service with UUID: $_weightServiceUuid");

//         for (var characteristic in service.characteristics) {
//           if (characteristic.uuid.toString() == _weightCharacteristicUuid) {
//             print("Found weight characteristic with UUID: $_weightCharacteristicUuid");

//             return {
//               'deviceAddress': deviceAddress,
//               'serviceUuid': service.uuid.toString(),
//               'characteristicUuid': characteristic.uuid.toString(),
//             };
//           }
//         }
//       }
//     }

//     // If no matching service or characteristic is found
//     return null;
//   } catch (e) {
//     print("Error in _findWeightCharacteristic: $e");
//     setState(() {
//       _weightData = "Error finding weight characteristic: $e";
//     });
//     return null;
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: themeColor,
//         centerTitle: true,
//         title: Text('SDK Connection, Screen5', style: appBarTextStyle),
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
//         children: <TextSpan>[
//           TextSpan(
//             text: ques,
//             style: blackHeadingStyle,
//           ),
//           TextSpan(
//             text: res,
//             style: blackContentStyle,
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _getWeightData() async {
//     try {
//       final result = await platform.invokeMethod('getWeightData');
//       print("Weight Data: $result");
//       setState(() {
//         _weightData = result;
//       });
//     } on PlatformException catch (e) {
//       print("Error fetching weight data: ${e.message}");
//       setState(() {
//         _weightData = "Error fetching weight data: ${e.message}";
//       });
//     }
//   }
// }




//updated code
import 'dart:typed_data';  // For ByteData
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_connection_2/utils/colors.dart';
import 'package:sdk_connection_2/utils/constants.dart';
import 'package:sdk_connection_2/widget/sizedBox.dart';

class TestScreen5 extends StatefulWidget {
  const TestScreen5({super.key});

  @override
  State<TestScreen5> createState() => _TestScreen5State();
}

class _TestScreen5State extends State<TestScreen5> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';
  String _weightCharacteristicUuid = '00001531-1212-efde-1523-785feabcd123'; // weight characteristic
  String _weightServiceUuid = '00001530-1212-efde-1523-785feabcd123'; // UUID for weight service
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
      // Request necessary permissions
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

  Future<void> _handleNativeMethodCall(MethodCall call) async {
  switch (call.method) {
    case 'startScan':
      print('Start scan method called');
      break;

    case 'connectToDevice':
      String deviceAddress = call.arguments['deviceAddress'];
      print('Connect to device method called with address: $deviceAddress');
      await _connectToDevice(deviceAddress);
      break;

    case 'getWeightData':
      String weightData = call.arguments['weightData'];
      setState(() {
        _weightData = weightData;
      });
      print('Weight Data received: $weightData');
      break;

    case 'discoverServices':
      String deviceAddress = call.arguments['deviceAddress'];
      print('Discover services method called with address: $deviceAddress');
      await _discoverServices(deviceAddress);
      break;

    case 'enableNotifications':
      String deviceAddress = call.arguments['deviceAddress'];
      String characteristicUuid = call.arguments['characteristicUuid'];
      print('Enable notifications called for device: $deviceAddress and characteristic: $characteristicUuid');
      await _enableNotifications(deviceAddress, characteristicUuid);
      break;

    case 'findWeightCharacteristic':
      String deviceAddress = call.arguments['deviceAddress'];
      print('Find weight characteristic called for device: $deviceAddress');
      var result = await _findWeightCharacteristic(deviceAddress);
      if (result != null) {
        print('Found weight characteristic: ${result['characteristicUuid']}');
      } else {
        print('Weight characteristic not found');
      }
      break;

    case 'onDeviceFound':
      Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
      // Check if the device already exists in the list based on its address
      bool deviceExists = _deviceList.any((device) => device['address'] == deviceInfo['address']);
      if (!deviceExists) {
        setState(() {
          _deviceList.add(deviceInfo);
    });
    print('Device added: ${deviceInfo['name']} with address: ${deviceInfo['address']}');
  } else {
    print('Duplicate device ignored: ${deviceInfo['name']} with address: ${deviceInfo['address']}');
  }
      // setState(() {
      //   _deviceList.add(deviceInfo);
      // });
      // print('Device found: ${deviceInfo['name']} with address: ${deviceInfo['address']}');
      
      break;

    default:
      print('Unknown method called: ${call.method}');
  }
}



  Future<void> _startScan() async {
    var state = await flutterBlue.state.first;
    if (state != BluetoothState.on) {
      print("Bluetooth is not on");
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

      // After connecting, fetch services
      print("_discoverServices function is called............................");
      await _discoverServices(deviceAddress);
    } on PlatformException catch (e) {
      setState(() {
        _deviceName = "Failed to connect: ${e.message}";
      });
    }
  }

  Future<void> _discoverServices(String deviceAddress) async {
    try {
      print("////////////////////////////////////////////////////////////////////////////////");
      print("address is ............: $deviceAddress");

      // Call _findWeightCharacteristic directly with the known UUIDs
      var result = await _findWeightCharacteristic(deviceAddress);
      print("Result from _findWeightCharacteristic: $result");

      if (result != null) {
        setState(() {
          _weightServiceUuid = result['serviceUuid']!;
          _weightCharacteristicUuid = result['characteristicUuid']!;
        });
        print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");

        // Enable notifications using the weight characteristic UUID
        await _enableNotifications(deviceAddress, _weightCharacteristicUuid);
      } else {
        setState(() {
          _weightData = "No weight characteristic found";
        });
        print("No weight characteristic found");
      }
    } catch (e) {
      // Handle any exceptions that may occur
      print("Error during service discovery: $e");
      setState(() {
        _weightData = "Service discovery failed: $e";
      });
    }
  }

  Future<void> _enableNotifications(String deviceAddress, String characteristicUuid) async {
    print("Inside _enableNotifications method");

    try {
      print("Starting _enableNotifications for device: $deviceAddress and characteristic: $characteristicUuid");

      // Get the connected devices
      var connectedDevices = await flutterBlue.connectedDevices;
      print("Connected devices: ${connectedDevices.map((d) => d.id.id).toList()}");

      // Ensure the device address is in lowercase for comparison
      String deviceAddressLower = deviceAddress.toLowerCase();

      // Find the device with the matching address
      BluetoothDevice? device;
      for (var connectedDevice in connectedDevices) {
        if (connectedDevice.id.id.toLowerCase() == deviceAddressLower) {
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

  Future<Map<String, String>?> _findWeightCharacteristic(String deviceAddress) async {
    try {
      // Get the connected devices
      var connectedDevices = await flutterBlue.connectedDevices;
      print("Connected devices: ${connectedDevices.map((d) => d.id.id).toList()}");

      // Ensure the device address is in lowercase for comparison
      String deviceAddressLower = deviceAddress.toLowerCase();

      // Find the device with the matching address
      BluetoothDevice? device;
      for (var connectedDevice in connectedDevices) {
        if (connectedDevice.id.id.toLowerCase() == deviceAddressLower) {
          device = connectedDevice;
          break;
        }
      }

      if (device == null) {
        print("Device with address $deviceAddress not found in connected devices.");
        setState(() {
          _weightData = "Device not connected";
        });
        return null;
      }

      print("Found device: ${device.name}");

      // Discover services of the device
      var services = await device.discoverServices();
      print("Discovered services: ${services.map((s) => s.uuid.toString()).toList()}");

      // Look for the weight service and characteristic by UUID
      for (var service in services) {
        if (service.uuid.toString() == _weightServiceUuid) {
          print("Found weight service with UUID: $_weightServiceUuid");

          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == _weightCharacteristicUuid) {
              print("Found weight characteristic with UUID: $_weightCharacteristicUuid");

              return {
                'deviceAddress': deviceAddress,
                'serviceUuid': service.uuid.toString(),
                'characteristicUuid': characteristic.uuid.toString(),
              };
            }
          }
        }
      }

      // If no matching service or characteristic is found
      return null;
    } catch (e) {
      print("Error in _findWeightCharacteristic: $e");
      setState(() {
        _weightData = "Error finding weight characteristic: $e";
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        centerTitle: true,
        title: Text('SDK Connection, Screen5', style: appBarTextStyle),
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
        children: <TextSpan>[
          TextSpan(
            text: ques,
            style: blackHeadingStyle,
          ),
          TextSpan(
            text: res,
            style: blackContentStyle,
          ),
        ],
      ),
    );
  }

  Future<void> _getWeightData() async {
    try {
      final result = await platform.invokeMethod('getWeightData');
      print("Weight Data: $result");
      setState(() {
        _weightData = result;
      });
    } on PlatformException catch (e) {
      print("Error fetching weight data: ${e.message}");
      setState(() {
        _weightData = "Error fetching weight data: ${e.message}";
      });
    }
  }
}
