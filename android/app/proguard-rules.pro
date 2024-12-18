# Keep the class and its members for ICDeviceManager SDK
-keep class cn.icomon.icdevicemanager.ICDeviceManager { *; }
-keep class cn.icomon.icdevicemanager.ICBluetoothSystem { *; }
-keep public class cn.icomon.icdevicemanager.ICBluetoothSystem$ICBluetoothDelegate { *; }
-keep public class cn.icomon.icdevicemanager.ICBluetoothSystem$ICOPBleCharacteristic { *; }
-keep enum cn.icomon.icdevicemanager.ICBluetoothSystem$ICOPBleWriteDataType { *; }
-keep class cn.icomon.icdevicemanager.manager.setting.ICSettingManagerImpl { *; }
-keep class cn.icomon.icdevicemanager.manager.algorithms.ICBodyFatAlgorithmsImpl { *; }
-keep class cn.icomon.icdevicemanager.ICDeviceManagerDelegate { *; }
-keep class cn.icomon.icdevicemanager.model.** { *; }
-keep class cn.icomon.icdevicemanager.ICDeviceManagerSettingManager { *; }
-keep public class cn.icomon.icdevicemanager.ICDeviceManagerSettingManager$ICSettingCallback { *; }
-keep class com.icomon.icbodyfatalgorithms.** { *; }
-keep class cn.icomon.icbleprotocol.** { *; }
-keep class cn.icomon.icdevicemanager.ICBodyFatAlgorithmsManager { *; }
-keep class cn.icomon.icdevicemanager.ICBluetoothSystem$** { *; }
-keep class cn.icomon.icdevicemanager.callback.** { *; }
#newly added 
-keep class com.example.sdk_connection_2.** { *; }
-keep class no.nordicsemi.android.** { *; }
-keep class com.pauldemarco.flutterblue.** { *; }

