
//****************************update 2.1, in this i am able to see list of devices & able to connect them, Device Manager Screen****************************/
// package com.example.sdk_connection_2;
// import android.bluetooth.BluetoothAdapter;
// import android.bluetooth.BluetoothDevice;
// import android.content.BroadcastReceiver;
// import android.content.Context;
// import android.content.Intent;
// import android.content.IntentFilter;
// import androidx.annotation.NonNull;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;
// import android.bluetooth.BluetoothManager;
// import android.content.pm.PackageManager;
// import android.Manifest;
// import android.os.Build;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;

// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
//     private BluetoothAdapter bluetoothAdapter;
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
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//         if (device != null) {
//             connectedDevice = device;
//             result.success("Connected to " + device.getName());
//         } else {
//             result.error("ERROR", "Device not found.", null);
//         }
//     }

//     private void getWeightData(MethodChannel.Result result) {
//         if (connectedDevice != null) {
//             String weight = "70 kg";
//             result.success(weight);
//         } else {
//             result.error("NO_DEVICE", "No device connected", null);
//         }
//     }

//     private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
//         @Override
//         public void onReceive(Context context, Intent intent) {
//             String action = intent.getAction();
//             if (BluetoothDevice.ACTION_FOUND.equals(action)) {
//                 BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
//                 String deviceName = device.getName();
//                 String deviceAddress = device.getAddress();

//                 Map<String, String> deviceInfo = new HashMap<>();
//                 deviceInfo.put("name", deviceName);
//                 deviceInfo.put("address", deviceAddress);

//                 new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                     .invokeMethod("onDeviceFound", deviceInfo);
//             }
//         }
//     };

//     @Override
//     protected void onDestroy() {
//         super.onDestroy();
//         unregisterReceiver(broadcastReceiver);
//     }
// }






//GATT Communication 1, this one is working*****************
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
// import androidx.annotation.NonNull;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;
// import android.bluetooth.BluetoothManager;
// import android.content.pm.PackageManager;
// import android.Manifest;
// import android.os.Build;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;

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
//                     connectToDevice(deviceAddress, result);
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
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//         if (device != null) {
//             connectedDevice = device;
//             bluetoothGatt = device.connectGatt(this, false, gattCallback);
//             result.success("Connecting to " + device.getName());
//         } else {
//             result.error("ERROR", "Device not found.", null);
//         }
//     }

//     private BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
//         @Override
//         public void onServicesDiscovered(BluetoothGatt gatt, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 for (BluetoothGattService service : gatt.getServices()) {
//                     for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                         UUID characteristicUuid = characteristic.getUuid();
//                         if (characteristicUuid != null) {
//                             readCharacteristic(characteristic);
//                         }
//                     }
//                 }
//             } else {
//                 sendErrorToFlutter("Service discovery failed");
//             }
//         }

//         @Override
//         public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 String data = new String(characteristic.getValue());
//                 sendDataToFlutter(data);
//             }
//         }

//         @Override
//         public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
//             super.onCharacteristicChanged(gatt, characteristic);
//         }
//     };

//     private void readCharacteristic(BluetoothGattCharacteristic characteristic) {
//         if (bluetoothGatt != null) {
//             bluetoothGatt.readCharacteristic(characteristic);
//         }
//     }

//     private void sendDataToFlutter(String data) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onWeightDataReceived", data);
//     }

//     private void sendErrorToFlutter(String error) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onError", error);
//     }

//     private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
//         @Override
//         public void onReceive(Context context, Intent intent) {
//             String action = intent.getAction();
//             if (BluetoothDevice.ACTION_FOUND.equals(action)) {
//                 BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
//                 String deviceName = device.getName();
//                 String deviceAddress = device.getAddress();

//                 Map<String, String> deviceInfo = new HashMap<>();
//                 deviceInfo.put("name", deviceName);
//                 deviceInfo.put("address", deviceAddress);

//                 new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                     .invokeMethod("onDeviceFound", deviceInfo);
//             }
//         }
//     };

//     @Override
//     protected void onDestroy() {
//         super.onDestroy();
//         unregisterReceiver(broadcastReceiver);
//         if (bluetoothGatt != null) {
//             bluetoothGatt.close();
//         }
//     }
// }



//*************************updated code, working getting list of devices but not able to connect , test screen*******************************/
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
// import androidx.annotation.NonNull;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;
// import android.bluetooth.BluetoothManager;
// import android.content.pm.PackageManager;
// import android.Manifest;
// import android.os.Build;
// import androidx.core.app.ActivityCompat;
// import androidx.core.content.ContextCompat;

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
//     }

//     private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
//         BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
//         if (device != null) {
//             connectedDevice = device;
//             bluetoothGatt = device.connectGatt(this, false, gattCallback);
//             result.success("Connecting to " + device.getName());
//         } else {
//             result.error("ERROR", "Device not found.", null);
//         }
//     }

//     private BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
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
//                 sendServiceInfoToFlutter(serviceInfo);
//             } else {
//                 sendErrorToFlutter("Service discovery failed");
//             }
//         }

//         @Override
//         public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
//             if (status == BluetoothGatt.GATT_SUCCESS) {
//                 String data = new String(characteristic.getValue());
//                 sendDataToFlutter(data); 
//             }
//         }

//         @Override
//         public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
//             super.onCharacteristicChanged(gatt, characteristic);
//         }
//     };

//     private void sendServiceInfoToFlutter(Map<String, String> serviceInfo) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onServiceInfoDiscovered", serviceInfo);
//     }

//     private void sendDataToFlutter(String data) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onWeightDataReceived", data);
//     }

//     private void sendErrorToFlutter(String error) {
//         new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .invokeMethod("onError", error);
//     }

//     private void getWeightData(MethodChannel.Result result) {
//         if (bluetoothGatt != null && connectedDevice != null) {
//             BluetoothGattCharacteristic weightCharacteristic = null;
//             for (BluetoothGattService service : bluetoothGatt.getServices()) {
//                 for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
//                     if (characteristic.getUuid().equals(UUID.fromString("UUID_OF_WEIGHT_CHARACTERISTIC"))) {
//                         weightCharacteristic = characteristic;
//                         break;
//                     }
//                 }
//             }
//             if (weightCharacteristic != null) {
//                 bluetoothGatt.readCharacteristic(weightCharacteristic);
//                 result.success("Weight data read successfully.");
//             } else {
//                 result.error("ERROR", "Weight characteristic not found.", null);
//             }
//         } else {
//             result.error("ERROR", "Device not connected.", null);
//         }
//     }

//     private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
//         @Override
//         public void onReceive(Context context, Intent intent) {
//             String action = intent.getAction();
//             if (BluetoothDevice.ACTION_FOUND.equals(action)) {
//                 BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
//                 String deviceName = device.getName();
//                 String deviceAddress = device.getAddress();
//                 Map<String, String> deviceInfo = new HashMap<>();
//                 deviceInfo.put("name", deviceName);
//                 deviceInfo.put("address", deviceAddress);

//                 new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                     .invokeMethod("onDeviceFound", deviceInfo);
//             }
//         }
//     };
// }


//**********************************updated one******************************/
package com.example.sdk_connection_2;

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
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.List;
import java.util.UUID;
import java.util.Map;
import java.util.HashMap;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothGatt bluetoothGatt;
    private BluetoothDevice connectedDevice;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startScan")) {
                    startBluetoothScan(result);
                } else if (call.method.equals("connectToDevice")) {
                    String deviceAddress = call.argument("deviceAddress");
                    if (deviceAddress == null || deviceAddress.isEmpty()) {
                        result.error("INVALID_ADDRESS", "Device address cannot be null or empty.", null);
                        return;
                    }
                    connectToDevice(deviceAddress, result);
                } else if (call.method.equals("getWeightData")) {
                    getWeightData(result);
                } else {
                    result.notImplemented();
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
                ActivityCompat.requestPermissions(this, new String[] {
                        Manifest.permission.BLUETOOTH_SCAN,
                        Manifest.permission.BLUETOOTH_CONNECT
                }, 1);
            }
        }
    }

    private void startBluetoothScan(MethodChannel.Result result) {
        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, 1);
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
                connectedDevice = device;
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
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Map<String, String> serviceInfo = new HashMap<>();
                for (BluetoothGattService service : gatt.getServices()) {
                    UUID serviceUuid = service.getUuid();
                    serviceInfo.put("serviceUuid", serviceUuid.toString());
                    for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                        UUID characteristicUuid = characteristic.getUuid();
                        serviceInfo.put("characteristicUuid", characteristicUuid.toString());
                    }
                }
                sendServiceInfoToFlutter(serviceInfo);
            } else {
                sendErrorToFlutter("Service discovery failed");
            }
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                String data = new String(characteristic.getValue());
                sendDataToFlutter(data);
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            String data = new String(characteristic.getValue());
            sendDataToFlutter(data);
        }
    };

    private void sendServiceInfoToFlutter(Map<String, String> serviceInfo) {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
            .invokeMethod("onServiceInfoDiscovered", serviceInfo);
    }

    private void sendDataToFlutter(String data) {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
            .invokeMethod("onWeightDataReceived", data);
    }

    private void sendErrorToFlutter(String error) {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
            .invokeMethod("onError", error);
    }

    private void getWeightData(MethodChannel.Result result) {
        if (bluetoothGatt != null && connectedDevice != null) {
            BluetoothGattCharacteristic weightCharacteristic = null;
            for (BluetoothGattService service : bluetoothGatt.getServices()) {
                for (BluetoothGattCharacteristic characteristic : service.getCharacteristics()) {
                    if (characteristic.getUuid().equals(UUID.fromString("UUID_OF_WEIGHT_CHARACTERISTIC"))) {
                        weightCharacteristic = characteristic;
                        break;
                    }
                }
            }
            if (weightCharacteristic != null) {
                bluetoothGatt.readCharacteristic(weightCharacteristic);
                result.success("Weight data read successfully.");
            } else {
                result.error("ERROR", "Weight characteristic not found.", null);
            }
        } else {
            result.error("ERROR", "Device not connected.", null);
        }
    }

    private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                if (device != null) {
                    String deviceName = device.getName();
                    String deviceAddress = device.getAddress();
                    Map<String, String> deviceInfo = new HashMap<>();
                    deviceInfo.put("name", deviceName);
                    deviceInfo.put("address", deviceAddress);

                    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                        .invokeMethod("onDeviceFound", deviceInfo);
                }
            }
        }
    };
}
