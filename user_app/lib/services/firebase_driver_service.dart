// import 'package:firebase_database/firebase_database.dart';
// import 'package:langas_user/models/driver_model.dart'; // Assuming Driver model is here
// import 'package:langas_user/models/vehicle_model.dart'; // Import Vehicle model as it's used by Driver
// import 'package:langas_user/util/apps_enums.dart'; // Import VehicleType enum
// import 'package:flutter/foundation.dart'; // Import for debugPrint
// import 'dart:async';
//
// class FirebaseDriverService {
//   final FirebaseDatabase _database = FirebaseDatabase.instance;
//   StreamSubscription<DatabaseEvent>? _proposalsSubscription;
//   final _driversController = StreamController<List<Driver>>.broadcast();
//
//   Stream<List<Driver>> get driversStream => _driversController.stream;
//
//   // Map to hold current drivers by driverID for easier updates/removals
//   final Map<int, Driver> _currentDrivers = {};
//
//   // Add an optional status parameter for filtering
//   void startListeningForProposals(int deliveryId, {String? statusFilter}) {
//     debugPrint('FirebaseDriverService: Starting listener for delivery ID: $deliveryId with status filter: OPEN');
//
//     DatabaseReference proposalsRef = _database.ref('deliveryProposals/$deliveryId');
//
//     // Apply the status filter if provided
//     Query query = statusFilter != null
//         ? proposalsRef.orderByChild('status').equalTo("OPEN")
//         : proposalsRef;
//
//     // Cancel previous subscription if exists to avoid duplicate listeners
//     _proposalsSubscription?.cancel();
//     debugPrint('FirebaseDriverService: Cancelled previous subscription.');
//
//     // Clear existing drivers when starting a new listener to ensure a fresh list
//     _currentDrivers.clear();
//     _driversController.add(List.from(_currentDrivers.values)); // Emit empty list initially
//     debugPrint('FirebaseDriverService: Cleared current drivers and emitted empty list.');
//
//     // Listen for initial data (all existing children matching the query) and subsequent child additions
//     // This listener will fire once for each existing child under the ref, then for any new children added.
//     _proposalsSubscription = query.onChildAdded.listen((event) {
//       debugPrint('FirebaseDriverService: onChildAdded event received.');
//       if (event.snapshot.value != null) {
//         final data = event.snapshot.value as Map<dynamic, dynamic>;
//         debugPrint('FirebaseDriverService: onChildAdded data: ${data.toString()}');
//         try {
//           // Parse the added driver data and add it to the map
//           final driver = Driver.fromFirebase(data);
//            // Re-check status here just in case the query wasn't perfect or for safety
//            if (statusFilter == null || driver.status == statusFilter) {
//               _currentDrivers[driver.driverId] = driver;
//               // Emit the updated list of all current drivers
//               _driversController.add(List.from(_currentDrivers.values));
//               debugPrint('FirebaseDriverService: Added driver ${driver.driverId} (Status: ${driver.status}). Current drivers count: ${_currentDrivers.length}');
//            } else {
//              debugPrint('FirebaseDriverService: Ignoring driver ${driver.driverId} with status ${driver.status} (doesn\'t match filter).');
//            }
//         } catch (e) {
//           debugPrint("FirebaseDriverService: Error parsing driver data from Firebase (child_added): $e");
//         }
//       }
//     }, onError: (error) {
//       debugPrint("FirebaseDriverService: Error listening to Firebase RTDB (child_added): $error");
//       _driversController.addError(error); // Propagate error to the stream
//     });
//
//      // Listen for changes to existing children
//      // This listener fires when the data of an existing child is updated.
//      query.onChildChanged.listen((event) {
//       debugPrint('FirebaseDriverService: onChildChanged event received.');
//       if (event.snapshot.value != null) {
//         final data = event.snapshot.value as Map<dynamic, dynamic>;
//         debugPrint('FirebaseDriverService: onChildChanged data: ${data.toString()}');
//         try {
//            // Parse the updated driver data
//            final updatedDriver = Driver.fromFirebase(data);
//
//            // If the updated driver matches the filter, update or add it.
//            // If it no longer matches, remove it.
//            if (statusFilter == null || updatedDriver.status == statusFilter) {
//              _currentDrivers[updatedDriver.driverId] = updatedDriver;
//              debugPrint('FirebaseDriverService: Changed driver ${updatedDriver.driverId} (Status: ${updatedDriver.status}). Current drivers count: ${_currentDrivers.length}');
//            } else {
//              _currentDrivers.remove(updatedDriver.driverId);
//               debugPrint('FirebaseDriverService: Removed driver ${updatedDriver.driverId} due to status change (${updatedDriver.status}) not matching filter.');
//            }
//            // Emit the updated list of all current drivers
//            _driversController.add(List.from(_currentDrivers.values));
//
//         } catch (e) {
//            debugPrint("FirebaseDriverService: Error parsing updated driver data from Firebase (child_changed): $e");
//         }
//       }
//      }, onError: (error) {
//         debugPrint("FirebaseDriverService: Error listening to Firebase RTDB (child_changed): $error");
//         _driversController.addError(error); // Propagate error
//      });
//
//      // Listen for children removals
//      // This listener fires when a child is removed from the database.
//      query.onChildRemoved.listen((event) {
//        debugPrint('FirebaseDriverService: onChildRemoved event received.');
//        // Note: onChildRemoved event's snapshot.value is the data *before* removal.
//        if (event.snapshot.value != null) {
//         // Assuming the removed snapshot still contains the driverId
//          final data = event.snapshot.value as Map<dynamic, dynamic>;
//          final driverId = data['driverID']; // Adjust field name if necessary
//          debugPrint('FirebaseDriverService: onChildRemoved data (might contain driverID): ${data.toString()}');
//          if (driverId != null) {
//             // Remove the driver from the map
//             _currentDrivers.remove(driverId);
//              // Emit the updated list of all current drivers
//             _driversController.add(List.from(_currentDrivers.values));
//             debugPrint('FirebaseDriverService: Removed driver $driverId. Current drivers count: ${_currentDrivers.length}');
//          }
//        } else {
//          debugPrint('FirebaseDriverService: onChildRemoved event with null data.');
//        }
//      }, onError: (error) {
//         debugPrint("FirebaseDriverService: Error listening to Firebase RTDB (child_removed): $error");
//         _driversController.addError(error); // Propagate error
//      });
//   }
//
//   void dispose() {
//     debugPrint('FirebaseDriverService: Disposing and cancelling subscription.');
//     _proposalsSubscription?.cancel();
//     _driversController.close();
//   }
// }
import 'package:firebase_database/firebase_database.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/models/vehicle_model.dart';
import 'package:langas_user/util/apps_enums.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class FirebaseDriverService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<DatabaseEvent>? _proposalsSubscription;
  final _driversController = StreamController<List<Driver>>.broadcast();

  Stream<List<Driver>> get driversStream => _driversController.stream;
  static const String RTDB_LIVE_TRACKING_PATH = 'detailed_live_tracking';

  // Map to hold current drivers by driverID for easier updates/removals
  final Map<int, Driver> _currentDrivers = {};

  void startListeningForProposals(int deliveryId,
      {String? statusFilter = "OPEN"}) {
    debugPrint(
        '========> FirebaseDriverService: Starting listener for delivery ID: $deliveryId with status filter: $statusFilter');
    DatabaseReference proposalsRef =
        _database.ref('deliveryProposals/$deliveryId');

    // Cancel previous subscription if exists to avoid duplicate listeners
    _proposalsSubscription?.cancel();
    debugPrint('FirebaseDriverService: Cancelled previous subscription.');

    // Clear existing drivers when starting a new listener to ensure a fresh list
    _currentDrivers.clear();
    _driversController
        .add(List.from(_currentDrivers.values)); // Emit empty list initially
    debugPrint(
        '=======> FirebaseDriverService: Cleared current drivers and emitted empty list.');

    // First, let's test the connection and log the structure
    // _testDatabaseStructure(deliveryId);

    // Listen for child added events on the proposals reference
    _proposalsSubscription = proposalsRef.onChildAdded.listen((event) {
      debugPrint(
          'FirebaseDriverService: onChildAdded event received for key: ${event.snapshot.key}');

      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        debugPrint(
            '===========> FirebaseDriverService: onChildAdded full data: ${data.toString()}');

        try {
          // Check if status matches filter (if filter is provided)
          final status = data['status']?.toString();
          debugPrint(
              'FirebaseDriverService: Proposal status: $status, Filter: $statusFilter');

          if (statusFilter == null || status == statusFilter) {
            // Parse the driver data
            final driver = Driver.fromFirebase(data);
            _currentDrivers[driver.driverId] = driver;

            // Emit the updated list
            _driversController.add(List.from(_currentDrivers.values));
            debugPrint(
                'FirebaseDriverService: Added driver ${driver.driverId} (Status: $status). Current drivers count: ${_currentDrivers.length}');
          } else {
            debugPrint(
                'FirebaseDriverService: Ignoring driver with status $status (doesn\'t match filter $statusFilter).');
          }
        } catch (e, stackTrace) {
          debugPrint(
              "FirebaseDriverService: Error parsing driver data from Firebase (child_added): $e");
          debugPrint("FirebaseDriverService: StackTrace: $stackTrace");
          debugPrint("FirebaseDriverService: Problematic data: $data");
        }
      } else {
        debugPrint('FirebaseDriverService: onChildAdded event with null data');
      }
    }, onError: (error) {
      debugPrint(
          "FirebaseDriverService: Error listening to Firebase RTDB (child_added): $error");
      _driversController.addError(error);
    });

    // Listen for changes to existing children
    proposalsRef.onChildChanged.listen((event) {
      debugPrint(
          'FirebaseDriverService: onChildChanged event received for key: ${event.snapshot.key}');

      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        debugPrint(
            'FirebaseDriverService: onChildChanged data: ${data.toString()}');

        try {
          final status = data['status']?.toString();
          debugPrint(
              'FirebaseDriverService: Changed proposal status: $status, Filter: $statusFilter');

          final updatedDriver = Driver.fromFirebase(data);

          if (statusFilter == null || status == statusFilter) {
            _currentDrivers[updatedDriver.driverId] = updatedDriver;
            debugPrint(
                'FirebaseDriverService: Updated driver ${updatedDriver.driverId} (Status: $status)');
          } else {
            // Remove if it no longer matches the filter
            _currentDrivers.remove(updatedDriver.driverId);
            debugPrint(
                'FirebaseDriverService: Removed driver ${updatedDriver.driverId} due to status change ($status)');
          }

          _driversController.add(List.from(_currentDrivers.values));
          debugPrint(
              'FirebaseDriverService: Current drivers count: ${_currentDrivers.length}');
        } catch (e, stackTrace) {
          debugPrint(
              "FirebaseDriverService: Error parsing updated driver data: $e");
          debugPrint("FirebaseDriverService: StackTrace: $stackTrace");
        }
      }
    }, onError: (error) {
      debugPrint(
          "FirebaseDriverService: Error listening to Firebase RTDB (child_changed): $error");
      _driversController.addError(error);
    });

    // Listen for children removals
    proposalsRef.onChildRemoved.listen((event) {
      debugPrint(
          'FirebaseDriverService: onChildRemoved event received for key: ${event.snapshot.key}');

      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        debugPrint(
            'FirebaseDriverService: onChildRemoved data: ${data.toString()}');

        // Try different possible field names for driverID
        final driverId =
            data['driverID'] ?? data['driverId'] ?? data['driver_id'];

        if (driverId != null) {
          _currentDrivers.remove(driverId);
          _driversController.add(List.from(_currentDrivers.values));
          debugPrint(
              'FirebaseDriverService: Removed driver $driverId. Current drivers count: ${_currentDrivers.length}');
        } else {
          debugPrint(
              'FirebaseDriverService: Could not find driverID in removed data');
        }
      } else {
        debugPrint(
            'FirebaseDriverService: onChildRemoved event with null data');
      }
    }, onError: (error) {
      debugPrint(
          "FirebaseDriverService: Error listening to Firebase RTDB (child_removed): $error");
      _driversController.addError(error);
    });
  }

  // Test method to check database structure
  Future<void> _testDatabaseStructure(int deliveryId) async {
    try {
      debugPrint(
          'FirebaseDriverService: Testing database structure for deliveryId: $deliveryId');
      // final DatabaseReference testRef =
      // FirebaseDatabase.instance.ref('$RTDB_LIVE_TRACKING_PATH/13');
      //
      // testRef.once().then((DatabaseEvent event) {
      //   if (event.snapshot.exists) {
      //     print("✅ Successfully connected to Firebase and data exists:");
      //     print("📦 Data: ${event.snapshot.value}");
      //   } else {
      //     print("⚠️ Connected to Firebase, but no data exists for driverId: 14");
      //   }
      // }).catchError((error) {
      //   print("❌ Failed to connect to Firebase RTDB: $error");
      // });
      final snapshot =
          await _database.ref('deliveryProposals/$deliveryId').get();
      // debugPrint("===========> Testing connection ");
      if (snapshot.exists) {
        debugPrint('FirebaseDriverService: Database connection successful!');
        debugPrint(
            'FirebaseDriverService: Raw data type: ${snapshot.value.runtimeType}');
        debugPrint('FirebaseDriverService: Raw data: ${snapshot.value}');

        if (snapshot.value is Map) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          debugPrint(
              'FirebaseDriverService: Found ${data.keys.length} child nodes: ${data.keys.toList()}');

          // Log details of each child
          data.forEach((key, value) {
            debugPrint('FirebaseDriverService: Child key: $key');
            if (value is Map) {
              final childData = value as Map<dynamic, dynamic>;
              debugPrint('  - Status: ${childData['status']}');
              debugPrint('  - DriverID: ${childData['driverID']}');
              debugPrint('  - ProposalID: ${childData['proposalID']}');
              debugPrint('  - All keys: ${childData.keys.toList()}');
            }
          });
        }
      } else {
        debugPrint(
            'FirebaseDriverService: No data found at deliveryProposals/$deliveryId');
      }
    } catch (e) {
      debugPrint('FirebaseDriverService: Error testing database structure: $e');
    }
  }

  // Method to get all proposals regardless of status (for testing)
  void startListeningForAllProposals(int deliveryId) {
    startListeningForProposals(deliveryId, statusFilter: null);
  }

  // Method to get open proposals specifically
  void startListeningForOpenProposals(int deliveryId) {
    startListeningForProposals(deliveryId, statusFilter: "OPEN");
  }

  // Method to get accepted proposals specifically
  void startListeningForAcceptedProposals(int deliveryId) {
    startListeningForProposals(deliveryId, statusFilter: "ACCEPTED");
  }

  // One-time fetch method for testing
  Future<List<Driver>> fetchAllProposals(int deliveryId,
      {String? statusFilter}) async {
    try {
      debugPrint(
          'FirebaseDriverService: Fetching all proposals for deliveryId: $deliveryId with filter: $statusFilter');

      final snapshot =
          await _database.ref('deliveryProposals/$deliveryId').get();

      if (!snapshot.exists) {
        debugPrint('FirebaseDriverService: No data found');
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Driver> drivers = [];

      for (final entry in data.entries) {
        try {
          final proposalData = entry.value as Map<dynamic, dynamic>;
          final status = proposalData['status']?.toString();

          debugPrint(
              'FirebaseDriverService: Processing proposal ${entry.key}: status = $status');

          if (statusFilter == null || status == statusFilter) {
            final driver = Driver.fromFirebase(proposalData);
            drivers.add(driver);
            debugPrint(
                'FirebaseDriverService: Added driver ID: ${driver.driverId}');
          }
        } catch (e) {
          debugPrint(
              'FirebaseDriverService: Error parsing proposal ${entry.key}: $e');
        }
      }

      debugPrint('FirebaseDriverService: Fetched ${drivers.length} drivers');
      return drivers;
    } catch (e) {
      debugPrint('FirebaseDriverService: Error in fetchAllProposals: $e');
      throw e;
    }
  }

  void dispose() {
    debugPrint('FirebaseDriverService: Disposing and cancelling subscription.');
    _proposalsSubscription?.cancel();
    _driversController.close();
  }
}
