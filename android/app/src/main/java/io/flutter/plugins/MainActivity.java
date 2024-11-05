

// // package com.example.sdk_connection_2;

// // import androidx.annotation.NonNull;
// // import io.flutter.embedding.android.FlutterActivity;
// // import io.flutter.embedding.engine.FlutterEngine;
// // import io.flutter.plugin.common.MethodChannel;
// // import cn.icomon.sdk.ICDeviceManager;
// // import cn.icomon.sdk.callbacks.AddDeviceCallback;
// // import android.os.Bundle;
// // import android.util.Log;
// // import android.content.Context;

// // public class MainActivity extends FlutterActivity {
// //     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";

// //     @Override
// //     public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
// //         super.configureFlutterEngine(flutterEngine);
// //         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
// //             .setMethodCallHandler((call, result) -> {
// //                 if (call.method.equals("initializeAndAddDevice")) {
// //                     String deviceId = call.argument("deviceId");
// //                     initializeAndAddDevice(deviceId, result);
// //                 } else {
// //                     result.notImplemented();
// //                 }
// //             });
// //     }

// //     private void initializeAndAddDevice(String deviceId, MethodChannel.Result result) {
// //         ICDeviceManager icDeviceManager = ICDeviceManager.shared();

// //         // Initialize SDK (Replace 'yourConfig' with actual configuration details)
// //         icDeviceManager.initMgrWithConfig(null);
// //         icDeviceManager.setDelegate(null);

// //         // Add device
// //         icDeviceManager.addDevice(deviceId, new AddDeviceCallback() {
// //             @Override
// //             public void onSuccess() {
// //                 result.success("Device added successfully.");
// //             }

// //             @Override
// //             public void onFailure(String error) {
// //                 result.error("ADD_DEVICE_ERROR", "Failed to add device: " + error, null);
// //             }
// //         });
// //     }
// // }

// package com.example.sdk_connection_2;

// import androidx.annotation.NonNull;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.MethodChannel;
// import cn.icomon.sdk.ICDeviceManager;
// import cn.icomon.sdk.ICDeviceManagerConfig;
// import cn.icomon.sdk.callbacks.AddDeviceCallback;
// import android.os.Bundle;
// import android.util.Log;
// import android.content.Context;

// public class MainActivity extends FlutterActivity {
//     private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";

//     @Override
//     public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//         super.configureFlutterEngine(flutterEngine);
//         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//             .setMethodCallHandler((call, result) -> {
//                 if (call.method.equals("initializeAndAddDevice")) {
//                     String deviceId = call.argument("deviceId");
//                     initializeAndAddDevice(deviceId, result);
//                 } else {
//                     result.notImplemented();
//                 }
//             });
//     }

//     private void initializeAndAddDevice(String deviceId, MethodChannel.Result result) {
//         ICDeviceManager icDeviceManager = ICDeviceManager.shared();

//         // Initialize SDK with default configuration
//         ICDeviceManagerConfig defaultConfig = new ICDeviceManagerConfig(); // Replace with appropriate default config method if available
//         icDeviceManager.initMgrWithConfig(defaultConfig);

//         // Set delegate if necessary
//         icDeviceManager.setDelegate(new ICDeviceManagerDelegate() {
//             // Implement required methods here
//         });

//         // Add device
//         icDeviceManager.addDevice(deviceId, new AddDeviceCallback() {
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

package com.example.sdk_connection_2;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import com.icomon.icdemo.ICDeviceManager;
import com.icomon.icdemo.ICDeviceManagerConfig;
import com.icomon.icdemo.callbacks.AddDeviceCallback;
import com.icomon.icdemo.ICDeviceManagerDelegate;
import com.icomon.icdemo.models.Device;
import android.util.Log;
import java.util.HashMap;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
    private BluetoothManager bluetoothManager;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        bluetoothManager = new BluetoothManager(this, channel);

        channel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("initializeAndAddDevice")) {
                String deviceId = call.argument("deviceId");
                initializeAndAddDevice(deviceId, result);
            } else {
                result.notImplemented();
            }
        });
    }

    private void initializeAndAddDevice(String deviceId, MethodChannel.Result result) {
        ICDeviceManager icDeviceManager = ICDeviceManager.shared();
        ICDeviceManagerConfig defaultConfig = new ICDeviceManagerConfig();
        icDeviceManager.initMgrWithConfig(defaultConfig);

        icDeviceManager.setDelegate(new ICDeviceManagerDelegate() {
            @Override
            public void onDeviceFound(Device device) {
                handleDeviceFound(device);
            }
        });

        icDeviceManager.addDevice(deviceId, new AddDeviceCallback() {
            @Override
            public void onSuccess() {
                result.success("Device added successfully.");
            }

            @Override
            public void onFailure(String error) {
                result.error("ADD_DEVICE_ERROR", "Failed to add device: " + error, null);
            }
        });
    }

    private void handleDeviceFound(Device device) {
        if (device != null) {
            String deviceName = device.getName();
            String deviceId = device.getId();
            int signalStrength = device.getSignalStrength();

            new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .invokeMethod("onDeviceFound", new HashMap<String, Object>() {{
                    put("deviceName", deviceName);
                    put("deviceId", deviceId);
                    put("signalStrength", signalStrength);
                }});
        }
    }
}

