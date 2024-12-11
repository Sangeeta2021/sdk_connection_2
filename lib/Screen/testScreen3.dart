//**************************MainActivity code for this************************/
// package com.example.sdk_connection_2;

// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.bluetooth.BluetoothGatt;
// import android.bluetooth.BluetoothGattCallback;
// import android.bluetooth.BluetoothGattCharacteristic;
// import android.bluetooth.BluetoothGattDescriptor;
// import android.bluetooth.BluetoothGattService;
// import android.content.BroadcastReceiver;
// import android.content.Context;
// import android.content.Intent;
// import android.content.IntentFilter;
// import android.content.pm.PackageManager;
// import android.Manifest;
// import android.os.Build;
// import android.os.Handler;
// import android.os.Looper;
// import android.util.Log;
// import androidx.annotation.NonNull;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;

// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.util.ArrayList;
// import java.util.Arrays;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;
// import java.util.UUID;

// public class MainActivity extends FlutterActivity {
//     private static final String TAG = "BLEWeightConnection";
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
//     private BluetoothGatt bluetoothGatt;
//     private final Handler mainHandler = new Handler(Looper.getMainLooper());

//     // Comprehensive list of potential weight-related service UUIDs
//     private final List<String> weightServiceUuids = Arrays.asList(
//         "0000181d-0000-1000-8000-00805f9b34fb",  // Weight Scale Service
//         "00001530-1212-efde-1523-785feabcd123",  // Custom device service
//         "0000ffb0-0000-1000-8000-00805f9b34fb"   // Another potential service
//     );

//     // Potential weight characteristic UUID patterns
//     private final List<String> weightCharacteristicPatterns = Arrays.asList(
//         "weight", "mass", "scale", 
//         "1531", "1532", "1534", 
//         "ffb1", "ffb2", "ffb3"
//     );

//     @Override
//     public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//         super.configureFlutterEngine(flutterEngine);
//         bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

//         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//                 .setMethodCallHandler((call, result) -> {
//                     switch (call.method) {
//                         case "startScan":
//                             startBluetoothScan(result);
//                             break;
//                         case "connectToDevice":
//                             String deviceAddress = call.argument("deviceAddress");
//                             if (deviceAddress != null && !deviceAddress.isEmpty()) {
//                                 connectToDevice(deviceAddress, result);
//                             } else {
//                                 result.error("INVALID_ADDRESS", "Device address cannot be null or empty.", null);
//                             }
//                             break;
//                         case "getWeightData":
//                             String serviceUuid = call.argument("serviceUuid");
//                             String characteristicUuid = call.argument("characteristicUuid");
//                             getWeightData(serviceUuid, characteristicUuid, result);
//                             break;
//                         default:
//                             result.notImplemented();
//                             break;
//                     }
//                 });

//         // Register broadcast receiver for device discovery
//         IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
//         registerReceiver(broadcastReceiver, filter);
        
//         // Check and request necessary permissions
//         checkBluetoothPermissions();
//     }

//     private void checkBluetoothPermissions() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             String[] requiredPermissions = {
//                 Manifest.permission.BLUETOOTH_SCAN,
//                 Manifest.permission.BLUETOOTH_CONNECT,
//                 Manifest.permission.ACCESS_FINE_LOCATION
//             };

//             List<String> missingPermissions = new ArrayList<>();
//             for (String permission : requiredPermissions) {
//                 if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
//                     missingPermissions.add(permission);
//                 }
//             }

//             if (!missingPermissions.isEmpty()) {
//                 ActivityCompat.requestPermissions(this, 
//                     missingPermissions.toArray(new String[0]), 1);
//             }
//         }
//     }

//     private void startBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter == null) {
//             result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not supported on this device", null);
//             return;
//         }

//         if (!bluetoothAdapter.isEnabled()) {
//             result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled", null);
//             return;
//         }

//         bluetoothAdapter.startDiscovery();
//         result.success("Bluetooth scan started");
//         Log.d(TAG, "Bluetooth scan started");
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         try {
//             BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//             if (device != null) {
//                 bluetoothGatt = device.connectGatt(this, false, gattCallback);
//                 result.success("Connecting to " + (device.getName() != null ? device.getName() : "Unknown Device"));
//                 Log.d(TAG, "Attempting to connect to device: " + deviceAddress);
//             } else {
//                 result.error("DEVICE_NOT_FOUND", "Device not found", null);
//             }
//         } catch (IllegalArgumentException e) {
//             result.error("INVALID_ADDRESS", "Invalid Bluetooth address", null);
//             Log.e(TAG, "Invalid Bluetooth address", e);
//         }
//     }

//     private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
//         @Override
//         public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
//             if (newState == BluetoothGatt.STATE_CONNECTED) {
//                 Log.d(TAG, "Connected to GATT server");
//                 gatt.discoverServices();
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Connected");
//             } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
//                 Log.d(TAG, "Disconnected from GATT server");
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Disconnected");
//             }
//         }

//         @Override
//         public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 Log.d(TAG, "Services discovered");
//                 Map<String, List<String>> serviceMap = new HashMap<>();
                
//                 for (BluetoothGattService service : gatt.getServices()) {
//                     String serviceUuid = service.getUuid().toString();
//                     List<String> characteristics = new ArrayList<>();
                    
//                     for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                         characteristics.add(characteristic.getUuid().toString());
//                     }
                    
//                     serviceMap.put(serviceUuid, characteristics);
//                 }
                
//                 sendToFlutterOnMainThread("onServicesDiscovered", serviceMap);
//             } else {
//                 Log.e(TAG, "onServicesDiscovered received: " + status);
//             }
//         }

//         @Override
//         public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 processWeightData(characteristic.getValue());
//             }
//         }

//         @Override
//         public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
//             processWeightData(characteristic.getValue());
//         }
//     };

//     private void processWeightData(byte[] data) {
//         if (data == null || data.length == 0) {
//             Log.w(TAG, "No weight data received");
//             sendToFlutterOnMainThread("onWeightDataReceived", "No data");
//             return;
//         }

//         try {
//             float weightKg = parseWeightData(data);
//             String weightString = String.format("%.2f kg", weightKg);
//             Log.d(TAG, "Processed weight: " + weightString);
//             sendToFlutterOnMainThread("onWeightDataReceived", weightString);
//         } catch (Exception e) {
//             Log.e(TAG, "Error parsing weight data", e);
//             sendToFlutterOnMainThread("onWeightDataReceived", "Data parsing error");
//         }
//     }

//     private float parseWeightData(byte[] data) {
//         // Multiple parsing strategies
//         float parsedWeight = 0f;
        
//         try {
//             // Strategy 1: Little Endian Float
//             ByteBuffer buffer = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN);
//             parsedWeight = buffer.getFloat();
//             return parsedWeight;
//         } catch (Exception e1) {
//             try {
//                 // Strategy 2: Big Endian Float
//                 ByteBuffer buffer = ByteBuffer.wrap(data).order(ByteOrder.BIG_ENDIAN);
//                 parsedWeight = buffer.getFloat();
//                 return parsedWeight;
//             } catch (Exception e2) {
//                 // Strategy 3: Byte manipulation
//                 int intBits = 0;
//                 for (int i = 0; i < Math.min(4, data.length); i++) {
//                     intBits |= (data[i] & 0xFF) << (8 * i);
//                 }
//                 return Float.intBitsToFloat(intBits);
//             }
//         }
//     }

//     private void getWeightData(String specifiedServiceUuid, String specifiedCharacteristicUuid, MethodChannel.Result result) {
//         if (bluetoothGatt == null) {
//             result.error("NO_CONNECTION", "No active Bluetooth connection", null);
//             return;
//         }

//         for (BluetoothGattService service : bluetoothGatt.getServices()) {
//             String serviceUuid = service.getUuid().toString().toUpperCase();

//             // Check if service matches specified or known weight service UUIDs
//             boolean isTargetService = (specifiedServiceUuid != null && serviceUuid.equals(specifiedServiceUuid.toUpperCase())) ||
//                                       weightServiceUuids.stream().anyMatch(uuid -> uuid.toUpperCase().equals(serviceUuid));

//             if (isTargetService) {
//                 for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                     String characteristicUuid = characteristic.getUuid().toString().toUpperCase();
                    
//                     // Check if characteristic matches specified or contains weight patterns
//                     boolean isTargetCharacteristic = 
//                         (specifiedCharacteristicUuid != null && characteristicUuid.equals(specifiedCharacteristicUuid.toUpperCase())) ||
//                         weightCharacteristicPatterns.stream().anyMatch(pattern -> characteristicUuid.contains(pattern.toUpperCase()));

//                     if (isTargetCharacteristic) {
//                         int properties = characteristic.getProperties();
                        
//                         // Enable notifications if supported
//                         bluetoothGatt.setCharacteristicNotification(characteristic, true);
                        
//                         // Try to read the characteristic
//                         if ((properties & BluetoothGattCharacteristic.PROPERTY_READ) > 0) {
//                             bluetoothGatt.readCharacteristic(characteristic);
//                             result.success("Reading weight data...");
//                             return;
//                         }
//                     }
//                 }
//             }
//         }
        
//         result.error("NO_WEIGHT_CHARACTERISTIC", "No suitable weight characteristic found", null);
//     }

//     private void sendToFlutterOnMainThread(String method, Object arguments) {
//         mainHandler.post(() -> new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                 .invokeMethod(method, arguments));
//     }

//     private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
//         @Override
//         public void onReceive(Context context, Intent intent) {
//             if (BluetoothDevice.ACTION_FOUND.equals(intent.getAction())) {
//                 BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
//                 if (device != null) {
//                     Map<String, String> deviceInfo = new HashMap<>();
//                     deviceInfo.put("name", device.getName() != null ? device.getName() : "Unknown Device");
//                     deviceInfo.put("address", device.getAddress());
//                     sendToFlutterOnMainThread("onDeviceFound", deviceInfo);
//                 }
//             }
//         }
//     };

//     @Override
//     protected void onDestroy() {
//         super.onDestroy();
        
//         // Unregister broadcast receiver
//         try {
//             unregisterReceiver(broadcastReceiver);
//         } catch (IllegalArgumentException e) {
//             Log.w(TAG, "Broadcast receiver not registered", e);
//         }
        
//         // Close Bluetooth GATT connection
//         if (bluetoothGatt != null) {
//             bluetoothGatt.close();
//             bluetoothGatt = null;
//         }
//     }
// }







//updated one in this code i am getting weight as 0kg *****************************************
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
  String _weightCharacteristicUuid = '';
  String _weightServiceUuid = '';
  List<Map<String, String>> _deviceList = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;

  // Known weight-related UUID patterns (add more if needed)
  final List<String> _weightUuidPatterns = [
    'weight',
    'mass',
    'scale',
    '1531', // Based on your specific UUIDs
    '1532',
    '1534',
  ];

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
    } on PlatformException catch (e) {
      setState(() {
        _deviceName = "Failed to connect: ${e.message}";
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
      print("Weight Data Retrieved: $result");
      setState(() {
        _weightData = result ?? "No weight data";
      });
    } catch (e) {
      print("Error getting weight data: $e");
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
        print("Discovered Services and Characteristics: $serviceInfo");

        var result = _findWeightCharacteristic(serviceInfo);
        if (result != null) {
          setState(() {
            _weightServiceUuid = result['serviceUuid']!;
            _weightCharacteristicUuid = result['characteristicUuid']!;
          });
          print("Weight UUID found - Service: $_weightServiceUuid, Characteristic: $_weightCharacteristicUuid");
        } else {
          print("No weight characteristic found");
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
    for (var serviceUuid in serviceInfo.keys) {
      var characteristics = serviceInfo[serviceUuid];
      
      for (var characteristic in characteristics) {
        // Convert to string to handle potential type variations
        String charString = characteristic.toString().toLowerCase();
        
        // Check against known weight-related patterns
        for (var pattern in _weightUuidPatterns) {
          if (charString.contains(pattern)) {
            return {
              'serviceUuid': serviceUuid,
              'characteristicUuid': characteristic.toString()
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
        backgroundColor: Colors.purple.shade200,
        centerTitle: true,
        title: Text('SDK Connection, Screen3', style: appBarTextStyle),
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




