

//************************able to get device list & connect with them also getting one uuid DM Screen***********************/
// package com.example.sdk_connection_2;

// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.bluetooth.BluetoothGatt;
// import android.bluetooth.BluetoothGattCallback;
// import android.bluetooth.BluetoothGattCharacteristic;
// import android.bluetooth.BluetoothGattService;
// import android.content.BroadcastReceiver;
// import android.content.Context;
// import android.content.Intent;
// import android.content.IntentFilter;
// import android.content.pm.PackageManager;
// import android.Manifest;
// import android.os.Build;
// import androidx.annotation.NonNull;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;
// import java.util.List;
// import java.util.UUID;
// import java.util.Map;
// import java.util.HashMap;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
//     private BluetoothGatt bluetoothGatt;
//     private BluetoothDevice connectedDevice;

//     @Override
//     public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//         super.configureFlutterEngine(flutterEngine);
//         bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

//         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .setMethodCallHandler((call, result) -> {
//                 if (call.method.equals("startScan")) {
//                     startBluetoothScan(result);
//                 } else if (call.method.equals("connectToDevice")) {
//                     String deviceAddress = call.argument("deviceAddress");
//                     if (deviceAddress == null || deviceAddress.isEmpty()) {
//                         result.error("INVALID_ADDRESS", "Device address cannot be null or empty.", null);
//                         return;
//                     }
//                     connectToDevice(deviceAddress, result);
//                 } else if (call.method.equals("getWeightData")) {
//                     getWeightData(result);
//                 } else {
//                     result.notImplemented();
//                 }
//             });

//         IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
//         registerReceiver(broadcastReceiver, filter);

//         checkBluetoothPermissions();
//     }

//     private void checkBluetoothPermissions() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED ||
//                 ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
//                 ActivityCompat.requestPermissions(this, new String[] {
//                         Manifest.permission.BLUETOOTH_SCAN,
//                         Manifest.permission.BLUETOOTH_CONNECT
//                 }, 1);
//             }
//         }
//     }

//     private void startBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
//             Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
//             startActivityForResult(enableBtIntent, 1);
//             result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
//             return;
//         }
//         bluetoothAdapter.startDiscovery();
//         result.success("Bluetooth scan started.");
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         try {
//             BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//             if (device != null) {
//                 connectedDevice = device;
//                 bluetoothGatt = device.connectGatt(this, false, gattCallback);
//                 result.success("Connecting to " + device.getName());
//             } else {
//                 result.error("ERROR", "Device not found.", null);
//             }
//         } catch (IllegalArgumentException e) {
//             result.error("INVALID_ADDRESS", "Invalid Bluetooth address: " + deviceAddress, null);
//         }
//     }

//     private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
//         @Override
//         public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 Map<String, String> serviceInfo = new HashMap<>();
//                 for (BluetoothGattService service : gatt.getServices()) {
//                     UUID serviceUuid = service.getUuid();
//                     serviceInfo.put("serviceUuid", serviceUuid.toString());
//                     for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                         UUID characteristicUuid = characteristic.getUuid();
//                         serviceInfo.put("characteristicUuid", characteristicUuid.toString());
//                     }
//                 }
//                 sendWeightData("Connected to device: " + connectedDevice.getName(), serviceInfo);
//             }
//         }
//     };

//     private void getWeightData(MethodChannel.Result result) {
//         if (connectedDevice == null) {
//             result.error("NO_CONNECTION", "No device connected.", null);
//             return;
//         }

//         BluetoothGattCharacteristic characteristic = bluetoothGatt.getService(UUID.fromString("SERVICE_UUID"))

//                 .getCharacteristic(UUID.fromString("CHARACTERISTIC_UUID"));
//         bluetoothGatt.readCharacteristic(characteristic);
//     }

//     private void sendWeightData(String weightData, Map<String, String> serviceInfo) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onWeightDataReceived", weightData);
//     }

//     private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
//         @Override
//         public void onReceive(Context context, Intent intent) {
//             if (BluetoothDevice.ACTION_FOUND.equals(intent.getAction())) {
//                 BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
//                 if (device != null) {
//                     Map<String, String> deviceInfo = new HashMap<>();
//                     deviceInfo.put("name", device.getName());
//                     deviceInfo.put("address", device.getAddress());
//                     new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                         .invokeMethod("onDeviceFound", deviceInfo);
//                 }
//             }
//         }
//     };
// }





//**************updated code for TestScreen, getting list of all uuids working properly********************************//
// package com.example.sdk_connection_2;

// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.bluetooth.BluetoothGatt;
// import android.bluetooth.BluetoothGattCallback;
// import android.bluetooth.BluetoothGattCharacteristic;
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
// import androidx.annotation.NonNull;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;

// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;
// import java.util.UUID;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
//     private BluetoothGatt bluetoothGatt;
//     private BluetoothDevice connectedDevice;
//     private String serviceUuid = ""; 
//     private String characteristicUuid = ""; 
//     private final Handler mainHandler = new Handler(Looper.getMainLooper());

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
//                             if (deviceAddress == null || deviceAddress.isEmpty()) {
//                                 result.error("INVALID_ADDRESS", "Device address cannot be null or empty.", null);
//                             } else {
//                                 connectToDevice(deviceAddress, result);
//                             }
//                             break;
//                         case "getWeightData":
//                             getWeightData(result);
//                             break;
//                         default:
//                             result.notImplemented();
//                             break;
//                     }
//                 });

//         IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
//         registerReceiver(broadcastReceiver, filter);

//         checkBluetoothPermissions();
//     }

//     private void checkBluetoothPermissions() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED ||
//                     ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
//                 ActivityCompat.requestPermissions(this, new String[]{
//                         Manifest.permission.BLUETOOTH_SCAN,
//                         Manifest.permission.BLUETOOTH_CONNECT
//                 }, 1);
//             }
//         }
//     }

//     private void startBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
//             Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
//             startActivityForResult(enableBtIntent, 1);
//             result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
//             return;
//         }
//         bluetoothAdapter.startDiscovery();
//         result.success("Bluetooth scan started.");
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         try {
//             BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//             if (device != null) {
//                 connectedDevice = device;
//                 bluetoothGatt = device.connectGatt(this, false, gattCallback);
//                 result.success("Connecting to " + device.getName());
//             } else {
//                 result.error("ERROR", "Device not found.", null);
//             }
//         } catch (IllegalArgumentException e) {
//             result.error("INVALID_ADDRESS", "Invalid Bluetooth address: " + deviceAddress, null);
//         }
//     }

//     private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
//         @Override
//         public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
//             if (newState == BluetoothGatt.STATE_CONNECTED) {
//                 bluetoothGatt = gatt;
//                 bluetoothGatt.discoverServices();
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Connected to device.");
//             } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Disconnected from device.");
//             }
//         }

//         @Override
//         public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 Map<String, List<String>> serviceAndCharacteristicMap = new HashMap<>();

//                 for (BluetoothGattService service : gatt.getServices()) {
//                     String serviceUuid = service.getUuid().toString();
//                     List<String> characteristicUuids = new ArrayList<>();

//                     for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                         characteristicUuids.add(characteristic.getUuid().toString());
//                     }

//                     serviceAndCharacteristicMap.put(serviceUuid, characteristicUuids);
//                 }

//                 sendToFlutterOnMainThread("onServicesDiscovered", serviceAndCharacteristicMap);
//             } else {
//                 sendToFlutterOnMainThread("onServicesDiscoveredError", "Failed to discover services.");
//             }
//         }

//         @Override
//         public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 String weightData = new String(characteristic.getValue());
//                 sendToFlutterOnMainThread("onWeightDataReceived", weightData);
//             }
//         }
//     };

//     private void getWeightData(MethodChannel.Result result) {
//         if (connectedDevice == null || bluetoothGatt == null || serviceUuid.isEmpty() || characteristicUuid.isEmpty()) {
//             result.error("NO_CONNECTION", "No device connected or service/characteristic not set.", null);
//             return;
//         }

//         BluetoothGattService service = bluetoothGatt.getService(UUID.fromString(serviceUuid));
//         if (service == null) {
//             result.error("SERVICE_NOT_FOUND", "Service not found.", null);
//             return;
//         }

//         BluetoothGattCharacteristic characteristic = service.getCharacteristic(UUID.fromString(characteristicUuid));
//         if (characteristic == null) {
//             result.error("CHARACTERISTIC_NOT_FOUND", "Characteristic not found.", null);
//             return;
//         }

//         bluetoothGatt.readCharacteristic(characteristic);
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
//                     deviceInfo.put("name", device.getName());
//                     deviceInfo.put("address", device.getAddress());
//                     sendToFlutterOnMainThread("onDeviceFound", deviceInfo);
//                 }
//             }
//         }
//     };
// }




//updated one with complete uuid handling, getting some response in weight data , when i used it in home screen
// package com.example.sdk_connection_2;
// import android.util.Log;
// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.bluetooth.BluetoothGatt;
// import android.bluetooth.BluetoothGattCallback;
// import android.bluetooth.BluetoothGattCharacteristic;
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
// import androidx.annotation.NonNull;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;

// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
//     private BluetoothGatt bluetoothGatt;
//     private final Handler mainHandler = new Handler(Looper.getMainLooper());

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
//                             getWeightData(result);
//                             break;
//                         case "enableNotifications":
//                             String characteristicUuid = call.argument("characteristicUuid");
//                             enableNotifications(characteristicUuid, result);
//                             break;
//                         default:
//                             result.notImplemented();
//                             break;
//                     }
//                 });

//         IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
//         registerReceiver(broadcastReceiver, filter);
//         checkBluetoothPermissions();
//     }

//     private void checkBluetoothPermissions() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED ||
//                     ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
//                 ActivityCompat.requestPermissions(this, new String[]{
//                         Manifest.permission.BLUETOOTH_SCAN,
//                         Manifest.permission.BLUETOOTH_CONNECT
//                 }, 1);
//             }
//         }
//     }

//     private void startBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
//             result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
//             return;
//         }
//         bluetoothAdapter.startDiscovery();
//         result.success("Bluetooth scan started.");
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         try {
//             BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//             if (device != null) {
//                 bluetoothGatt = device.connectGatt(this, false, gattCallback);
//                 result.success("Connecting to " + device.getName());
//             } else {
//                 result.error("ERROR", "Device not found.", null);
//             }
//         } catch (IllegalArgumentException e) {
//             result.error("INVALID_ADDRESS", "Invalid Bluetooth address: " + deviceAddress, null);
//         }
//     }

//     private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
//         @Override
//         public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
//             if (newState == BluetoothGatt.STATE_CONNECTED) {
//                 bluetoothGatt = gatt;
//                 bluetoothGatt.discoverServices();
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Connected to device.");
//             } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Disconnected from device.");
//             }
//         }

//         @Override
//         public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 Map<String, List<String>> serviceAndCharacteristicMap = new HashMap<>();
//                 for (BluetoothGattService service : gatt.getServices()) {
//                     String serviceUuid = service.getUuid().toString();
//                     List<String> characteristicUuids = new ArrayList<>();
//                     for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                         characteristicUuids.add(characteristic.getUuid().toString());
//                     }
//                     serviceAndCharacteristicMap.put(serviceUuid, characteristicUuids);
//                 }
//                 sendToFlutterOnMainThread("onServicesDiscovered", serviceAndCharacteristicMap);
//             }
//         }

//         @Override
//         public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 String weight = parseWeightData(characteristic.getValue());
//                 sendToFlutterOnMainThread("onWeightDataReceived", weight);
//             }
//         }

//         @Override
//         public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
//             String weight = parseWeightData(characteristic.getValue());
//             sendToFlutterOnMainThread("onWeightDataReceived", weight);
//         }
//     };

//     // private String parseWeightData(byte[] data) {
//     //     if (data != null && data.length >= 4) {
//     //         float weight = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN).getFloat();
//     //         return String.format("%.2f kg", weight);
//     //     }
//     //     return "Invalid weight data";
//     // }


// //     private String parseWeightData(byte[] data) {
// //     if (data != null && data.length >= 4) {
// //         try {
// //             float weight = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN).getFloat();

// //             if (weight > 0 && weight < 300) { // Example range: 0 to 300 kg
// //                 return String.format("%.2f kg", weight);
// //             } else {
// //                 Log.e("BLE", "Parsed weight is out of realistic range: " + weight);
// //                 return "Invalid weight data";
// //             }
// //         } catch (Exception e) {
// //             Log.e("BLE", "Error parsing weight data", e);
// //             return "Error parsing weight data";
// //         }
// //     }

// //     return "Invalid weight data (length too short)";
// // } 

// private String parseWeightData(byte[] data) {
//     if (data == null || data.length < 4) {
//         return "Invalid weight data (insufficient length)";
//     }

//     try {
//         float weight = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN).getFloat();
//         if (weight > 0 && weight < 300) { // Assuming valid range for weight
//             return String.format("%.2f kg", weight);
//         } else {
//             Log.e("BLE", "Parsed weight is out of realistic range: " + weight);
//             return "Invalid weight data (out of range)";
//         }
//     } catch (Exception e) {
//         Log.e("BLE", "Error parsing weight data", e);
//         return "Error parsing weight data";
//     }
// }



//     private void enableNotifications(String characteristicUuid, MethodChannel.Result result) {
//         if (bluetoothGatt != null) {
//             for (BluetoothGattService service : bluetoothGatt.getServices()) {
//                 for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                     if (characteristic.getUuid().toString().equals(characteristicUuid)) {
//                         bluetoothGatt.setCharacteristicNotification(characteristic, true);
//                         result.success("Notifications enabled for characteristic " + characteristicUuid);
//                         return;
//                     }
//                 }
//             }
//             result.error("CHARACTERISTIC_NOT_FOUND", "Characteristic not found.", null);
//         } else {
//             result.error("NO_CONNECTION", "No connected device.", null);
//         }
//     }

//     private void getWeightData(MethodChannel.Result result) {
//         if (bluetoothGatt != null) {
//             for (BluetoothGattService service : bluetoothGatt.getServices()) {
//                 for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                     if (characteristic.getProperties() == BluetoothGattCharacteristic.PROPERTY_READ) {
//                         bluetoothGatt.readCharacteristic(characteristic);
//                         result.success("Reading weight data...");
//                         return;
//                     }
//                 }
//             }
//             result.error("UUID_NOT_FOUND", "No readable characteristic found.", null);
//         } else {
//             result.error("NO_CONNECTION", "No connected device.", null);
//         }
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
//                     deviceInfo.put("name", device.getName());
//                     deviceInfo.put("address", device.getAddress());
//                     sendToFlutterOnMainThread("onDeviceFound", deviceInfo);
//                 }
//             }
//         }
//     };
// }



//***************************updated one to see the raw data & parsing output, Home Screen********************************/
// package com.example.sdk_connection_2;

// import android.util.Log;
// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.bluetooth.BluetoothGatt;
// import android.bluetooth.BluetoothGattCallback;
// import android.bluetooth.BluetoothGattCharacteristic;
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
// import androidx.annotation.NonNull;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;

// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
//     private BluetoothGatt bluetoothGatt;
//     private final Handler mainHandler = new Handler(Looper.getMainLooper());

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
//                             getWeightData(result);
//                             break;
//                         case "enableNotifications":
//                             String characteristicUuid = call.argument("characteristicUuid");
//                             enableNotifications(characteristicUuid, result);
//                             break;
//                         default:
//                             result.notImplemented();
//                             break;
//                     }
//                 });

//         IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
//         registerReceiver(broadcastReceiver, filter);
//         checkBluetoothPermissions();
//     }

//     private void checkBluetoothPermissions() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED ||
//                     ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
//                 ActivityCompat.requestPermissions(this, new String[]{
//                         Manifest.permission.BLUETOOTH_SCAN,
//                         Manifest.permission.BLUETOOTH_CONNECT
//                 }, 1);
//             }
//         }
//     }

//     private void startBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
//             result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
//             return;
//         }
//         bluetoothAdapter.startDiscovery();
//         result.success("Bluetooth scan started.");
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         try {
//             BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//             if (device != null) {
//                 bluetoothGatt = device.connectGatt(this, false, gattCallback);
//                 result.success("Connecting to " + device.getName());
//             } else {
//                 result.error("ERROR", "Device not found.", null);
//             }
//         } catch (IllegalArgumentException e) {
//             result.error("INVALID_ADDRESS", "Invalid Bluetooth address: " + deviceAddress, null);
//         }
//     }

//     private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
//         @Override
//         public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
//             if (newState == BluetoothGatt.STATE_CONNECTED) {
//                 bluetoothGatt = gatt;
//                 bluetoothGatt.discoverServices();
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Connected to device.");
//             } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Disconnected from device.");
//             }
//         }

//         @Override
//         public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 Map<String, List<String>> serviceAndCharacteristicMap = new HashMap<>();
//                 for (BluetoothGattService service : gatt.getServices()) {
//                     String serviceUuid = service.getUuid().toString();
//                     List<String> characteristicUuids = new ArrayList<>();
//                     for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                         characteristicUuids.add(characteristic.getUuid().toString());
//                     }
//                     serviceAndCharacteristicMap.put(serviceUuid, characteristicUuids);
//                 }
//                 sendToFlutterOnMainThread("onServicesDiscovered", serviceAndCharacteristicMap);
//             }
//         }

//         @Override
//         public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 String weight = parseWeightData(characteristic.getValue());
//                 sendToFlutterOnMainThread("onWeightDataReceived", weight);
//             }
//         }

//         @Override
//         public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
//             String weight = parseWeightData(characteristic.getValue());
//             sendToFlutterOnMainThread("onWeightDataReceived", weight);
//         }
//     };

//     private String parseWeightData(byte[] data) {
//         if (data == null || data.length == 0) {
//             Log.e("BLE", "Received empty or null data");
//             return "Invalid weight data (no data received)";
//         }

//         Log.d("BLE", "Raw data bytes: " + bytesToHex(data)); // Logs raw byte array

//         if (data.length < 4) {
//             return "Invalid weight data (insufficient length)";
//         }

//         try {
//             float weight = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN).getFloat();
//             if (weight > 0 && weight < 300) { // Assuming valid range for weight
//                 return String.format("%.2f kg", weight);
//             } else {
//                 Log.e("BLE", "Parsed weight is out of realistic range: " + weight);
//                 return "Invalid weight data (out of range)";
//             }
//         } catch (Exception e) {
//             Log.e("BLE", "Error parsing weight data", e);
//             return "Error parsing weight data";
//         }
//     }

//     private String bytesToHex(byte[] bytes) {
//         StringBuilder sb = new StringBuilder();
//         for (byte b : bytes) {
//             sb.append(String.format("%02X ", b)); // Format each byte as a two-character hex
//         }
//         return sb.toString().trim();
//     }

//     private void enableNotifications(String characteristicUuid, MethodChannel.Result result) {
//         if (bluetoothGatt != null) {
//             for (BluetoothGattService service : bluetoothGatt.getServices()) {
//                 for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                     if (characteristic.getUuid().toString().equals(characteristicUuid)) {
//                         bluetoothGatt.setCharacteristicNotification(characteristic, true);
//                         result.success("Notifications enabled for characteristic " + characteristicUuid);
//                         return;
//                     }
//                 }
//             }
//             result.error("CHARACTERISTIC_NOT_FOUND", "Characteristic not found.", null);
//         } else {
//             result.error("NO_CONNECTION", "No connected device.", null);
//         }
//     }

//     private void getWeightData(MethodChannel.Result result) {
//         if (bluetoothGatt != null) {
//             for (BluetoothGattService service : bluetoothGatt.getServices()) {
//                 for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                     if (characteristic.getProperties() == BluetoothGattCharacteristic.PROPERTY_READ) {
//                         bluetoothGatt.readCharacteristic(characteristic);
//                         result.success("Reading weight data...");
//                         return;
//                     }
//                 }
//             }
//             result.error("UUID_NOT_FOUND", "No readable characteristic found.", null);
//         } else {
//             result.error("NO_CONNECTION", "No connected device.", null);
//         }
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
//                     deviceInfo.put("name", device.getName());
//                     deviceInfo.put("address", device.getAddress());
//                     sendToFlutterOnMainThread("onDeviceFound", deviceInfo);
//                 }
//             }
//         }
//     };
// }


//********************updated one for, service id list, characteristic uuid list & number of properties for each uuid, Test Screen 3********************************/
// package com.example.sdk_connection_2;

// import android.util.Log;
// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.bluetooth.BluetoothGatt;
// import android.bluetooth.BluetoothGattCallback;
// import android.bluetooth.BluetoothGattCharacteristic;
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
// import androidx.annotation.NonNull;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;

// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
//     private BluetoothGatt bluetoothGatt;
//     private final Handler mainHandler = new Handler(Looper.getMainLooper());

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
//                             getWeightData(result);
//                             break;
//                         case "enableNotifications":
//                             String characteristicUuid = call.argument("characteristicUuid");
//                             enableNotifications(characteristicUuid, result);
//                             break;
//                         default:
//                             result.notImplemented();
//                             break;
//                     }
//                 });

//         IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
//         registerReceiver(broadcastReceiver, filter);
//         checkBluetoothPermissions();
//     }

//     private void checkBluetoothPermissions() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED ||
//                     ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
//                 ActivityCompat.requestPermissions(this, new String[] {
//                         Manifest.permission.BLUETOOTH_SCAN,
//                         Manifest.permission.BLUETOOTH_CONNECT
//                 }, 1);
//             }
//         }
//     }

//     private void startBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
//             result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
//             return;
//         }
//         bluetoothAdapter.startDiscovery();
//         result.success("Bluetooth scan started.");
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         try {
//             BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//             if (device != null) {
//                 bluetoothGatt = device.connectGatt(this, false, gattCallback);
//                 result.success("Connecting to " + device.getName());
//             } else {
//                 result.error("ERROR", "Device not found.", null);
//             }
//         } catch (IllegalArgumentException e) {
//             result.error("INVALID_ADDRESS", "Invalid Bluetooth address: " + deviceAddress, null);
//         }
//     }

//     private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
//         @Override
//         public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
//             if (newState == BluetoothGatt.STATE_CONNECTED) {
//                 bluetoothGatt = gatt;
//                 bluetoothGatt.discoverServices();
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Connected to device.");
//             } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
//                 sendToFlutterOnMainThread("onConnectionStateChange", "Disconnected from device.");
//             }
//         }

//         @Override
//         public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 Map<String, List<String>> serviceAndCharacteristicMap = new HashMap<>();
//                 for (BluetoothGattService service : gatt.getServices()) {
//                     String serviceUuid = service.getUuid().toString();
//                     List<String> characteristicUuids = new ArrayList<>();
//                     for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                         characteristicUuids.add(characteristic.getUuid().toString());

//                         // Log the characteristic properties
//                         int properties = characteristic.getProperties();
//                         Log.d("BLE", "Service UUID: " + serviceUuid + " | Characteristic UUID: " + characteristic.getUuid() + 
//                                      " | Properties: " + properties);
//                     }
//                     serviceAndCharacteristicMap.put(serviceUuid, characteristicUuids);
//                 }
//                 sendToFlutterOnMainThread("onServicesDiscovered", serviceAndCharacteristicMap);
//             }
//         }

//         @Override
//         public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 String weight = parseWeightData(characteristic.getValue());
//                 sendToFlutterOnMainThread("onWeightDataReceived", weight);
//             }
//         }

//         @Override
//         public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
//             String weight = parseWeightData(characteristic.getValue());
//             sendToFlutterOnMainThread("onWeightDataReceived", weight);
//         }
//     };

//     private String parseWeightData(byte[] data) {
//         if (data == null || data.length == 0) {
//             Log.e("BLE", "Received empty or null data");
//             return "Invalid weight data (no data received)";
//         }

//         Log.d("BLE", "Raw data bytes: " + bytesToHex(data)); // Logs raw byte array for debugging

//         if (data.length < 4) {
//             return "Invalid weight data (insufficient length)";
//         }

//         try {
//             // Parse the weight from the byte data
//             float weight = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN).getFloat();
//             if (weight > 0 && weight < 300) { // Assuming valid weight range
//                 return String.format("%.2f kg", weight);
//             } else {
//                 Log.e("BLE", "Parsed weight is out of realistic range: " + weight);
//                 return "Invalid weight data (out of range)";
//             }
//         } catch (Exception e) {
//             Log.e("BLE", "Error parsing weight data", e);
//             return "Error parsing weight data";
//         }
//     }

//     private String bytesToHex(byte[] bytes) {
//         StringBuilder sb = new StringBuilder();
//         for (byte b : bytes) {
//             sb.append(String.format("%02X ", b)); // Format each byte as a two-character hex
//         }
//         return sb.toString().trim();
//     }

//     private void enableNotifications(String characteristicUuid, MethodChannel.Result result) {
//         if (bluetoothGatt != null) {
//             for (BluetoothGattService service : bluetoothGatt.getServices()) {
//                 for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                     if (characteristic.getUuid().toString().equals(characteristicUuid)) {
//                         bluetoothGatt.setCharacteristicNotification(characteristic, true);
//                         result.success("Notifications enabled for characteristic " + characteristicUuid);
//                         return;
//                     }
//                 }
//             }
//             result.error("CHARACTERISTIC_NOT_FOUND", "Characteristic not found.", null);
//         } else {
//             result.error("NO_CONNECTION", "No connected device.", null);
//         }
//     }

//     private void getWeightData(MethodChannel.Result result) {
//         if (bluetoothGatt != null) {
//             for (BluetoothGattService service : bluetoothGatt.getServices()) {
//                 for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                     // Check for readable characteristics and attempt to read
//                     if (characteristic.getProperties() == BluetoothGattCharacteristic.PROPERTY_READ) {
//                         bluetoothGatt.readCharacteristic(characteristic);
//                         result.success("Reading weight data...");
//                         return;
//                     }
//                 }
//             }
//             result.error("UUID_NOT_FOUND", "No readable characteristic found.", null);
//         } else {
//             result.error("NO_CONNECTION", "No connected device.", null);
//         }
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
//                     deviceInfo.put("name", device.getName());
//                     deviceInfo.put("address", device.getAddress());
//                     sendToFlutterOnMainThread("onDeviceFound", deviceInfo);
//                 }
//             }
//         }
//     };
// }


//***************************getting weight as 0 kg, screen 3*********************** */
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


//*****************************Update one , Screen4********************************/
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


//*****doing changes to fetch the realtime data, screen4*********************/
package com.example.sdk_connection_2;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.Manifest;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "BLEWeightConnection";
    private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothGatt bluetoothGatt;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    // Comprehensive list of potential weight-related service UUIDs
    private final List<String> weightServiceUuids = Arrays.asList(
        "0000181d-0000-1000-8000-00805f9b34fb",  // Weight Scale Service
        "00001530-1212-efde-1523-785feabcd123",  // Custom device service
        "0000ffb0-0000-1000-8000-00805f9b34fb"   // Another potential service
    );

    // Potential weight characteristic UUID patterns
    private final List<String> weightCharacteristicPatterns = Arrays.asList(
        "weight", "mass", "scale", 
        "1531", "1532", "1534", 
        "ffb1", "ffb2", "ffb3"
    );

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "startScan":
                            startBluetoothScan(result);
                            break;
                        case "connectToDevice":
                            String deviceAddress = call.argument("deviceAddress");
                            if (deviceAddress != null && !deviceAddress.isEmpty()) {
                                connectToDevice(deviceAddress, result);
                            } else {
                                result.error("INVALID_ADDRESS", "Device address cannot be null or empty.", null);
                            }
                            break;
                        case "getWeightData":
                            String serviceUuid = call.argument("serviceUuid");
                            String characteristicUuid = call.argument("characteristicUuid");
                            getWeightData(serviceUuid, characteristicUuid, result);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                });

        // Register broadcast receiver for device discovery
        IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
        registerReceiver(broadcastReceiver, filter);
        
        // Check and request necessary permissions
        checkBluetoothPermissions();
    }

    private void checkBluetoothPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            String[] requiredPermissions = {
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.ACCESS_FINE_LOCATION
            };

            List<String> missingPermissions = new ArrayList<>();
            for (String permission : requiredPermissions) {
                if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                    missingPermissions.add(permission);
                }
            }

            if (!missingPermissions.isEmpty()) {
                ActivityCompat.requestPermissions(this, 
                    missingPermissions.toArray(new String[0]), 1);
            }
        }
    }

    private void startBluetoothScan(MethodChannel.Result result) {
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not supported on this device", null);
            return;
        }

        if (!bluetoothAdapter.isEnabled()) {
            result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled", null);
            return;
        }

        bluetoothAdapter.startDiscovery();
        result.success("Bluetooth scan started");
        Log.d(TAG, "Bluetooth scan started");
    }

    private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
        try {
            BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
            if (device != null) {
                bluetoothGatt = device.connectGatt(this, false, gattCallback);
                result.success("Connecting to " + (device.getName() != null ? device.getName() : "Unknown Device"));
                Log.d(TAG, "Attempting to connect to device: " + deviceAddress);
            } else {
                result.error("DEVICE_NOT_FOUND", "Device not found", null);
            }
        } catch (IllegalArgumentException e) {
            result.error("INVALID_ADDRESS", "Invalid Bluetooth address", null);
            Log.e(TAG, "Invalid Bluetooth address", e);
        }
    }

    private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            if (newState == BluetoothGatt.STATE_CONNECTED) {
                Log.d(TAG, "Connected to GATT server");
                gatt.discoverServices();
                sendToFlutterOnMainThread("onConnectionStateChange", "Connected");
            } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
                Log.d(TAG, "Disconnected from GATT server");
                sendToFlutterOnMainThread("onConnectionStateChange", "Disconnected");
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "Services discovered");
                Map<String, List<String>> serviceMap = new HashMap<>();
                
                for (BluetoothGattService service : gatt.getServices()) {
                    String serviceUuid = service.getUuid().toString();
                    List<String> characteristics = new ArrayList<>();
                    
                    for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                        characteristics.add(characteristic.getUuid().toString());
                    }
                    
                    serviceMap.put(serviceUuid, characteristics);
                }
                
                sendToFlutterOnMainThread("onServicesDiscovered", serviceMap);
            } else {
                Log.e(TAG, "onServicesDiscovered received: " + status);
            }
        }


     

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                processWeightData(characteristic.getValue());
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            processWeightData(characteristic.getValue());
        }
    };

    private void processWeightData(byte[] data) {
        if (data == null || data.length == 0) {
            Log.w(TAG, "No weight data received");
            sendToFlutterOnMainThread("onWeightDataReceived", "No data");
            return;
        }

        try {
            float weightKg = parseWeightData(data);
            String weightString = String.format("%.2f kg", weightKg);
            Log.d(TAG, "Processed weight: " + weightString);
            sendToFlutterOnMainThread("onWeightDataReceived", weightString);
        } catch (Exception e) {
            Log.e(TAG, "Error parsing weight data", e);
            sendToFlutterOnMainThread("onWeightDataReceived", "Data parsing error");
        }
    }

    private float parseWeightData(byte[] data) {
        // Multiple parsing strategies
        float parsedWeight = 0f;
        
        try {
            // Strategy 1: Little Endian Float
            ByteBuffer buffer = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN);
            parsedWeight = buffer.getFloat();
            return parsedWeight;
        } catch (Exception e1) {
            try {
                // Strategy 2: Big Endian Float
                ByteBuffer buffer = ByteBuffer.wrap(data).order(ByteOrder.BIG_ENDIAN);
                parsedWeight = buffer.getFloat();
                return parsedWeight;
            } catch (Exception e2) {
                // Strategy 3: Byte manipulation
                int intBits = 0;
                for (int i = 0; i < Math.min(4, data.length); i++) {
                    intBits |= (data[i] & 0xFF) << (8 * i);
                }
                return Float.intBitsToFloat(intBits);
            }
        }
    }

    private void getWeightData(String specifiedServiceUuid, String specifiedCharacteristicUuid, MethodChannel.Result result) {
        if (bluetoothGatt == null) {
            result.error("NO_CONNECTION", "No active Bluetooth connection", null);
            return;
        }

        for (BluetoothGattService service : bluetoothGatt.getServices()) {
            String serviceUuid = service.getUuid().toString().toUpperCase();

            // Check if service matches specified or known weight service UUIDs
            boolean isTargetService = (specifiedServiceUuid != null && serviceUuid.equals(specifiedServiceUuid.toUpperCase())) ||
                                      weightServiceUuids.stream().anyMatch(uuid -> uuid.toUpperCase().equals(serviceUuid));

            if (isTargetService) {
                for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                    String characteristicUuid = characteristic.getUuid().toString().toUpperCase();
                    
                    // Check if characteristic matches specified or contains weight patterns
                    boolean isTargetCharacteristic = 
                        (specifiedCharacteristicUuid != null && characteristicUuid.equals(specifiedCharacteristicUuid.toUpperCase())) ||
                        weightCharacteristicPatterns.stream().anyMatch(pattern -> characteristicUuid.contains(pattern.toUpperCase()));

                    if (isTargetCharacteristic) {
                        int properties = characteristic.getProperties();
                        
                        // Enable notifications if supported
                        bluetoothGatt.setCharacteristicNotification(characteristic, true);
                        
                        // Try to read the characteristic
                        if ((properties & BluetoothGattCharacteristic.PROPERTY_READ) > 0) {
                            bluetoothGatt.readCharacteristic(characteristic);
                            result.success("Reading weight data...");
                            return;
                        }
                    }
                }
            }
        }
        
        result.error("NO_WEIGHT_CHARACTERISTIC", "No suitable weight characteristic found", null);
    }

    private void sendToFlutterOnMainThread(String method, Object arguments) {
        mainHandler.post(() -> new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .invokeMethod(method, arguments));
    }

    private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (BluetoothDevice.ACTION_FOUND.equals(intent.getAction())) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                if (device != null) {
                    Map<String, String> deviceInfo = new HashMap<>();
                    deviceInfo.put("name", device.getName() != null ? device.getName() : "Unknown Device");
                    deviceInfo.put("address", device.getAddress());
                    sendToFlutterOnMainThread("onDeviceFound", deviceInfo);
                }
            }
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        
        // Unregister broadcast receiver
        try {
            unregisterReceiver(broadcastReceiver);
        } catch (IllegalArgumentException e) {
            Log.w(TAG, "Broadcast receiver not registered", e);
        }
        
        // Close Bluetooth GATT connection
        if (bluetoothGatt != null) {
            bluetoothGatt.close();
            bluetoothGatt = null;
        }
    }
}



