// updated code to resolve error in discover services, modification of screen 4
// all the error resolved but getting weight still as 0kg
//remove device duplication in screen
// import 'dart:typed_data';  // For ByteData
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

//   Future<void> _handleNativeMethodCall(MethodCall call) async {
//   switch (call.method) {
//     case 'startScan':
//       print('Start scan method called');
//       break;

//     case 'connectToDevice':
//       String deviceAddress = call.arguments['deviceAddress'];
//       print('Connect to device method called with address: $deviceAddress');
//       await _connectToDevice(deviceAddress);
//       break;

//     case 'getWeightData':
//       String weightData = call.arguments['weightData'];
//       setState(() {
//         _weightData = weightData;
//       });
//       print('Weight Data received: $weightData');
//       break;

//     case 'discoverServices':
//       String deviceAddress = call.arguments['deviceAddress'];
//       print('Discover services method called with address: $deviceAddress');
//       await _discoverServices(deviceAddress);
//       break;

//     case 'enableNotifications':
//       String deviceAddress = call.arguments['deviceAddress'];
//       String characteristicUuid = call.arguments['characteristicUuid'];
//       print('Enable notifications called for device: $deviceAddress and characteristic: $characteristicUuid');
//       await _enableNotifications(deviceAddress, characteristicUuid);
//       break;

//     case 'findWeightCharacteristic':
//       String deviceAddress = call.arguments['deviceAddress'];
//       print('Find weight characteristic called for device: $deviceAddress');
//       var result = await _findWeightCharacteristic(deviceAddress);
//       if (result != null) {
//         print('Found weight characteristic: ${result['characteristicUuid']}');
//       } else {
//         print('Weight characteristic not found');
//       }
//       break;

//     case 'onDeviceFound':
//       Map<String, String> deviceInfo = Map<String, String>.from(call.arguments);
//       // Check if the device already exists in the list based on its address
//       bool deviceExists = _deviceList.any((device) => device['address'] == deviceInfo['address']);
//       if (!deviceExists) {
//         setState(() {
//           _deviceList.add(deviceInfo);
//     });
//     print('Device added: ${deviceInfo['name']} with address: ${deviceInfo['address']}');
//   } else {
//     print('Duplicate device ignored: ${deviceInfo['name']} with address: ${deviceInfo['address']}');
//   }
//       // setState(() {
//       //   _deviceList.add(deviceInfo);
//       // });
//       // print('Device found: ${deviceInfo['name']} with address: ${deviceInfo['address']}');
      
//       break;

//     default:
//       print('Unknown method called: ${call.method}');
//   }
// }



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

//   Future<void> _discoverServices(String deviceAddress) async {
//     try {
//       print("////////////////////////////////////////////////////////////////////////////////");
//       print("address is ............: $deviceAddress");

//       // Call _findWeightCharacteristic directly with the known UUIDs
//       var result = await _findWeightCharacteristic(deviceAddress);
//       print("Result from _findWeightCharacteristic: $result");

//       if (result != null) {
//         setState(() {
//           _weightServiceUuid = result['serviceUuid']!;
//           _weightCharacteristicUuid = result['characteristicUuid']!;
//         });
//         print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");

//         // Enable notifications using the weight characteristic UUID
//         await _enableNotifications(deviceAddress, _weightCharacteristicUuid);
//       } else {
//         setState(() {
//           _weightData = "No weight characteristic found";
//         });
//         print("No weight characteristic found");
//       }
//     } catch (e) {
//       // Handle any exceptions that may occur
//       print("Error during service discovery: $e");
//       setState(() {
//         _weightData = "Service discovery failed: $e";
//       });
//     }
//   }

//   Future<void> _enableNotifications(String deviceAddress, String characteristicUuid) async {
//     print("Inside _enableNotifications method");

//     try {
//       print("Starting _enableNotifications for device: $deviceAddress and characteristic: $characteristicUuid");

//       // Get the connected devices
//       var connectedDevices = await flutterBlue.connectedDevices;
//       print("Connected devices: ${connectedDevices.map((d) => d.id.id).toList()}");

//       // Ensure the device address is in lowercase for comparison
//       String deviceAddressLower = deviceAddress.toLowerCase();

//       // Find the device with the matching address
//       BluetoothDevice? device;
//       for (var connectedDevice in connectedDevices) {
//         if (connectedDevice.id.id.toLowerCase() == deviceAddressLower) {
//           device = connectedDevice;
//           break;
//         }
//       }

//       if (device == null) {
//         print("Device with address $deviceAddress not found in connected devices.");
//         setState(() {
//           _deviceName = "Device not connected";
//         });
//         return;
//       }
//       print("Found device: ${device.name}");

//       // Discover services of the device
//       var services = await device.discoverServices();
//       print("Discovered services: ${services.map((s) => s.uuid.toString()).toList()}");

//       BluetoothCharacteristic? targetCharacteristic;

//       // Find the target characteristic by UUID
//       for (var service in services) {
//         print("Checking service: ${service.uuid}");
//         for (var characteristic in service.characteristics) {
//           print("Found characteristic: ${characteristic.uuid}");
//           if (characteristic.uuid.toString() == characteristicUuid) {
//             targetCharacteristic = characteristic;
//             break;
//           }
//         }
//         if (targetCharacteristic != null) break;
//       }

//       if (targetCharacteristic == null) {
//         print("Characteristic with UUID $characteristicUuid not found.");
//         setState(() {
//           _weightData = "Characteristic not found";
//         });
//         return;
//       }
//       print("Found target characteristic: ${targetCharacteristic.uuid}");

//       // Enable notifications for the characteristic
//       await targetCharacteristic.setNotifyValue(true);
//       bool isNotifying = await targetCharacteristic.isNotifying;
//       print("Notifications enabled for characteristic: ${targetCharacteristic.uuid}, isNotifying: $isNotifying");

//       if (!isNotifying) {
//         print("Failed to enable notifications for characteristic: ${targetCharacteristic.uuid}");
//         setState(() {
//           _weightData = "Failed to enable notifications.";
//         });
//         return;
//       }

//       // Listen for notifications
//       targetCharacteristic.value.listen((value) {
//         print("Raw data received: $value");

//         // Assuming the weight data is a 4-byte float (adjust if necessary)
//         if (value.length >= 4) {
//           var weight = ByteData.sublistView(Uint8List.fromList(value)).getFloat32(0, Endian.little);
//           setState(() {
//             _weightData = "${weight.toStringAsFixed(2)} kg";  // Update the weight data on the screen
//           });
//           print("Processed weight: $_weightData");
//         } else {
//           print("Unexpected data format: $value");
//         }
//       }).onError((error) {
//         print("Error in notification listener: $error");
//       });

//     } catch (e) {
//       print("Error in _enableNotifications: ${e.toString()}");
//       setState(() {
//         _weightData = "Error enabling notifications: ${e.toString()}";
//       });
//     }
//   }

//   Future<Map<String, String>?> _findWeightCharacteristic(String deviceAddress) async {
//     try {
//       // Get the connected devices
//       var connectedDevices = await flutterBlue.connectedDevices;
//       print("Connected devices: ${connectedDevices.map((d) => d.id.id).toList()}");

//       // Ensure the device address is in lowercase for comparison
//       String deviceAddressLower = deviceAddress.toLowerCase();

//       // Find the device with the matching address
//       BluetoothDevice? device;
//       for (var connectedDevice in connectedDevices) {
//         if (connectedDevice.id.id.toLowerCase() == deviceAddressLower) {
//           device = connectedDevice;
//           break;
//         }
//       }

//       if (device == null) {
//         print("Device with address $deviceAddress not found in connected devices.");
//         setState(() {
//           _weightData = "Device not connected";
//         });
//         return null;
//       }

//       print("Found device: ${device.name}");

//       // Discover services of the device
//       var services = await device.discoverServices();
//       print("Discovered services: ${services.map((s) => s.uuid.toString()).toList()}");

//       // Look for the weight service and characteristic by UUID
//       for (var service in services) {
//         if (service.uuid.toString() == _weightServiceUuid) {
//           print("Found weight service with UUID: $_weightServiceUuid");

//           for (var characteristic in service.characteristics) {
//             if (characteristic.uuid.toString() == _weightCharacteristicUuid) {
//               print("Found weight characteristic with UUID: $_weightCharacteristicUuid");

//               return {
//                 'deviceAddress': deviceAddress,
//                 'serviceUuid': service.uuid.toString(),
//                 'characteristicUuid': characteristic.uuid.toString(),
//               };
//             }
//           }
//         }
//       }

//       // If no matching service or characteristic is found
//       return null;
//     } catch (e) {
//       print("Error in _findWeightCharacteristic: $e");
//       setState(() {
//         _weightData = "Error finding weight characteristic: $e";
//       });
//       return null;
//     }
//   }

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


//*******************8updated code with fixing errors, uuid not found */
import 'dart:typed_data'; // For ByteData
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
  String _weightCharacteristicUuid = '00001531-1212-efde-1523-785feabcd123';
  String _weightServiceUuid = '00001530-1212-efde-1523-785feabcd123';
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

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'startScan':
        await _startScan();
        break;
      case 'connectToDevice':
        String deviceAddress = call.arguments['deviceAddress'];
        await _connectToDevice(deviceAddress);
        break;
      case 'getWeightData':
        String weightData = call.arguments['weightData'];
        setState(() {
          _weightData = weightData;
        });
        break;
      case 'onDeviceFound':
        _addDeviceToList(Map<String, String>.from(call.arguments));
        break;
      default:
        print('Unknown method called: ${call.method}');
    }
  }

  Future<void> _startScan() async {
    try {
      setState(() {
        _deviceList.clear();
      });
      await platform.invokeMethod('startScan');
      print('Scanning for devices...');
    } on PlatformException catch (e) {
      print("Failed to start scan: ${e.message}");
      setState(() {
        _deviceName = "Scan failed: ${e.message}";
      });
    }
  }

  void _addDeviceToList(Map<String, String> deviceInfo) {
    bool deviceExists = _deviceList.any((device) => device['address'] == deviceInfo['address']);
    if (!deviceExists) {
      setState(() {
        _deviceList.add(deviceInfo);
      });
      // print('Device added: ${deviceInfo['name']} with address: ${deviceInfo['address']}');
    } else {
      // print('Duplicate device ignored: ${deviceInfo['name']} with address: ${deviceInfo['address']}');
    }
  }

  

  //updated one
//   Future<void> _connectToDevice(String deviceAddress) async {
//   try {
//     // Attempt to connect to the device
//     final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
//     setState(() {
//       _deviceName = result;
//       print("****************8device name: $result");
//     });

//     // Wait for the device to be connected before proceeding
//     BluetoothDevice? device = await _getConnectedDevice(deviceAddress);
//     print("*************************connected device: $device******************************");
//     if (device != null) {
//       await _discoverServices(device);
//     } else {
//       setState(() {
//         _deviceName = "Device connection failed";
//       });
//     }
//   } on PlatformException catch (e) {
//     setState(() {
//       _deviceName = "Failed to connect: ${e.message}";
//     });
//     print("PlatformException in _connectToDevice: ${e.message}");
//   } catch (e) {
//     setState(() {
//       _deviceName = "Unexpected error: $e";
//     });
//     print("Unexpected error in _connectToDevice: $e");
//   }
// }

//updated one
Future<void> _connectToDevice(String deviceAddress) async {
  try {
    // Attempt to connect to the device
    final result = await platform.invokeMethod('connectToDevice', {'deviceAddress': deviceAddress});
    setState(() {
      _deviceName = result;
      // print("Device connected: $result");
    });

    // Allow time for the connection to stabilize
    await Future.delayed(Duration(seconds: 2));

    // Check if the device is connected
    BluetoothDevice? device = await _getConnectedDevice(deviceAddress);
    print("*****************************8Connected device: $device");

    if (device != null) {
      // Discover services using FlutterBlue
      await _discoverServices(device);
    } else {
      // Fallback to old logic if device is not found
      print("Device not found in FlutterBlue, falling back to direct service discovery.");
      await platform.invokeMethod('discoverServices', {'deviceAddress': deviceAddress});
    }
  } on PlatformException catch (e) {
    setState(() {
      _deviceName = "Failed to connect: ${e.message}";
    });
    print("PlatformException in _connectToDevice: ${e.message}");
  } catch (e) {
    setState(() {
      _deviceName = "Unexpected error: $e";
    });
    print("Unexpected error in _connectToDevice: $e");
  }
}





//   Future<void> _discoverServices(BluetoothDevice device) async {
//   try {
//     var result = await _findWeightCharacteristic(device);
//     print("*******************result inside _discoverServices: $result*******************");
//     if (result != null) {
//       setState(() {
//         _weightServiceUuid = result['serviceUuid']!;
//         _weightCharacteristicUuid = result['characteristicUuid']!;
//       });
//       print("**************************_enableNotifications method called********************");
//       await _enableNotifications(device, _weightCharacteristicUuid);
//     } else {
//       setState(() {
//         _weightData = "No weight characteristic found";
//       });
//     }
//   } catch (e) {
//     setState(() {
//       _weightData = "Service discovery failed: $e";
//     });
//   }
// }
//updated one
Future<void> _discoverServices(dynamic deviceOrAddress) async {
  try {
    if (deviceOrAddress is BluetoothDevice) {
      // Discover services using FlutterBlue
      var services = await deviceOrAddress.discoverServices();
      // Process services...
    } else if (deviceOrAddress is String) {
      // Call native method to discover services using device address
      await platform.invokeMethod('discoverServices', {'deviceAddress': deviceOrAddress});
      // Process services...
    }
  } catch (e) {
    setState(() {
      _weightData = "Service discovery failed: $e";
    });
    print("Error in _discoverServices: $e");
  }
}



  //check device is connected or not
  Future<BluetoothDevice?> _getConnectedDevice(String deviceAddress) async {
  try {
    var connectedDevices = await flutterBlue.connectedDevices;
    for (var device in connectedDevices) {
      if (device.id.id.toLowerCase() == deviceAddress.toLowerCase()) {
        return device;
      }
    }
    return null; // Device not connected
  } catch (e) {
    setState(() {
      _weightData = "Error fetching connected devices: $e";
    });
    return null;
  }
}



  

  Future<void> _enableNotifications(BluetoothDevice device, String characteristicUuid) async {
  print("///////////////////////Enable notification/////////////////////////");

  try {
    var services = await device.discoverServices();
    BluetoothCharacteristic? targetCharacteristic;

    // Find the characteristic
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == characteristicUuid) {
          targetCharacteristic = characteristic;
          break;
        }
      }
      if (targetCharacteristic != null) break;
    }

    if (targetCharacteristic == null) {
      setState(() {
        _weightData = "Characteristic not found";
      });
      return;
    }

    // Enable notifications
    await targetCharacteristic.setNotifyValue(true);
    targetCharacteristic.value.listen((value) {
      if (value.length >= 4) {
        var weight = ByteData.sublistView(Uint8List.fromList(value)).getFloat32(0, Endian.little);
        setState(() {
          _weightData = "${weight.toStringAsFixed(2)} kg";
        });
      } else {
        print("Unexpected data format: $value");
      }
    }).onError((error) {
      print("Error in notification listener: $error");
    });
  } catch (e) {
    setState(() {
      _weightData = "Error enabling notifications: ${e.toString()}";
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
        _weightData = "Error fetching weight data: ${e.message}";
      });
    }
  }

//updated one
Future<Map<String, String>?> _findWeightCharacteristic(BluetoothDevice device) async {
  print('////////////////////find weight char///////////////////');
  try {
    var services = await device.discoverServices();

    for (var service in services) {
      if (service.uuid.toString() == _weightServiceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == _weightCharacteristicUuid) {
            return {
              'deviceAddress': device.id.id,
              'serviceUuid': service.uuid.toString(),
              'characteristicUuid': characteristic.uuid.toString(),
            };
          }
        }
      }
    }
    return null;
  } catch (e) {
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
}





