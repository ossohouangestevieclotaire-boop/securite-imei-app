package com.example.securite_imei_app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "securite.imei/device_admin"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val compName = ComponentName(this, DeviceAdminReceiver::class.java)

            if (call.method == "activerAdmin") {
                val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                    putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, compName)
                    putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "Activez cette option pour sécuriser et protéger l'appareil contre le vol.")
                }
                startActivityForResult(intent, 1)
                result.success(true)
            } else if (call.method == "verrouillerAppareil") {
                val isAdmin = devicePolicyManager.isAdminActive(compName)
                if (isAdmin) {
                    devicePolicyManager.lockNow()
                    result.success(true)
                } else {
                    result.error("ADMIN_NOT_ACTIVE", "Les droits d'administrateur ne sont pas activés.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
