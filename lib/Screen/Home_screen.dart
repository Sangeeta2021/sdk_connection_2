//trying to identify the weight related uuids , testing each uuids by putting them on code
//when i used this with screen 4 mainactivity got 0.kg
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

  // Future<void> _getWeightData() async {
  //   if (_weightCharacteristicUuid.isEmpty) {
  //     setState(() {
  //       _weightData = 'Weight UUID not found!';
  //     });
  //     return;
  //   }

  //   try {
  //     print("Invoking getWeightData with UUID: $_weightCharacteristicUuid...");
  //     final result = await platform.invokeMethod('getWeightData', {'uuid': _weightCharacteristicUuid});
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


  //updated one
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
    if (serviceUuid == "00001530-1212-efde-1523-785feabcd123") {
      for (var characteristic in characteristics) {
        // If the characteristic matches any of the known weight-related UUIDs
        if (
          
            characteristic == "00001531-1212-efde-1523-785feabcd123" ||
            characteristic == "00001532-1212-efde-1523-785feabcd123" ||
            characteristic == "00001534-1212-efde-1523-785feabcd123") {
          return characteristic;  // Return the weight characteristic UUID
        }
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
