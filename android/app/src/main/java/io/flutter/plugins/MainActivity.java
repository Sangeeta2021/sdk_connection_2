package com.example.sdk_connection_2;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.bluetooth.BluetoothManager;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.sdk_connection_2/device_manager";
    private BluetoothAdapter bluetoothAdapter;
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
                    connectToDevice(deviceAddress, result);
                } else if (call.method.equals("getWeightData")) {
                    getWeightData(result);
                } else {
                    result.notImplemented();
                }
            });

        // Register for Bluetooth device found events
        IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
        registerReceiver(broadcastReceiver, filter);
    }

    private void startBluetoothScan(MethodChannel.Result result) {
        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            result.error("UNAVAILABLE", "Bluetooth is not available or enabled.", null);
            return;
        }
        bluetoothAdapter.startDiscovery();
    }

    private void connectToDevice(String deviceAddress, MethodChannel.Result result) {
        BluetoothDevice device = bluetoothAdapter.getRemoteDevice(deviceAddress);
        if (device != null) {
            connectedDevice = device;
            result.success("Connected to " + device.getName());
        } else {
            result.error("ERROR", "Device not found.", null);
        }
    }

    private void getWeightData(MethodChannel.Result result) {
        if (connectedDevice != null) {
            // Here, you should fetch the real-time weight data from your device.
            // For example, use the ICDeviceManager SDK or send commands to the device to get weight data.
            String weight = "70 kg"; // Placeholder for weight data
            result.success(weight);
        } else {
            result.error("NO_DEVICE", "No device connected", null);
        }
    }

    // BroadcastReceiver for receiving the found devices during scan
    private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                String deviceName = device.getName();
                String deviceAddress = device.getAddress();
                
                // Send found device back to Flutter
                Map<String, String> deviceInfo = new HashMap<>();
                deviceInfo.put("name", deviceName);
                deviceInfo.put("address", deviceAddress);
                
                // Here, you would send the device info to Flutter (via method channel)
                // Example: methodChannel.invokeMethod('onDeviceFound', deviceInfo);
            }
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(broadcastReceiver);
    }
}
