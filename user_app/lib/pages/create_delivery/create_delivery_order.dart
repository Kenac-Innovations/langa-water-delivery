import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/deliveries/create_delivery_bloc/create_delivery_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/create_delivery_bloc/create_delivery_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/create_delivery_bloc/create_delivery_bloc_state.dart';
import 'package:langas_user/bloc/deliveries/delivery_price_bloc/delivery_price_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/delivery_price_bloc/delivery_price_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/delivery_price_bloc/delivery_price_bloc_state.dart';
import 'package:langas_user/dto/delivery_dto.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/flutter_flow/nav/nav.dart';
import 'package:langas_user/models/user_model.dart';
import 'package:langas_user/pages/create_delivery/delivery_confirmation_step_content.dart';
import 'package:langas_user/pages/create_delivery/delivery_summary_step_content.dart';
import 'package:langas_user/pages/create_delivery/drop_off_step_content.dart';
import 'package:langas_user/pages/create_delivery/parcel_details_step_content.dart';
import 'package:langas_user/pages/create_delivery/payment_method_step_content.dart';
import 'package:langas_user/pages/create_delivery/pickup_step_content.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:langas_user/services/geolocation.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/apps_enums.dart';

class MultiStepDelivery extends StatefulWidget {
  final String? initialCurrentLocationString;
  final LatLng? initialCurrentLatLng;

  const MultiStepDelivery({
    super.key,
    this.initialCurrentLocationString,
    this.initialCurrentLatLng,
  });

  @override
  _MultiStepDeliveryState createState() => _MultiStepDeliveryState();
}

class _MultiStepDeliveryState extends State<MultiStepDelivery> {
  String googleApikey = ApiConstants.googleApiKey;

  int _currentStep = 0;

  final GlobalKey<FormState> _formKeyStep0 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep3 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep4 = GlobalKey<FormState>();

  bool isImmediateDelivery = true;
  final TextEditingController pickupContactNameController =
      TextEditingController();
  final TextEditingController pickupPhoneController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();
  final TextEditingController deliveryTimeController = TextEditingController();
  bool useMyContactDetails = false;
  bool useMyCurrentLocationForPickup = false;
  String pickupLocationDisplay = "Search Pickup Location";
  LatLng? pickupLatLng;

  final TextEditingController dropOffContactNameController =
      TextEditingController();
  final TextEditingController dropOffPhoneController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  String dropOffLocationDisplay = "Search Drop Off Location";
  LatLng? dropOffLatLng;

  final TextEditingController parcelDescriptionController =
      TextEditingController();
  Sensitivity selectedSensitivity = Sensitivity.BASIC;
  VehicleType selectedVehicleType = VehicleType.BIKE;

  PaymentMethod selectedPaymentMethod = PaymentMethod.CASH;
  bool autoAssignDriver = false;

  num deliveryCost = 0;
  num taxAmount = 0;
  num totalCost = 0;
  bool _isPriceLoading = false;
  bool _isSubmitting = false;
  bool _isProcessingAction = false;

  late GeolocationService _geolocationService;
  User? _currentUser;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _geolocationService = context.read<GeolocationService>();
    _fetchCurrentUser();
    if (widget.initialCurrentLatLng != null) {
      pickupLatLng = widget.initialCurrentLatLng;
    }
    if (widget.initialCurrentLocationString != null &&
        widget.initialCurrentLocationString!.isNotEmpty) {
      pickupLocationDisplay = widget.initialCurrentLocationString!;
      useMyCurrentLocationForPickup = true;
    } else {
      _fetchInitialLocation();
    }
  }

  void _fetchCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      setState(() {
        _currentUser = authState.user;
      });
    }
  }

  Future<void> _fetchInitialLocation() async {
    Position? position = await _geolocationService.getCurrentLocation();
    if (position != null && mounted) {
      pickupLatLng = LatLng(position.latitude, position.longitude);
      String address = await _geolocationService.getAddressFromCoordinates(
          position.latitude, position.longitude);
      setState(() {
        pickupLocationDisplay =
            address.isNotEmpty ? address : "Current Location";
        useMyCurrentLocationForPickup = true;
      });
    }
  }

  @override
  void dispose() {
    pickupContactNameController.dispose();
    pickupPhoneController.dispose();
    deliveryDateController.dispose();
    deliveryTimeController.dispose();
    dropOffContactNameController.dispose();
    dropOffPhoneController.dispose();
    instructionsController.dispose();
    parcelDescriptionController.dispose();
    super.dispose();
  }

  void _fillPickupUserInfo() {
    if (useMyContactDetails && _currentUser != null) {
      pickupContactNameController.text =
          '${_currentUser!.firstName} ${_currentUser!.lastName}';
      pickupPhoneController.text = _currentUser!.phoneNumber;
    } else {
      pickupContactNameController.clear();
      pickupPhoneController.clear();
    }
  }

  Future<void> _fillPickUpUserLocation() async {
    if (useMyCurrentLocationForPickup) {
      setState(() {
        _isProcessingAction = true;
      });
      Position? position = await _geolocationService.getCurrentLocation();
      if (position != null && mounted) {
        pickupLatLng = LatLng(position.latitude, position.longitude);
        String address = await _geolocationService.getAddressFromCoordinates(
            position.latitude, position.longitude);
        setState(() {
          pickupLocationDisplay =
              address.isNotEmpty ? address : "Current Location";
          _isProcessingAction = false;
        });
        _triggerPriceCalculation();
      } else if (mounted) {
        _showErrorToast("Could not fetch current location.");
        setState(() {
          useMyCurrentLocationForPickup = false;
          pickupLocationDisplay = "Search Pickup Location";
          pickupLatLng = null;
          _isProcessingAction = false;
        });
      }
    } else {
      setState(() {
        pickupLocationDisplay = "Search Pickup Location";
        pickupLatLng = null;
      });
      _triggerPriceCalculation();
    }
  }

  DateTime _getCombinedDateTime() {
    if (isImmediateDelivery) {
      return DateTime.now();
    } else {
      try {
        final date =
            DateFormat('yyyy-MM-dd').parse(deliveryDateController.text);
        final timeString = deliveryTimeController.text;
        final format = DateFormat.jm();
        final time = format.parse(timeString);

        return DateTime(
            date.year, date.month, date.day, time.hour, time.minute);
      } catch (e) {
        print("Error parsing date/time: $e");
        return DateTime.now();
      }
    }
  }

  void _triggerPriceCalculation() {
    if (pickupLatLng != null && dropOffLatLng != null) {
      setState(() {
        _isPriceLoading = true;
        deliveryCost = 0;
        taxAmount = 0;
        totalCost = 0;
      });
      _calculateDistanceAndFetchPrice();
    } else {
      setState(() {
        deliveryCost = 0;
        taxAmount = 0;
        totalCost = 0;
        _isPriceLoading = false;
      });
    }
  }

  Future<void> _calculateDistanceAndFetchPrice() async {
    if (pickupLatLng == null || dropOffLatLng == null) return;

    try {
      double distance = await _geolocationService.calculateDistance(
        pickupLatLng!.latitude,
        pickupLatLng!.longitude,
        dropOffLatLng!.latitude,
        dropOffLatLng!.longitude,
      );

      double distanceInKm = distance / 1000.0;

      final priceDto = PriceGeneratorRequestDto(
        vehicleType: selectedVehicleType,
        sensitivity: selectedSensitivity,
        distance: distanceInKm,
        currency: 'USD',
      );
      context
          .read<DeliveryPriceBloc>()
          .add(GetDeliveryPriceRequested(requestDto: priceDto));
    } catch (e) {
      print("Error calculating distance or preparing price request: $e");
      _showErrorToast("Could not calculate distance.");
      if (mounted) {
        setState(() {
          _isPriceLoading = false;
        });
      }
    }
  }

  void _updateCosts(num basePrice) {
    final calculatedTax = basePrice * 0.15;
    final calculatedTotal = basePrice + calculatedTax;
    setState(() {
      deliveryCost = basePrice;
      taxAmount = calculatedTax;
      totalCost = calculatedTotal;
      _isPriceLoading = false;
    });
  }

  void _handleSubmitOrder() {
    if (_currentStep != 4) return;

    if (pickupLatLng == null || dropOffLatLng == null || totalCost <= 0) {
      _showErrorToast(
          "Please complete all required fields and calculate price.");
      return;
    }
    if (!isImmediateDelivery &&
        (deliveryDateController.text.isEmpty ||
            deliveryTimeController.text.isEmpty)) {
      _showErrorToast(
          "Please select a delivery date and time for scheduled delivery.");
      return;
    }
    if (!useMyContactDetails &&
        (pickupContactNameController.text.isEmpty ||
            pickupPhoneController.text.isEmpty)) {
      _showErrorToast(
          "Please enter pickup contact details or select 'Use my details'.");
      return;
    }
    if (dropOffContactNameController.text.isEmpty ||
        dropOffPhoneController.text.isEmpty) {
      _showErrorToast("Please enter drop-off contact details.");
      return;
    }
    if (parcelDescriptionController.text.isEmpty) {
      _showErrorToast("Please enter a parcel description.");
      return;
    }

    final deliveryDateTime = _getCombinedDateTime();

    final requestDto = CreateDeliveryRequestDto(
      priceAmount: totalCost,
      autoAssign: autoAssignDriver,
      currency: 'USD',
      sensitivity: selectedSensitivity,
      pickupLatitude: pickupLatLng!.latitude,
      pickupLongitude: pickupLatLng!.longitude,
      pickupLocation: pickupLocationDisplay,
      pickupContactName: pickupContactNameController.text,
      pickupContactPhone: pickupPhoneController.text,
      dropOffLatitude: dropOffLatLng!.latitude,
      dropOffLongitude: dropOffLatLng!.longitude,
      dropOffLocation: dropOffLocationDisplay,
      dropOffContactName: dropOffContactNameController.text,
      dropOffContactPhone: dropOffPhoneController.text,
      deliveryInstructions: instructionsController.text,
      parcelDescription: parcelDescriptionController.text,
      vehicleType: selectedVehicleType,
      paymentMethod: selectedPaymentMethod,
      deliveryDate: deliveryDateTime,
    );

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final clientId = authState.user.userId.toString();
      context
          .read<CreateDeliveryBloc>()
          .add(SubmitDelivery(clientId: clientId, requestDto: requestDto));
    } else {
      _showErrorToast("Authentication error. Please log in again.");
      context.goNamed('LoginScreen');
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Pickup"),
        content: PickupStepContent(
          formKey: _formKeyStep0,
          pickupContactNameController: pickupContactNameController,
          pickupPhoneController: pickupPhoneController,
          deliveryDateController: deliveryDateController,
          deliveryTimeController: deliveryTimeController,
          pickUpLocationText: pickupLocationDisplay,
          isPickupSameAsMe: useMyContactDetails,
          isPickupLocationSameAsMe: useMyCurrentLocationForPickup,
          isImmediateDelivery: isImmediateDelivery,
          googleApikey: googleApikey,
          onDeliveryTypeChanged: (value) {
            setState(() {
              isImmediateDelivery = value;
            });
            if (!value) {
              if (deliveryDateController.text.isEmpty) _pickDate();
              if (deliveryTimeController.text.isEmpty) _pickTime();
            }
          },
          onPickupLocationChanged: (display, latLng) {
            setState(() {
              pickupLocationDisplay = display;
              pickupLatLng = latLng;
              useMyCurrentLocationForPickup = false;
            });
            _triggerPriceCalculation();
          },
          onSameAsMeChanged: (value) {
            setState(() {
              useMyContactDetails = value;
            });
            _fillPickupUserInfo();
          },
          onSameAsMeLocationChanged: (value) {
            setState(() {
              useMyCurrentLocationForPickup = value;
            });
            _fillPickUpUserLocation();
          },
          pickDate: _pickDate,
          pickTime: _pickTime,
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Drop Off"),
        content: DropOffStepContent(
          formKey: _formKeyStep1,
          dropOffContactNameController: dropOffContactNameController,
          dropOffPhoneController: dropOffPhoneController,
          instructionsController: instructionsController,
          dropOffLocationText: dropOffLocationDisplay,
          googleApikey: googleApikey,
          onDropOffLocationChanged: (display, latLng) {
            setState(() {
              dropOffLocationDisplay = display;
              dropOffLatLng = latLng;
            });
            _triggerPriceCalculation();
          },
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Parcel"),
        content: ParcelDetailsStepContent(
          formKey: _formKeyStep2,
          parcelDescriptionController: parcelDescriptionController,
          selectedSensitivity: selectedSensitivity,
          selectedVehicleType: selectedVehicleType,
          onSensitivityChanged: (value) {
            if (value != null) {
              setState(() {
                selectedSensitivity = value;
              });
              _triggerPriceCalculation();
            }
          },
          onVehicleChanged: (value) {
            if (value != null) {
              setState(() {
                selectedVehicleType = value;
              });
              _triggerPriceCalculation();
            }
          },
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Payment"),
        content: PaymentMethodStepContent(
          formKey: _formKeyStep3,
          selectedPaymentMethod: selectedPaymentMethod,
          autoAssignDriver: autoAssignDriver,
          onPaymentChanged: (value) {
            if (value != null) {
              setState(() {
                selectedPaymentMethod = value;
              });
            }
          },
          onAssignmentChanged: (value) {
            setState(() {
              autoAssignDriver = value;
            });
          },
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Summary"),
        content: BlocListener<DeliveryPriceBloc, DeliveryPriceState>(
          listener: (context, priceState) {
            if (priceState is DeliveryPriceSuccess) {
              _updateCosts(priceState.price);
            } else if (priceState is DeliveryPriceFailure) {
              _showErrorToast(
                  "Could not calculate price: ${priceState.failure.message}");
              setState(() {
                _isPriceLoading = false;
              });
            } else if (priceState is DeliveryPriceLoading) {
              setState(() {
                _isPriceLoading = true;
              });
            }
          },
          child: DeliverySummaryStepContent(
            formKey: _formKeyStep4,
            deliveryCost: deliveryCost,
            taxAmount: taxAmount,
            totalCost: totalCost,
            selectedPaymentMethod: selectedPaymentMethod,
            isLoading: _isPriceLoading,
          ),
        ),
        isActive: _currentStep >= 4,
        state: _currentStep == 4 ? StepState.editing : StepState.complete,
      ),
    ];
  }

  Widget _buildStepperControls(ControlsDetails details) {
    final isLastStep = _currentStep == _buildSteps().length - 1;

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSubmitting ? null : details.onStepCancel,
                child: const Text('Back'),
              ),
            ),
          ],
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: (_isSubmitting || (_isPriceLoading && isLastStep))
                  ? null
                  : (isLastStep ? _handleSubmitOrder : details.onStepContinue),
              child: _isSubmitting && isLastStep
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(isLastStep ? 'Submit Order' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(now) ? now : selectedDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: FlutterFlowTheme.of(context).primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
        deliveryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: FlutterFlowTheme.of(context).primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: FlutterFlowTheme.of(context).primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        selectedTime = picked;
        deliveryTimeController.text =
            MaterialLocalizations.of(context).formatTimeOfDay(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isImmediateDelivery
              ? "Create Instant Delivery"
              : "Create Scheduled Delivery",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<CreateDeliveryBloc, CreateDeliveryState>(
        listener: (context, state) {
          if (state is CreateDeliveryLoading) {
            setState(() {
              _isSubmitting = true;
            });
          } else if (state is CreateDeliverySuccess) {
            setState(() {
              _isSubmitting = false;
            });
            _showSuccessToast("Delivery created successfully!");
            context.goNamed('Current_Deliveries');
          } else if (state is CreateDeliveryFailure) {
            setState(() {
              _isSubmitting = false;
            });
            _showErrorToast(
                "Failed to create delivery: ${state.failure.message}");
          } else {
            if (_isSubmitting) {
              setState(() {
                _isSubmitting = false;
              });
            }
          }
        },
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: FlutterFlowTheme.of(context).primary,
                  onSurface: Colors.black87,
                ),
            canvasColor: Colors.white,
          ),
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            steps: _buildSteps(),
            onStepContinue: () {
              bool valid = false;
              switch (_currentStep) {
                case 0:
                  valid = _formKeyStep0.currentState!.validate();
                  break;
                case 1:
                  valid = _formKeyStep1.currentState!.validate();
                  break;
                case 2:
                  valid = _formKeyStep2.currentState!.validate();
                  break;
                case 3:
                  valid = _formKeyStep3.currentState!.validate();
                  break;
                case 4:
                  valid = true;
                  break;
              }
              if (valid) {
                if (_currentStep < _buildSteps().length - 1) {
                  setState(() {
                    _currentStep++;
                  });
                  if (_currentStep == 4) {
                    _triggerPriceCalculation();
                  }
                } else {}
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep--;
                });
              }
            },
            controlsBuilder: (context, details) {
              return _buildStepperControls(details);
            },
          ),
        ),
      ),
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
