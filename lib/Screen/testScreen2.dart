import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdk_connection_2/utils/constants.dart';
import 'package:sdk_connection_2/widget/sizedBox.dart';

class TestScreen2 extends StatefulWidget {
  const TestScreen2({super.key});

  @override
  State<TestScreen2> createState() => _TestScreen2State();
}

class _TestScreen2State extends State<TestScreen2> {
  static const platform = MethodChannel('com.example.sdk_connection_2/device_manager');

  String _weightData = 'No data received yet';
  String _deviceName = 'No device connected';
  List<Map<String, String>> _deviceList = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;

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

    // Start scanning once permissions are granted
    await _startScan();
  }

  Future<void> _startScan() async {
    // Check Bluetooth status before starting the scan
    var state = await flutterBlue.state.first;
    if (state != BluetoothState.on) {
      print("Bluetooth is not on");
      return;
    }

    // Clear previous device list and start scanning
    setState(() {
      _deviceList.clear();
    });

    try {
      final result = await platform.invokeMethod('startScan');
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

      // After successful connection, get services and characteristics
      print("_getServicesAndCharacteristics function called.................");
      _getServicesAndCharacteristics();

    } on PlatformException catch (e) {
      setState(() {
        _deviceName = "Failed to connect: ${e.message}";
      });
    }
  }

  Future<void> _getServicesAndCharacteristics() async {
    if (_connectedDevice == null) return;

    // Discover services and characteristics after successful connection
    try {
      List<BluetoothService> services = await _connectedDevice!.discoverServices();

      for (BluetoothService service in services) {
        print("Service UUID: ${service.uuid}");
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          print("Characteristic UUID: ${characteristic.uuid}");
        }
      }
    } catch (e) {
      print("Error discovering services and characteristics: $e");
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
        _weightData = "Failed to get weight: ${e.message}";
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
        title: Text(
          'BLE SDK Connection, Test Screen 2',
          style: appBarTextStyle,
        ),
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
              child: Text(
                'Get Weight Data',
                style: buttonTextStyle,
              ),
            ),
            height20,
            ElevatedButton(
              onPressed: () async {
                if (_deviceList.isNotEmpty) {
                  await _connectToDevice(_deviceList.first['address']!);
                }
              },
              child: Text(
                'Connect to Device',
                style: buttonTextStyle,
              ),
            ),
            height20,
            Expanded(
              child: ListView.builder(
                itemCount: _deviceList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _deviceList[index]['name']!,
                      style: blackHeadingStyle,
                    ),
                    subtitle: Text(
                      _deviceList[index]['address']!,
                      style: blackContentStyle,
                    ),
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
          TextSpan(text: res, style: blackHeadingStyle)
        ],
      ),
    );
  }
}
