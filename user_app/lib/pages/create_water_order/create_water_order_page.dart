import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/bloc/water_order_bloc_bloc.dart';
import 'package:langas_user/bloc/bloc/water_order_bloc_event.dart';
import 'package:langas_user/bloc/bloc/water_order_bloc_state.dart';
import 'package:langas_user/dto/water_order_dto.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/user_model.dart';
import 'package:langas_user/pages/create_water_order/delivery_card.dart';
import 'package:langas_user/pages/create_water_order/payment_section.dart';
import 'package:langas_user/pages/create_water_order/summary_section.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:langas_user/services/geolocation.dart';
import 'package:langas_user/util/apps_enums.dart';

class DeliveryModel {
  final int id = DateTime.now().millisecondsSinceEpoch;
  final TextEditingController quantityController =
      TextEditingController(text: '1');
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController manualAddressController = TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  String pickedAddressDisplay;
  LatLng? latLng;
  bool isScheduled;
  bool useMyDetails;
  double price = 0.0;

  DeliveryModel({
    this.latLng,
    this.isScheduled = false,
    this.useMyDetails = false,
    this.pickedAddressDisplay = "Tap to pin location on map (Required)",
  });

  void dispose() {
    quantityController.dispose();
    instructionsController.dispose();
    dateController.dispose();
    timeController.dispose();
    manualAddressController.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
  }
}

class CreateWaterOrderPage extends StatefulWidget {
  final User? currentUser;

  const CreateWaterOrderPage({
    super.key,
    this.currentUser,
  });

  @override
  _CreateWaterOrderPageState createState() => _CreateWaterOrderPageState();
}

class _CreateWaterOrderPageState extends State<CreateWaterOrderPage> {
  int _currentStep = 0;
  final List<DeliveryModel> _deliveries = [];
  final _promoCodeController = TextEditingController();
  WaterPaymentType _selectedPaymentMethod = WaterPaymentType.ON_DELIVERY;
  bool _isLoading = false;
  double _totalAmount = 0.0;
  final double _pricePerLitre = 0.5; // Example price per litre

  late GeolocationService _geolocationService;

  @override
  void initState() {
    super.initState();
    _geolocationService = GeolocationService();
    _addDelivery();
  }

  void _addDelivery() async {
    setState(() {
      _deliveries.add(DeliveryModel());
    });
  }

  void _removeDelivery(int index) {
    setState(() {
      if (_deliveries.length > 1) {
        _deliveries[index].dispose();
        _deliveries.removeAt(index);
      } else {
        _showErrorToast("You must have at least one delivery.");
      }
    });
  }

  @override
  void dispose() {
    for (var delivery in _deliveries) {
      delivery.dispose();
    }
    _promoCodeController.dispose();
    super.dispose();
  }

  void _calculatePrices() {
    double total = 0;
    if (_deliveries.isEmpty) {
      _showErrorToast("Please add at least one delivery location.");
      return;
    }

    for (var delivery in _deliveries) {
      final quantity = int.tryParse(delivery.quantityController.text) ?? 0;
      if (quantity <= 0) {
        _showErrorToast("Please enter a valid quantity for all deliveries.");
        return;
      }
      delivery.price = quantity * _pricePerLitre;
      total += delivery.price;
    }
    setState(() {
      _totalAmount = total;
    });
  }

  void _handleSubmitOrder() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      _showErrorToast("You must be logged in to place an order.");
      return;
    }

    final deliveryDtos = _deliveries.map((delivery) {
      ScheduledDetailsRequestDto scheduledDetails;
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd');
      final timeFormat = DateFormat('HH:mm:ss');

      if (delivery.isScheduled) {
        scheduledDetails = ScheduledDetailsRequestDto(
          scheduledDate: delivery.dateController.text,
          scheduledTime: delivery.timeController.text,
        );
      } else {
        // For immediate delivery, use current date and time
        scheduledDetails = ScheduledDetailsRequestDto(
          scheduledDate: dateFormat.format(now),
          scheduledTime: timeFormat.format(now),
        );
      }

      return WaterDeliveryRequestDto(
        priceAmount: delivery.price,
        dropOffLocation: DropOffLocationRequestDto(
          useMyContact: delivery.useMyDetails,
          addressId: null,
          dropOffLatitude: delivery.latLng!.latitude,
          dropOffLongitude: delivery.latLng!.longitude,
          dropOffLocation: delivery.pickedAddressDisplay,
          dropOffAddressTyped: delivery.manualAddressController.text.trim(),
          dropOffContactName: delivery.contactNameController.text.trim(),
          dropOffContactPhone: delivery.contactPhoneController.text.trim(),
        ),
        isScheduled: delivery.isScheduled,
        quantity: int.parse(delivery.quantityController.text),
        deliveryInstructions: delivery.instructionsController.text.trim(),
        scheduledDetails: scheduledDetails,
      );
    }).toList();

    final orderDto = CreateWaterOrderRequestDto(
      clientId: authState.user.userId,
      paymentType: _selectedPaymentMethod,
      promoCode: _promoCodeController.text.trim(),
      deliveries: deliveryDtos,
      paymentStatus: WaterPaymentStatus.PENDING,
      totalAmount: _totalAmount,
    );

    context.read<WaterOrderBloc>().add(CreateWaterOrder(orderDto));
  }

  void onStepContinue() {
    if (_currentStep == 0) {
      bool allValid = true;
      for (var delivery in _deliveries) {
        if (delivery.manualAddressController.text.trim().isEmpty ||
            (int.tryParse(delivery.quantityController.text) ?? 0) <= 0 ||
            delivery.latLng == null ||
            delivery.contactNameController.text.trim().isEmpty ||
            delivery.contactPhoneController.text.trim().isEmpty ||
            (delivery.isScheduled &&
                (delivery.dateController.text.isEmpty ||
                    delivery.timeController.text.isEmpty))) {
          allValid = false;
          break;
        }
      }
      if (!allValid) {
        _showErrorToast(
            "For all deliveries, please fill all required fields: address, map pin, contact details, quantity, and scheduled date/time if applicable.");
        return;
      }
    }
    if (_currentStep == 1) {
      _calculatePrices();
    }
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      _handleSubmitOrder();
    }
  }

  void onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final User? currentUser =
        (authState is Authenticated) ? authState.user : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Create Water Order",
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins'),
        ),
        backgroundColor: theme.primary,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<WaterOrderBloc, WaterOrderState>(
        listener: (context, state) {
          setState(() => _isLoading = state is WaterOrderLoading);

          if (state is WaterOrderCreationSuccess) {
            _showSuccessToast("Order created successfully!");
            context.go('/My_Orders');
          }
          if (state is WaterOrderFailure) {
            _showErrorToast(state.failure.message);
          }
        },
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: theme.primary),
            canvasColor: Colors.white,
            shadowColor: Colors.grey.shade200,
          ),
          child: Stepper(
            elevation: 0,
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: onStepContinue,
            onStepCancel: onStepCancel,
            controlsBuilder: (context, details) {
              final isLastStep = _currentStep == 2;
              return Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLastStep
                            ? _handleSubmitOrder
                            : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isLastStep
                                    ? 'Confirm & Place Order'
                                    : 'Continue',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (_currentStep != 0) const SizedBox(width: 12),
                    if (_currentStep != 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Delivery Locations',
                    style: TextStyle(fontSize: 16)),
                content: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _deliveries.length,
                      itemBuilder: (context, index) {
                        return DeliveryCard(
                          key: ValueKey(_deliveries[index].id),
                          delivery: _deliveries[index],
                          index: index,
                          showRemoveButton: _deliveries.length > 1,
                          onRemove: () => _removeDelivery(index),
                          onLocationUpdate: (latLng, address) {
                            setState(() {
                              _deliveries[index].latLng = latLng;
                              _deliveries[index].pickedAddressDisplay = address;
                            });
                          },
                          currentUser: currentUser,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addDelivery,
                      icon:
                          Icon(Icons.add_circle_outline, color: theme.primary),
                      label: Text('Add Another Delivery',
                          style: TextStyle(color: theme.primary)),
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
                state:
                    _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Payment', style: TextStyle(fontSize: 16)),
                content: PaymentSection(
                  selectedPaymentMethod: _selectedPaymentMethod,
                  promoCodeController: _promoCodeController,
                  onPaymentChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPaymentMethod = val);
                    }
                  },
                ),
                isActive: _currentStep >= 1,
                state:
                    _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title:
                    const Text('Order Summary', style: TextStyle(fontSize: 16)),
                content: SummarySection(
                  deliveries: _deliveries,
                  totalAmount: _totalAmount,
                ),
                isActive: _currentStep >= 2,
                state:
                    _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
  }
}
