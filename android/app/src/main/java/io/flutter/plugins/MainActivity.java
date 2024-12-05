

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


//*****************making changes adding the uuids & testing which one is for weight**************************/
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
//     if (connectedDevice == null || bluetoothGatt == null) {
//         result.error("NO_CONNECTION", "No device connected.", null);
//         return;
//     }

//     for (BluetoothGattService service : bluetoothGatt.getServices()) {
//         for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//             // Try reading each characteristic
//             boolean success = bluetoothGatt.readCharacteristic(characteristic);
//             if (success) {
//                 // Log or send the service and characteristic UUIDs to Flutter for testing
//                 sendToFlutterOnMainThread("onCharacteristicTest", 
//                     "Testing Service UUID: " + service.getUuid() + 
//                     ", Characteristic UUID: " + characteristic.getUuid());
//             }
//         }
//     }
// }


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



//*************************updated read characteristic function*********************************/
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
//         if (connectedDevice == null || bluetoothGatt == null) {
//             result.error("NO_CONNECTION", "No device connected.", null);
//             return;
//         }

//         for (BluetoothGattService service : bluetoothGatt.getServices()) {
//             for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                 // Try reading each characteristic
//                 boolean success = bluetoothGatt.readCharacteristic(characteristic);
//                 if (success) {
//                     // Log or send the service and characteristic UUIDs to Flutter for testing
//                     sendToFlutterOnMainThread("onCharacteristicTest", 
//                         "Testing Service UUID: " + service.getUuid() + 
//                         ", Characteristic UUID: " + characteristic.getUuid());
//                 }
//             }
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
//     private final Handler mainHandler = new Handler(Looper.getMainLooper());
    
//     private static final int REQUEST_ENABLE_BT = 1;

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
//             startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
//             result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
//             return;
//         }
//         bluetoothAdapter.startDiscovery();
//         result.success("Bluetooth scan started.");
//     }

//     private void stopBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter != null && bluetoothAdapter.isDiscovering()) {
//             bluetoothAdapter.cancelDiscovery();
//             result.success("Bluetooth scan stopped.");
//         } else {
//             result.error("SCAN_ERROR", "No ongoing Bluetooth scan to stop.", null);
//         }
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

        

// @Override
// public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//     if (status == BluetoothGatt.GATT_SUCCESS) {
//         Map<String, List<String>> serviceAndCharacteristicMap = new HashMap<>();

//         for (BluetoothGattService service : gatt.getServices()) {
//             String serviceUuid = service.getUuid().toString();
//             List<String> characteristicUuids = new ArrayList<>();

//             for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                 characteristicUuids.add(characteristic.getUuid().toString());
//                 // Log discovered characteristics
//                 Log.d("Discovered Characteristic", "UUID: " + characteristic.getUuid());
//             }

//             serviceAndCharacteristicMap.put(serviceUuid, characteristicUuids);
//         }

//         // Send discovered services and characteristics to Flutter
//         sendToFlutterOnMainThread("onServicesDiscovered", serviceAndCharacteristicMap);
//     } else {
//         sendToFlutterOnMainThread("onServicesDiscoveredError", "Failed to discover services.");
//     }
// }




//     // Example UUID for weight data characteristic
// UUID WEIGHT_CHARACTERISTIC_UUID = UUID.fromString("0000ffb1-0000-1000-8000-00805f9b34fb");

// @Override
// public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//     if (status == BluetoothGatt.GATT_SUCCESS) {
//         // Check if this is the weight characteristic
//         if (characteristic.getUuid().equals(WEIGHT_CHARACTERISTIC_UUID)) {
//             String weightData = new String(characteristic.getValue());

//             try {
//                 float weight = Float.parseFloat(weightData); // Parse to float if it's numeric
//                 sendToFlutterOnMainThread("onWeightDataReceived", weight);
//             } catch (NumberFormatException e) {
//                 sendToFlutterOnMainThread("onWeightDataError", "Error parsing weight data.");
//             }
//         }
//     } else {
//         sendToFlutterOnMainThread("onWeightDataError", "Failed to read characteristic.");
//     }
// }


//     private void getWeightData(MethodChannel.Result result) {
//         if (connectedDevice == null || bluetoothGatt == null) {
//             result.error("NO_CONNECTION", "No device connected.", null);
//             return;
//         }

//         for (BluetoothGattService service : bluetoothGatt.getServices()) {
//             for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                 // Try reading each characteristic
//                 boolean success = bluetoothGatt.readCharacteristic(characteristic);
//                 if (success) {
//                     // Log or send the service and characteristic UUIDs to Flutter for testing
//                     sendToFlutterOnMainThread("onCharacteristicTest", 
//                         "Testing Service UUID: " + service.getUuid() + 
//                         ", Characteristic UUID: " + characteristic.getUuid());
//                 }
//             }
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
// }


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

// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
//     private BluetoothGatt bluetoothGatt;
//     private BluetoothDevice connectedDevice;
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
//                 if (characteristic.getUuid().toString().equals("0000ffb3-0000-1000-8000-00805f9b34fb")) {
//                     byte[] data = characteristic.getValue();
//                     String weight = parseWeightData(data);
//                     sendToFlutterOnMainThread("onWeightDataReceived", weight);
//                 }
//             } else {
//                 Log.e("BLE", "Failed to read characteristic: " + status);
//             }
//         }
//     };

//     private String parseWeightData(byte[] data) {
//         if (data != null && data.length > 0) {
//             int weight = data[0];
//             return weight + " kg";
//         }
//         return "Invalid weight data";
//     }

//     //updated one
//     private void getWeightData(MethodChannel.Result result) {
//     if (bluetoothGatt == null) {
//         result.error("NO_CONNECTION", "No connected device.", null);
//         return;
//     }

//     // Log all services and characteristics
//     List<BluetoothGattService> services = bluetoothGatt.getServices();
//     Map<String, List<String>> serviceAndCharacteristicMap = new HashMap<>();
    
//     for (BluetoothGattService service : services) {
//         String serviceUuid = service.getUuid().toString();
//         List<String> characteristicUuids = new ArrayList<>();
//         for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//             String characteristicUuid = characteristic.getUuid().toString();
//             characteristicUuids.add(characteristicUuid);
//             Log.d("BLE", "Service UUID: " + serviceUuid + " | Characteristic UUID: " + characteristicUuid);
//         }
//         serviceAndCharacteristicMap.put(serviceUuid, characteristicUuids);
//     }

//     // Send to Flutter for debugging purposes
//     sendToFlutterOnMainThread("onServicesDiscovered", serviceAndCharacteristicMap);

//     // Now, let's search for the correct UUID for the weight characteristic
//     boolean foundWeightCharacteristic = false;

//     // Replace these with the UUIDs you want to check
//     String[] weightCharacteristicUuids = new String[]{
//         "0000ffb1-0000-1000-8000-00805f9b34fb", // Example UUID
//         "0000ffb2-0000-1000-8000-00805f9b34fb",
//         "0000ffb3-0000-1000-8000-00805f9b34fb"  // Another example UUID
//     };

//     for (BluetoothGattService service : services) {
//         for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//             String characteristicUuid = characteristic.getUuid().toString();

//             // Check if this is a weight characteristic
//             for (String weightUuid : weightCharacteristicUuids) {
//                 if (characteristicUuid.equals(weightUuid)) {
//                     bluetoothGatt.readCharacteristic(characteristic);
//                     foundWeightCharacteristic = true;
//                     result.success("Reading weight data...");
//                     Log.d("BLE", "Reading characteristic with UUID: " + weightUuid);
//                     return;
//                 }
//             }
//         }
//     }

//     if (!foundWeightCharacteristic) {
//         result.error("UUID_NOT_FOUND", "No matching weight characteristic found.", null);
//     }
// }


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



//updated one with complete uuid hsndling, getting some response in weight data , when i used it in home screen

import android.util.Log;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
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
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothGatt bluetoothGatt;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

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
                            getWeightData(result);
                            break;
                        case "enableNotifications":
                            String characteristicUuid = call.argument("characteristicUuid");
                            enableNotifications(characteristicUuid, result);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                });

        IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
        registerReceiver(broadcastReceiver, filter);
        checkBluetoothPermissions();
    }

    private void checkBluetoothPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED ||
                    ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, new String[]{
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.BLUETOOTH_CONNECT
                }, 1);
            }
        }
    }

    private void startBluetoothScan(MethodChannel.Result result) {
        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
            return;
        }
        bluetoothAdapter.startDiscovery();
        result.success("Bluetooth scan started.");
    }

    private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
        try {
            BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
            if (device != null) {
                bluetoothGatt = device.connectGatt(this, false, gattCallback);
                result.success("Connecting to " + device.getName());
            } else {
                result.error("ERROR", "Device not found.", null);
            }
        } catch (IllegalArgumentException e) {
            result.error("INVALID_ADDRESS", "Invalid Bluetooth address: " + deviceAddress, null);
        }
    }

    private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            if (newState == BluetoothGatt.STATE_CONNECTED) {
                bluetoothGatt = gatt;
                bluetoothGatt.discoverServices();
                sendToFlutterOnMainThread("onConnectionStateChange", "Connected to device.");
            } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
                sendToFlutterOnMainThread("onConnectionStateChange", "Disconnected from device.");
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Map<String, List<String>> serviceAndCharacteristicMap = new HashMap<>();
                for (BluetoothGattService service : gatt.getServices()) {
                    String serviceUuid = service.getUuid().toString();
                    List<String> characteristicUuids = new ArrayList<>();
                    for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                        characteristicUuids.add(characteristic.getUuid().toString());
                    }
                    serviceAndCharacteristicMap.put(serviceUuid, characteristicUuids);
                }
                sendToFlutterOnMainThread("onServicesDiscovered", serviceAndCharacteristicMap);
            }
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                String weight = parseWeightData(characteristic.getValue());
                sendToFlutterOnMainThread("onWeightDataReceived", weight);
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            String weight = parseWeightData(characteristic.getValue());
            sendToFlutterOnMainThread("onWeightDataReceived", weight);
        }
    };

    private String parseWeightData(byte[] data) {
        if (data != null && data.length >= 4) {
            float weight = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN).getFloat();
            return String.format("%.2f kg", weight);
        }
        return "Invalid weight data";
    }

    private void enableNotifications(String characteristicUuid, MethodChannel.Result result) {
        if (bluetoothGatt != null) {
            for (BluetoothGattService service : bluetoothGatt.getServices()) {
                for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                    if (characteristic.getUuid().toString().equals(characteristicUuid)) {
                        bluetoothGatt.setCharacteristicNotification(characteristic, true);
                        result.success("Notifications enabled for characteristic " + characteristicUuid);
                        return;
                    }
                }
            }
            result.error("CHARACTERISTIC_NOT_FOUND", "Characteristic not found.", null);
        } else {
            result.error("NO_CONNECTION", "No connected device.", null);
        }
    }

    private void getWeightData(MethodChannel.Result result) {
        if (bluetoothGatt != null) {
            for (BluetoothGattService service : bluetoothGatt.getServices()) {
                for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                    if (characteristic.getProperties() == BluetoothGattCharacteristic.PROPERTY_READ) {
                        bluetoothGatt.readCharacteristic(characteristic);
                        result.success("Reading weight data...");
                        return;
                    }
                }
            }
            result.error("UUID_NOT_FOUND", "No readable characteristic found.", null);
        } else {
            result.error("NO_CONNECTION", "No connected device.", null);
        }
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
                    deviceInfo.put("name", device.getName());
                    deviceInfo.put("address", device.getAddress());
                    sendToFlutterOnMainThread("onDeviceFound", deviceInfo);
                }
            }
        }
    };
}
