


//**********************************************************Updated Code*************************************************/
// package com.example.sdk_connection_2;

// import android.Manifest;
// import android.content.Context;
// import android.content.pm.PackageManager;
// import android.os.Build;
// import androidx.core.app.ActivityCompat;
// import com.icomon.icdemo.ICDeviceManager;
// import com.icomon.icdemo.ICDeviceManagerConfig;
// import com.icomon.icdemo.callbacks.AddDeviceCallback;
// import com.icomon.icdemo.ICDeviceManagerDelegate;
// import com.icomon.icdemo.models.Device;
// import io.flutter.plugin.common.MethodChannel;

// import java.util.HashMap;

// public class BluetoothManager {

//     private Context context;
//     private ICDeviceManager icDeviceManager;
//     private MethodChannel methodChannel;

//     public BluetoothManager(Context context, MethodChannel methodChannel) {
//         this.context = context;
//         this.methodChannel = methodChannel;
//         icDeviceManager = ICDeviceManager.shared();
//     }

//     public void initializeSdk(MethodChannel.Result result) {
//         ICDeviceManagerConfig defaultConfig = new ICDeviceManagerConfig();
//         icDeviceManager.initMgrWithConfig(defaultConfig);

//         // Set the delegate to handle device discovery
//         icDeviceManager.setDelegate(new ICDeviceManagerDelegate() {
//             @Override
//             public void onDeviceFound(Device device) {
//                 handleDeviceFound(device);
//             }
//         });

//         result.success("SDK Initialized");
//     }

//     private void handleDeviceFound(Device device) {
//         if (device != null) {
//             // Extract relevant device information, assuming the Device class has these fields
//             String deviceName = device.getName();
//             String deviceId = device.getId();
//             int signalStrength = device.getSignalStrength();

//             // Send the device info back to Flutter
//             methodChannel.invokeMethod("onDeviceFound", new HashMap<String, Object>() {{
//                 put("deviceName", deviceName);
//                 put("deviceId", deviceId);
//                 put("signalStrength", signalStrength);
//             }});
//         }
//     }

//     public boolean checkBLEConnectionPermission() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             return ActivityCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
//                     && ActivityCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED;
//         } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//             return ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
//                     && ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED;
//         }
//         return true;
//     }

//     public void scanDevices(MethodChannel.Result result) {
//         if (checkBLEConnectionPermission()) {
//             icDeviceManager.scanDevice(new ICDeviceManagerDelegate() {
//                 @Override
//                 public void onDeviceFound(Device device) {
//                     handleDeviceFound(device);
//                 }
//             });
//             result.success("Scanning started");
//         } else {
//             result.error("Permission Denied", "BLE permissions not granted", null);
//         }
//     }

//     public void stopScanning(MethodChannel.Result result) {
//         icDeviceManager.stopScan();
//         result.success("Scanning stopped");
//     }

//     public void addDevice(Object device, MethodChannel.Result result) {
//         icDeviceManager.addDevice(device, new AddDeviceCallback() {
//             @Override
//             public void onSuccess() {
//                 result.success("Device added successfully.");
//             }

//             @Override
//             public void onFailure(String error) {
//                 result.error("ADD_DEVICE_ERROR", "Failed to add device: " + error, null);
//             }
//         });
//     }
// }
//  //not required///