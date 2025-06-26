import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/models/firebase_delivery_model.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class FirebaseDeliveryService {
  final FirebaseDatabase _database;
  final String _deliveriesPath = 'openDeliveryCars';

  FirebaseDeliveryService(this._database);

  // Get open deliveries stream filtered by vehicle type
  Stream<List<FirebaseDelivery>> getOpenDeliveries(VehicleType vehicleType) {
    final controller = StreamController<List<FirebaseDelivery>>();
    final deliveries = <FirebaseDelivery>[];

    // Query deliveries by vehicle type
    final query = _database.ref(_deliveriesPath);

    // Listen for changes
    final subscription = query.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        try {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          print("==========> This is the data $data");
          deliveries.clear(); // Clear existing deliveries

          // Process each delivery
          data.forEach((key, value) {
            try {
              if (value is Map) {
                // Convert the dynamic map to a Map<String, dynamic>
                final Map<String, dynamic> deliveryData = {};
                value.forEach((k, v) {
                  if (k is String) {
                    deliveryData[k] = v;
                  } else {
                    deliveryData[k.toString()] = v;
                  }
                });

                // Add the delivery ID to the data
                deliveryData['id'] = key.toString();

                // Convert client data if it exists
                if (deliveryData['client'] is Map) {
                  final clientData = deliveryData['client'] as Map;
                  deliveryData['client'] = {
                    'firstname': clientData['firstname'] ?? '',
                    'lastname': clientData['lastname'] ?? '',
                  };
                }

                // Convert vehicle type if it's a string
                if (deliveryData['vehicleType'] is String) {
                  final typeStr =
                      deliveryData['vehicleType'].toString().toUpperCase();
                  deliveryData['vehicleType'] = typeStr;
                }

                // Convert payment method if it's a string
                if (deliveryData['paymentMethod'] is String) {
                  final methodStr =
                      deliveryData['paymentMethod'].toString().toUpperCase();
                  deliveryData['paymentMethod'] = methodStr;
                }

                // Convert delivery status if it's a string
                if (deliveryData['deliveryStatus'] is String) {
                  final statusStr =
                      deliveryData['deliveryStatus'].toString().toUpperCase();
                  deliveryData['deliveryStatus'] = statusStr;
                }

                // Convert numeric values
                if (deliveryData['priceAmount'] is num) {
                  deliveryData['priceAmount'] =
                      deliveryData['priceAmount'].toDouble();
                }
                if (deliveryData['commissionRequired'] is num) {
                  deliveryData['commissionRequired'] =
                      deliveryData['commissionRequired'].toDouble();
                }
                if (deliveryData['pickupLatitude'] is num) {
                  deliveryData['pickupLatitude'] =
                      deliveryData['pickupLatitude'].toDouble();
                }
                if (deliveryData['pickupLongitude'] is num) {
                  deliveryData['pickupLongitude'] =
                      deliveryData['pickupLongitude'].toDouble();
                }
                if (deliveryData['dropOffLatitude'] is num) {
                  deliveryData['dropOffLatitude'] =
                      deliveryData['dropOffLatitude'].toDouble();
                }
                if (deliveryData['dropOffLongitude'] is num) {
                  deliveryData['dropOffLongitude'] =
                      deliveryData['dropOffLongitude'].toDouble();
                }

                final delivery = FirebaseDelivery.fromJson(deliveryData);
                deliveries.add(delivery);
              }
            } catch (e) {
              print('Error parsing individual delivery: $e');
            }
          });

          // Emit updated list
          if (!controller.isClosed) {
            controller.add(List.from(deliveries));
          }
        } catch (e) {
          print('Error processing deliveries: $e');
          if (!controller.isClosed) {
            controller.addError(e);
          }
        }
      } else {
        // No deliveries found
        print("=========> No current deliveries <===========");
        deliveries.clear();
        if (!controller.isClosed) {
          controller.add([]);
        }
      }
    });

    // Handle errors
    subscription.onError((error) {
      print('Error in delivery stream: $error');
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });

    // Clean up subscription when stream is cancelled
    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  // Update delivery status
  Future<void> updateDeliveryStatus(String deliveryId, bool isProposed) async {
    try {
      await _database
          .ref('$_deliveriesPath/$deliveryId/isProposed')
          .set(isProposed);
    } catch (e) {
      print('Error updating delivery status: $e');
      rethrow;
    }
  }

  // Remove delivery
  Future<void> removeDelivery(String deliveryId) async {
    try {
      await _database.ref('$_deliveriesPath/$deliveryId').remove();
    } catch (e) {
      print('Error removing delivery: $e');
      rethrow;
    }
  }

  // Get driver proposals stream
  Stream<Map<String, dynamic>> getDriverProposals(String driverId) {
    final controller = StreamController<Map<String, dynamic>>();
    final proposals = <String, dynamic>{};

    // Query driver proposals
    final query = _database.ref('driverDeliveriesProposals/$driverId');

    // Listen for changes
    final subscription = query.onValue.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          proposals.clear(); // Clear existing proposals

          // Process each proposal
          data.forEach((key, value) {
            if (value is Map) {
              // Convert the dynamic map to a Map<String, dynamic>
              final Map<String, dynamic> proposalData = {};
              value.forEach((k, v) {
                if (k is String) {
                  proposalData[k] = v;
                } else {
                  proposalData[k.toString()] = v;
                }
              });
              proposals[key.toString()] = proposalData;
            }
          });

          // Emit updated map
          if (!controller.isClosed) {
            controller.add(Map.from(proposals));
          }
        } catch (e) {
          print('Error processing driver proposals: $e');
          if (!controller.isClosed) {
            controller.addError(e);
          }
        }
      } else {
        // No proposals found
        proposals.clear();
        if (!controller.isClosed) {
          controller.add({});
        }
      }
    });

    // Handle errors
    subscription.onError((error) {
      print('Error in driver proposals stream: $error');
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });

    // Clean up subscription when stream is cancelled
    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }
}
