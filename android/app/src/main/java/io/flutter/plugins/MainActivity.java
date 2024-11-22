

// //************************able to get device list & connect with them also getting one uuid DM Screen***********************/
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





//***************************8updated code for getting dynamic uuids, Testscreen2/TestScreen****************/

// package com.example.sdk_connection_2;

// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.bluetooth.BluetoothGatt;
// import android.bluetooth.BluetoothGattCallback;
// import android.bluetooth.BluetoothGattCharacteristic;
// import android.bluetooth.BluetoothGattService;
// import android.bluetooth.le.BluetoothLeScanner;
// import android.bluetooth.le.ScanCallback;
// import android.bluetooth.le.ScanResult;
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
// import java.util.HashMap;
// import java.util.Map;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
//     private BluetoothLeScanner bluetoothLeScanner;
//     private BluetoothGatt bluetoothGatt;
//     private BluetoothDevice connectedDevice;
//     private BluetoothGattCharacteristic activeCharacteristic;

//     @Override
//     public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//         super.configureFlutterEngine(flutterEngine);
//         bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
//         bluetoothLeScanner = bluetoothAdapter.getBluetoothLeScanner();

//         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .setMethodCallHandler((call, result) -> {
//                 switch (call.method) {
//                     case "startScan":
//                         startBluetoothScan(result);
//                         break;
//                     case "connectToDevice":
//                         String deviceAddress = call.argument("deviceAddress");
//                         if (deviceAddress == null || deviceAddress.isEmpty()) {
//                             result.error("INVALID_ADDRESS", "Device address cannot be null or empty.", null);
//                         } else {
//                             connectToDevice(deviceAddress, result);
//                         }
//                         break;
//                     case "getWeightData":
//                         getWeightData(result);
//                         break;
//                     default:
//                         result.notImplemented();
//                         break;
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
//                     Manifest.permission.BLUETOOTH_SCAN,
//                     Manifest.permission.BLUETOOTH_CONNECT
//                 }, 1);
//             }
//         }
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
//                 ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
//             }
//         }
//     }

//     private void startBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
//             result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
//             return;
//         }

//         bluetoothLeScanner.startScan(new ScanCallback() {
//             @Override
//             public void onScanResult(int callbackType, ScanResult result) {
//                 BluetoothDevice device = result.getDevice();
//                 Map<String, String> deviceInfo = new HashMap<>();
//                 deviceInfo.put("name", device.getName());
//                 deviceInfo.put("address", device.getAddress());
//                 new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                         .invokeMethod("onDeviceFound", deviceInfo);
//             }

//             @Override
//             public void onScanFailed(int errorCode) {
//                 super.onScanFailed(errorCode);
//                 Map<String, String> errorInfo = new HashMap<>();
//                 errorInfo.put("error", "Scan failed with error code: " + errorCode);
//                 new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                         .invokeMethod("onScanError", errorInfo);
//             }
//         });
//         result.success("Bluetooth scan started.");
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//         if (device == null) {
//             result.error("ERROR", "Device not found.", null);
//             return;
//         }

//         connectedDevice = device;
//         bluetoothGatt = device.connectGatt(this, false, new BluetoothGattCallback() {
//             @Override
//             public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//                 if (status == BluetoothGatt.GATT_SUCCESS) {
//                     for (BluetoothGattService service : gatt.getServices()) {
//                         for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                             activeCharacteristic = characteristic;
//                             Map<String, String> serviceInfo = new HashMap<>();
//                             serviceInfo.put("serviceUuid", service.getUuid().toString());
//                             serviceInfo.put("characteristicUuid", characteristic.getUuid().toString());
//                             sendDeviceDetails(serviceInfo);
//                         }
//                     }
//                     result.success("Connected to device: " + device.getName());
//                 }
//             }
//         });
//     }

//     private void getWeightData(MethodChannel.Result result) {
//         if (bluetoothGatt == null || activeCharacteristic == null) {
//             result.error("NO_CONNECTION", "No device or characteristic connected.", null);
//             return;
//         }

//         bluetoothGatt.readCharacteristic(activeCharacteristic);
//         result.success("Reading weight data...");
//     }

//     private void sendDeviceDetails(Map<String, String> serviceInfo) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onDeviceDetailsReceived", serviceInfo);
//     }

//     private void sendWeightData(Map<String, String> weightData) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onWeightDataReceived", weightData);
//     }

//     private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
//         @Override
//         public void onReceive(Context context, Intent intent) {
//             if (BluetoothDevice.ACTION_FOUND.equals(intent.getAction())) {
//                 BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
//                 if (device != null && device.getType() == BluetoothDevice.DEVICE_TYPE_LE) {
//                     Map<String, String> deviceInfo = new HashMap<>();
//                     deviceInfo.put("name", device.getName());
//                     deviceInfo.put("address", device.getAddress());
//                     new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                         .invokeMethod("onDeviceFound", deviceInfo);
//                 }
//             }
//         }
//     };

//     @Override
//     public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
//         super.onRequestPermissionsResult(requestCode, permissions, grantResults);
//         if (requestCode == 1) {
//             if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                 checkBluetoothPermissions();
//             }
//         }
//     }
// }


//***************************updated code to discover the services  & get the uuids , Test Screen3************************/
// package com.example.sdk_connection_2;

// import android.Manifest;
// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.bluetooth.BluetoothGatt;
// import android.bluetooth.BluetoothGattCallback;
// import android.bluetooth.BluetoothGattCharacteristic;
// import android.bluetooth.BluetoothGattService;
// import android.bluetooth.le.ScanCallback;
// import android.bluetooth.le.ScanResult;
// import android.content.pm.PackageManager;
// import android.os.Build;
// import android.os.Handler;

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
//     private final List<Map<String, String>> scannedDevices = new ArrayList<>();
//     private static final int REQUEST_PERMISSIONS = 1;
//     private MethodChannel.Result permissionResultCallback;

//     @Override
//     public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//         super.configureFlutterEngine(flutterEngine);
//         bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

//         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//                 .setMethodCallHandler((call, result) -> {
//                     switch (call.method) {
//                         case "checkPermissions":
//                             checkPermissions(result);
//                             break;
//                         case "startScan":
//                             startBluetoothScan(result);
//                             break;
//                         case "connectToDevice":
//                             String deviceAddress = call.argument("deviceAddress");
//                             connectToDevice(deviceAddress, result);
//                             break;
//                         case "discoverServices":
//                             discoverServices(result);
//                             break;
//                         default:
//                             result.notImplemented();
//                             break;
//                     }
//                 });
//     }

//     private void checkPermissions(MethodChannel.Result result) {
//         List<String> permissions = new ArrayList<>();

//         if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
//             permissions.add(Manifest.permission.ACCESS_FINE_LOCATION);
//         }

//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED) {
//                 permissions.add(Manifest.permission.BLUETOOTH_SCAN);
//             }
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
//                 permissions.add(Manifest.permission.BLUETOOTH_CONNECT);
//             }
//         } else {
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED) {
//                 permissions.add(Manifest.permission.BLUETOOTH);
//             }
//             if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_ADMIN) != PackageManager.PERMISSION_GRANTED) {
//                 permissions.add(Manifest.permission.BLUETOOTH_ADMIN);
//             }
//         }

//         if (permissions.isEmpty()) {
//             result.success(true);
//         } else {
//             permissionResultCallback = result;
//             ActivityCompat.requestPermissions(this, permissions.toArray(new String[0]), REQUEST_PERMISSIONS);
//         }
//     }

//     @Override
//     public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
//         super.onRequestPermissionsResult(requestCode, permissions, grantResults);

//         if (requestCode == REQUEST_PERMISSIONS) {
//             boolean allGranted = true;
//             for (int grantResult : grantResults) {
//                 if (grantResult != PackageManager.PERMISSION_GRANTED) {
//                     allGranted = false;
//                     break;
//                 }
//             }
//             if (permissionResultCallback != null) {
//                 permissionResultCallback.success(allGranted);
//                 permissionResultCallback = null;
//             }
//         }
//     }

//     private void startBluetoothScan(MethodChannel.Result result) {
//         if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
//             result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available or enabled.", null);
//             return;
//         }

//         bluetoothAdapter.getBluetoothLeScanner().startScan(scanCallback);
//         new Handler().postDelayed(() -> bluetoothAdapter.getBluetoothLeScanner().stopScan(scanCallback), 10000); // Stop scanning after 10 seconds
//         result.success("Bluetooth scan started.");
//     }

//     private final ScanCallback scanCallback = new ScanCallback() {
//         @Override
//         public void onScanResult(int callbackType, ScanResult result) {
//             BluetoothDevice device = result.getDevice();
//             Map<String, String> deviceInfo = new HashMap<>();
//             deviceInfo.put("name", device.getName() != null ? device.getName() : "Unknown Device");
//             deviceInfo.put("address", device.getAddress());

//             if (!scannedDevices.contains(deviceInfo)) {
//                 scannedDevices.add(deviceInfo);
//                 sendScannedDevicesToFlutter();
//             }
//         }
//     };

//     private void sendScannedDevicesToFlutter() {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                 .invokeMethod("onScanResult", scannedDevices);
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         if (deviceAddress == null || deviceAddress.isEmpty()) {
//             result.error("INVALID_ADDRESS", "Device address is invalid.", null);
//             return;
//         }
//         BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//         bluetoothGatt = device.connectGatt(this, false, gattCallback);
//         result.success("Connecting to " + device.getName());
//     }

//     private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
//         @Override
//         public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
//             if (newState == BluetoothGatt.STATE_CONNECTED) {
//                 gatt.discoverServices();
//             }
//         }

//         @Override
//         public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 List<Map<String, Object>> services = new ArrayList<>();
//                 for (BluetoothGattService service : gatt.getServices()) {
//                     Map<String, Object> serviceInfo = new HashMap<>();
//                     serviceInfo.put("serviceUuid", service.getUuid().toString());
//                     List<Map<String, String>> characteristics = new ArrayList<>();
//                     for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                         Map<String, String> charInfo = new HashMap<>();
//                         charInfo.put("characteristicUuid", characteristic.getUuid().toString());
//                         characteristics.add(charInfo);
//                     }
//                     serviceInfo.put("characteristics", characteristics);
//                     services.add(serviceInfo);
//                 }
//                 sendServicesToFlutter(services);
//             }
//         }
//     };

//     private void discoverServices(MethodChannel.Result result) {
//         if (bluetoothGatt == null) {
//             result.error("NO_CONNECTION", "No connected device to discover services.", null);
//             return;
//         }
//         bluetoothGatt.discoverServices();
//         result.success("Service discovery started.");
//     }

//     private void sendServicesToFlutter(List<Map<String, Object>> services) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                 .invokeMethod("onServicesDiscovered", services);
//     }
// }


//*************updated sdk to resolve not getting uuid issue, Test Screen2**********************/
package com.example.sdk_connection_2;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.Manifest;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeScanner bluetoothLeScanner;
    private BluetoothGatt bluetoothGatt;
    private BluetoothDevice connectedDevice;
    private BluetoothGattCharacteristic activeCharacteristic;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        bluetoothLeScanner = bluetoothAdapter.getBluetoothLeScanner();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "startScan":
                    startBluetoothScan(result);
                    break;
                case "connectToDevice":
                    String deviceAddress = call.argument("deviceAddress");
                    if (deviceAddress == null || deviceAddress.isEmpty()) {
                        result.error("INVALID_ADDRESS", "Device address cannot be null or empty.", null);
                    } else {
                        connectToDevice(deviceAddress, result);
                    }
                    break;
                case "getWeightData":
                    getWeightData(result);
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
            }
        }
    }

    private void startBluetoothScan(MethodChannel.Result result) {
        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
            return;
        }

        bluetoothLeScanner.startScan(new ScanCallback() {
            @Override
            public void onScanResult(int callbackType, ScanResult result) {
                BluetoothDevice device = result.getDevice();
                Map<String, String> deviceInfo = new HashMap<>();
                deviceInfo.put("name", device.getName());
                deviceInfo.put("address", device.getAddress());
                new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                    .invokeMethod("onDeviceFound", deviceInfo);
            }

            @Override
            public void onScanFailed(int errorCode) {
                super.onScanFailed(errorCode);
                Map<String, String> errorInfo = new HashMap<>();
                errorInfo.put("error", "Scan failed with error code: " + errorCode);
                new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                    .invokeMethod("onScanError", errorInfo);
            }
        });
        result.success("Bluetooth scan started.");
    }

    private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
        BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
        if (device == null) {
            result.error("ERROR", "Device not found.", null);
            return;
        }

        connectedDevice = device;
        bluetoothGatt = device.connectGatt(this, false, new BluetoothGattCallback() {
            @Override
            public void onServicesDiscovered(BluetoothGatt gatt, int status) {
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    for (BluetoothGattService service : gatt.getServices()) {
                        for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                            // Log the UUIDs for debugging
                System.out.println("Service UUID: " + service.getUuid());
                System.out.println("Characteristic UUID: " + characteristic.getUuid());
                            activeCharacteristic = characteristic;
                            Map<String, String> serviceInfo = new HashMap<>();
                            serviceInfo.put("serviceUuid", service.getUuid().toString());
                            serviceInfo.put("characteristicUuid", characteristic.getUuid().toString());
                            sendDeviceDetails(serviceInfo);
                        }
                    }
                    result.success("Connected to device: " + device.getName());
                }
            }

            //if the above one failde try this one
//             @Override
// public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//     if (status == BluetoothGatt.GATT_SUCCESS) {
//         for (BluetoothGattService service : gatt.getServices()) {
//             for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                 // Log the UUIDs for debugging
//                 System.out.println("Service UUID: " + service.getUuid());
//                 System.out.println("Characteristic UUID: " + characteristic.getUuid());

//                 // Store the active characteristic for reading/writing
//                 if (characteristic.getProperties() == BluetoothGattCharacteristic.PROPERTY_READ) {
//                     activeCharacteristic = characteristic; // Set characteristic for reading
//                 }

//                 // Send UUID data back to Flutter (optional)
//                 Map<String, String> serviceInfo = new HashMap<>();
//                 serviceInfo.put("serviceUuid", service.getUuid().toString());
//                 serviceInfo.put("characteristicUuid", characteristic.getUuid().toString());
//                 sendDeviceDetails(serviceInfo);
//             }
//         }
//     } else {
//         System.err.println("Service discovery failed with status: " + status);
//     }
// }



            
        });
    }

    

    private void getWeightData(MethodChannel.Result result) {
        if (bluetoothGatt == null || activeCharacteristic == null) {
            result.error("NO_CONNECTION", "No device or characteristic connected.", null);
            return;
        }

        bluetoothGatt.readCharacteristic(activeCharacteristic);
        result.success("Reading weight data...");
    }

    // if above weightData doesnt work then try this
//     private void getWeightData(MethodChannel.Result result) {
//     if (bluetoothGatt != null && activeCharacteristic != null) {
//         boolean readInitiated = bluetoothGatt.readCharacteristic(activeCharacteristic);
//         if (!readInitiated) {
//             result.error("READ_ERROR", "Failed to initiate characteristic read.", null);
//         }
//     } else {
//         result.error("NO_CONNECTION", "No connected device or characteristic found.", null);
//     }
// }


    private void sendDeviceDetails(Map<String, String> serviceInfo) {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
            .invokeMethod("onDeviceDetailsReceived", serviceInfo);
    }

    private void sendWeightData(Map<String, String> weightData) {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
            .invokeMethod("onWeightDataReceived", weightData);
    }

    private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (BluetoothDevice.ACTION_FOUND.equals(intent.getAction())) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                if (device != null && device.getType() == BluetoothDevice.DEVICE_TYPE_LE) {
                    Map<String, String> deviceInfo = new HashMap<>();
                    deviceInfo.put("name", device.getName());
                    deviceInfo.put("address", device.getAddress());
                    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                        .invokeMethod("onDeviceFound", deviceInfo);
                }
            }
        }
    };

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 1) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                checkBluetoothPermissions();
            }
        }
    }
}

