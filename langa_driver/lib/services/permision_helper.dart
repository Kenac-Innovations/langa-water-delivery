// lib/utils/permissions_helper.dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationPermissions() async {
  debugPrint("[PermissionsHelperV4] Requesting location permissions...");

  // --- Stage 1: Check if 'Always' is ALREADY granted ---
  // This is the most important check, especially after returning from settings.
  var statusAlways = await Permission.locationAlways.status;
  debugPrint(
      "[PermissionsHelperV4] Initial 'locationAlways' status: $statusAlways");

  if (statusAlways.isGranted) {
    debugPrint(
        "[PermissionsHelperV4] 'locationAlways' is already granted. Permission check successful.");
    return true;
  }

  // --- Stage 2: 'Always' is NOT granted. Check 'WhenInUse'. ---
  var statusWhenInUse = await Permission.locationWhenInUse.status;
  debugPrint(
      "[PermissionsHelperV4] 'locationWhenInUse' status (since Always was not granted): $statusWhenInUse");

  // If 'WhenInUse' is permanently denied, and 'Always' wasn't granted in Stage 1,
  // the only way is for the user to change it in settings.
  if (statusWhenInUse.isPermanentlyDenied) {
    debugPrint(
        "[PermissionsHelperV4] 'locationWhenInUse' is permanently denied AND 'locationAlways' is not granted. Opening app settings.");
    await openAppSettings();
    return false;
  }

  // --- Stage 3: 'WhenInUse' is not granted (and not permanently denied). Request 'WhenInUse'. ---
  if (!statusWhenInUse.isGranted) {
    debugPrint("[PermissionsHelperV4] Requesting 'locationWhenInUse'...");
    statusWhenInUse = await Permission.locationWhenInUse.request();
    debugPrint(
        "[PermissionsHelperV4] 'locationWhenInUse' status after request: $statusWhenInUse");

    if (!statusWhenInUse.isGranted) {
      // User denied 'WhenInUse' at the prompt, or it became permanently denied now.
      if (statusWhenInUse.isPermanentlyDenied) {
        debugPrint(
            "[PermissionsHelperV4] 'locationWhenInUse' became permanently denied after request. Opening app settings.");
        await openAppSettings();
      } else {
        debugPrint(
            "[PermissionsHelperV4] 'locationWhenInUse' was denied (not permanently). User needs to allow it for 'Always' to be requested.");
      }
      return false; // Exit if 'WhenInUse' is not granted
    }
  }

  // --- Stage 4: 'WhenInUse' IS granted. Now, request 'Always' to upgrade. ---
  // This stage is reached if:
  //   a) 'Always' was not granted initially (Stage 1 failed).
  //   b) 'WhenInUse' was either already granted or just got granted (Stage 2 & 3 passed).
  debugPrint(
      "[PermissionsHelperV4] 'locationWhenInUse' is granted. Now attempting to request/upgrade to 'locationAlways'.");

  // Re-check 'Always' status before requesting, in case it changed via settings while 'WhenInUse' was being processed.
  statusAlways = await Permission.locationAlways.status;
  if (statusAlways.isGranted) {
    debugPrint(
        "[PermissionsHelperV4] 'locationAlways' is now granted (possibly from settings during WhenInUse prompt). Permission check successful.");
    return true;
  }

  // If still not granted, request it. This should trigger the OS prompt to upgrade.
  statusAlways = await Permission.locationAlways.request();
  debugPrint(
      "[PermissionsHelperV4] 'locationAlways' status after upgrade request: $statusAlways");

  if (statusAlways.isGranted) {
    debugPrint(
        "[PermissionsHelperV4] 'locationAlways' granted after upgrade. Permission check successful.");
    return true;
  } else {
    // User might have chosen "Keep Only While Using" or denied the upgrade.
    if (statusAlways.isPermanentlyDenied) {
      debugPrint(
          "[PermissionsHelperV4] 'locationAlways' became permanently denied after upgrade request. Opening app settings.");
      await openAppSettings();
    } else {
      debugPrint(
          "[PermissionsHelperV4] 'locationAlways' was denied during upgrade (user might have chosen 'Keep Only While Using'). Background tracking needs 'Always'.");
      // Consider showing a dialog here explaining why "Always" is crucial for background tracking.
    }
    return false;
  }
}
