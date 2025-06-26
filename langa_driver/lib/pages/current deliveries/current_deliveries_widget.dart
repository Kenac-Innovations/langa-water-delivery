import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/utils/delivery_enums.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentDeliveriesWidget extends StatefulWidget {
  const CurrentDeliveriesWidget({super.key});

  @override
  State<CurrentDeliveriesWidget> createState() =>
      _CurrentDeliveriesWidgetState();
}

class _CurrentDeliveriesWidgetState extends State<CurrentDeliveriesWidget>
    with WidgetsBindingObserver {
  final unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _otpController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Hardcoded sample data for water deliveries
  final List<Delivery> _deliveries = [
    Delivery(
      deliverId: 101,
      priceAmount: 15.50,
      currency: 'USD',
      sensitivity: Sensitivity.BASIC,
      paymentStatus: PaymentStatus.PAID,
      pickupLatitude: -17.8252,
      pickupLongitude: 31.0335,
      pickupLocation: '123 Water Plant Ave, Harare',
      pickupContactName: 'Harare Water',
      pickupContactPhone: '0777123456',
      dropOffLatitude: -17.8352,
      dropOffLongitude: 31.0435,
      dropOffLocation: '456 Aqua St, Borrowdale',
      dropOffContactName: 'John Doe',
      dropOffContactPhone: '0777654321',
      deliveryInstructions: 'Leave at the gate if no one is home.',
      parcelDescription: '20L Water Bottle x 5',
      vehicleType: VehicleType.TRUCK,
      paymentMethod: PaymentMethod.E_MONEY,
      packageWeight: 100,
      deliveryStatus: DeliveryStatus.ASSIGNED,
      isProposed: false,
      commissionRequired: 1.55,
      numberOfSeats: 0,
      deliveryType: 'WATER',
      isScheduled: false,
      customer: const Customer(
          clientId: 1,
          firstname: 'John',
          lastname: 'Doe',
          mobileNumber: '0777654321',
          emailAddress: 'john.doe@example.com'),
    ),
    Delivery(
      deliverId: 102,
      priceAmount: 25.00,
      currency: 'USD',
      sensitivity: Sensitivity.BASIC,
      paymentStatus: PaymentStatus.PAID,
      pickupLatitude: -17.8252,
      pickupLongitude: 31.0335,
      pickupLocation: '123 Water Plant Ave, Harare',
      pickupContactName: 'Harare Water',
      pickupContactPhone: '0777123456',
      dropOffLatitude: -17.8152,
      dropOffLongitude: 31.0235,
      dropOffLocation: '789 Spring Rd, Avondale',
      dropOffContactName: 'Jane Smith',
      dropOffContactPhone: '0712987654',
      deliveryInstructions: 'Call upon arrival.',
      parcelDescription: '500ml Water Bottles x 2 cases',
      vehicleType: VehicleType.VAN,
      paymentMethod: PaymentMethod.CASH,
      packageWeight: 24,
      deliveryStatus: DeliveryStatus.PICKED_UP,
      isProposed: false,
      commissionRequired: 2.50,
      numberOfSeats: 0,
      deliveryType: 'WATER',
      isScheduled: false,
      customer: const Customer(
          clientId: 2,
          firstname: 'Jane',
          lastname: 'Smith',
          mobileNumber: '0712987654',
          emailAddress: 'jane.smith@example.com'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unfocusNode.dispose();
    _otpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _launchMapsUrl(double lat, double lng) async {
    final Uri mapsUri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    } else {
      _showErrorSnackbar('Could not launch any maps app.');
    }
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, FlutterFlowTheme theme) {
    return AppBar(
      backgroundColor: theme.primary,
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30.0,
        borderWidth: 1.0,
        buttonSize: 60.0,
        icon: const Icon(Icons.arrow_back_rounded,
            color: Colors.white, size: 24.0),
        onPressed: () async => context.go('/homePage'),
      ),
      title: Text(
        "Current Water Deliveries",
        style: theme.headlineMedium.override(
            fontFamily: theme.headlineMediumFamily,
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600),
      ),
      actions: [
        FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(Icons.refresh_rounded,
              color: Colors.white, size: 24.0),
          onPressed: () {},
        ),
      ],
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildEmptyState(FlutterFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined,
              color: theme.secondaryText.withOpacity(0.6), size: 80),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text('No Active Deliveries',
                style: theme.titleLarge.override(
                    fontFamily: theme.titleLargeFamily,
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600)),
          ),
          Text('You don\'t have any active deliveries right now.',
              style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.secondaryText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showPickupBottomSheet(Delivery delivery) {
    File? tempParcelImageFromSheet;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            Future<void> takePhoto() async {
              final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera, imageQuality: 70);
              if (photo != null) {
                setModalState(() {
                  tempParcelImageFromSheet = File(photo.path);
                });
              }
            }

            return Container(
              decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0))),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pickup Water Delivery',
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .headlineSmallFamily,
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Order ID: ${delivery.deliverId}',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: Colors.white.withOpacity(0.8))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Take a photo of the items',
                                style:
                                    FlutterFlowTheme.of(context).titleMedium),
                            const SizedBox(height: 8),
                            Text(
                                'Please take a clear photo of the water bottles for verification purposes.',
                                style: FlutterFlowTheme.of(context).bodyMedium),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: takePhoto,
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .alternate
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate)),
                                child: tempParcelImageFromSheet != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                            tempParcelImageFromSheet!,
                                            fit: BoxFit.cover))
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            Icon(Icons.camera_alt,
                                                size: 48,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText),
                                            const SizedBox(height: 8),
                                            Text('Tap to take a photo',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium)
                                          ]),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                    child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.pop(bottomSheetContext),
                                        style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: const Text('Cancel'))),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: tempParcelImageFromSheet != null
                                        ? () {
                                            Navigator.pop(bottomSheetContext);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: const Text('Confirm Pickup',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCompleteDeliveryBottomSheet(Delivery delivery) {
    _otpController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0))),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Complete Delivery',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .headlineSmallFamily,
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Order ID: ${delivery.deliverId}',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleSmallFamily,
                                    color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter the OTP',
                            style: FlutterFlowTheme.of(context).titleMedium),
                        const SizedBox(height: 8),
                        Text(
                            'Ask the recipient for the OTP to complete the delivery.',
                            style: FlutterFlowTheme.of(context).bodyMedium),
                        const SizedBox(height: 16),
                        Form(
                          child: TextFormField(
                            controller: _otpController,
                            decoration: InputDecoration(
                                labelText: 'OTP Code (6 Digits)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.5))),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleMediumFamily,
                                    fontSize: 24,
                                    letterSpacing: 8,
                                    color: Colors.black),
                            cursorColor: Colors.black,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) =>
                                value == null || value.length != 6
                                    ? 'Enter 6-digit OTP'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(bottomSheetContext),
                                    style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: const Text('Cancel'))),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_otpController.text.length == 6) {
                                    Navigator.pop(bottomSheetContext);
                                  } else {
                                    ScaffoldMessenger.of(bottomSheetContext)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter the complete 6-digit OTP'),
                                          backgroundColor: Colors.orange),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: const Text('Complete',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCancelConfirmation(Delivery delivery) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Delivery',
              style: TextStyle(fontFamily: 'Poppins')),
          content: Text(
              'Are you sure you want to cancel delivery #${delivery.deliverId}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('No')),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Yes, Cancel',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: _buildAppBar(context, theme),
        body: SafeArea(
          top: true,
          child: _deliveries.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                  itemCount: _deliveries.length,
                  itemBuilder: (context, index) {
                    return _buildDeliveryCard(_deliveries[index], theme);
                  },
                ),
        ),
      ),
    );
  }

  void _callClient(String phone) async {
    if (phone.isEmpty) return;
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Could not launch call to $phone');
      }
    } catch (e) {
      _showErrorSnackbar('Could not launch call: $e');
    }
  }

  Widget _buildDeliveryCard(Delivery delivery, FlutterFlowTheme theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: theme.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(delivery, theme),
            const SizedBox(height: 12),
            _buildCardInfoRow(delivery, "5.2", theme),
            if (delivery.deliveryInstructions != null &&
                delivery.deliveryInstructions!.isNotEmpty)
              _buildSpecialInstructions(delivery, theme),
            Divider(height: 24, thickness: 1, color: theme.alternate),
            _buildLocationSection(delivery, theme),
            _buildClientInfo(delivery, theme),
            const SizedBox(height: 16),
            _buildParcelInfo(delivery, theme),
            const SizedBox(height: 16),
            _buildActionButtons(delivery, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Delivery delivery, FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Order ID: ${delivery.deliverId}",
            style: theme.titleMedium.override(
                fontFamily: theme.titleMediumFamily,
                fontWeight: FontWeight.w600,
                color: theme.primaryText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: _getStatusColor(delivery.deliveryStatus, theme)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(30)),
          child: Text(
            _getStatusText(delivery.deliveryStatus),
            style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(delivery.deliveryStatus, theme)),
          ),
        ),
      ],
    );
  }

  Widget _buildCardInfoRow(
      Delivery delivery, String distanceToPickupKm, FlutterFlowTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.local_offer_outlined,
                  '\$${delivery.priceAmount.toStringAsFixed(2)}', theme,
                  title: "Price: "),
              const SizedBox(height: 4),
              if (delivery.deliveryStatus == DeliveryStatus.ASSIGNED)
                _infoRow(Icons.social_distance_sharp, '$distanceToPickupKm km',
                    theme,
                    title: "To Pickup: "),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getVehicleIcon(delivery.vehicleType, theme),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                delivery.deliveryType,
                style: theme.bodySmall.copyWith(
                    color: theme.primary, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text, FlutterFlowTheme theme,
      {String title = ""}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.secondaryText),
        const SizedBox(width: 4),
        Text(title,
            style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontWeight: FontWeight.w600)),
        Expanded(
            child: Text(text,
                style: theme.bodyMedium, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildSpecialInstructions(Delivery delivery, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: theme.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.warning.withOpacity(0.3))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 20, color: theme.warning),
            const SizedBox(width: 8),
            Expanded(
                child: Text(delivery.deliveryInstructions!,
                    style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontStyle: FontStyle.italic))),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Delivery delivery, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on,
                      color: Colors.white, size: 16)),
              Container(
                  width: 1.5,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.grey.shade400),
              Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.flag, color: Colors.white, size: 16)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pickup Location",
                    style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600)),
                Text(delivery.pickupLocation,
                    style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.secondaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Text("Drop-Off Location",
                    style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(delivery.dropOffLocation,
                    style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.secondaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(Delivery delivery, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: theme.alternate.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.alternate)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_circle_outlined,
                  size: 18, color: theme.primary),
              const SizedBox(width: 8),
              Text("Delivery Contact",
                  style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: theme.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              '${delivery.customer.firstname} ${delivery.customer.lastname}'
                  .trim(),
              style: theme.bodyLarge.override(
                  fontFamily: theme.bodyLargeFamily,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText)),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16, color: theme.secondaryText),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(delivery.customer.mobileNumber,
                      style: theme.bodyMedium)),
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.call, color: theme.success),
                onPressed: () => _callClient(delivery.customer.mobileNumber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParcelInfo(Delivery delivery, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: theme.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.info.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.opacity, size: 18, color: Colors.black),
              const SizedBox(width: 8),
              Text("Water Delivery Details",
                  style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black)),
            ],
          ),
          const SizedBox(height: 5),
          Text(delivery.parcelDescription, style: theme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Delivery delivery, FlutterFlowTheme theme) {
    bool isAssigned = delivery.deliveryStatus == DeliveryStatus.ASSIGNED;
    bool isPickedUp = delivery.deliveryStatus == DeliveryStatus.PICKED_UP;

    List<Widget> topRowButtons = [];
    Widget? mainAction;

    final chatButton = Expanded(
      child: OutlinedButton.icon(
        icon: Icon(Icons.chat_bubble_outline, size: 18, color: theme.primary),
        label: Text('CHAT',
            style: TextStyle(
                color: theme.primary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        style: OutlinedButton.styleFrom(
            foregroundColor: theme.primary,
            side: BorderSide(color: theme.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () {
          context.push('/chat', extra: {
            'deliveryId': delivery.deliverId.toString(),
            'customerId': delivery.customer.clientId.toString(),
            'customerName':
                '${delivery.customer.firstname} ${delivery.customer.lastname}',
          });
        },
      ),
    );

    if (isAssigned) {
      topRowButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon:
                Icon(Icons.directions_outlined, size: 18, color: theme.primary),
            label: Text('TO PICKUP',
                style: TextStyle(
                    color: theme.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => _launchMapsUrl(
                delivery.pickupLatitude, delivery.pickupLongitude),
          ),
        ),
      );

      topRowButtons.add(const SizedBox(width: 8));
      topRowButtons.add(chatButton);

      mainAction = ElevatedButton.icon(
        icon:
            Icon(Icons.local_shipping_outlined, size: 18, color: Colors.white),
        label: const Text('CONFIRM PICKUP',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () => _showPickupBottomSheet(delivery),
      );
    } else if (isPickedUp) {
      topRowButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon:
                Icon(Icons.directions_outlined, size: 18, color: theme.primary),
            label: Text('TO DROPOFF',
                style: TextStyle(
                    color: theme.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => _launchMapsUrl(
                delivery.dropOffLatitude, delivery.dropOffLongitude),
          ),
        ),
      );
      topRowButtons.add(const SizedBox(width: 8));
      topRowButtons.add(chatButton);

      mainAction = ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline,
            size: 18, color: Colors.white),
        label: const Text('CONFIRM COMPLETION',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () => _showCompleteDeliveryBottomSheet(delivery),
      );
    }

    bool canCancel = delivery.deliveryStatus == DeliveryStatus.ASSIGNED;

    List<Widget> allButtons = [];
    if (topRowButtons.isNotEmpty) {
      allButtons.add(Row(children: topRowButtons));
      allButtons.add(const SizedBox(height: 8));
    }
    if (mainAction != null) {
      allButtons.add(mainAction);
    }

    if (canCancel) {
      allButtons.add(const SizedBox(height: 8));
      allButtons.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.cancel_outlined, size: 18, color: theme.error),
            label: Text('CANCEL DELIVERY',
                style: TextStyle(
                    color: theme.error,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            style: OutlinedButton.styleFrom(
                foregroundColor: theme.error,
                side: BorderSide(color: theme.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => _showCancelConfirmation(delivery),
          ),
        ),
      );
    }

    return Column(children: allButtons.isNotEmpty ? allButtons : [Container()]);
  }

  Widget _getVehicleIcon(VehicleType vehicleType, FlutterFlowTheme theme) {
    IconData iconData;
    Color iconColor;
    switch (vehicleType) {
      case VehicleType.CAR:
        iconData = Icons.directions_car;
        iconColor = Colors.blue.shade700;
        break;
      case VehicleType.BIKE:
        iconData = Icons.pedal_bike;
        iconColor = Colors.green.shade700;
        break;
      case VehicleType.TRUCK:
        iconData = Icons.local_shipping;
        iconColor = Colors.orange.shade800;
        break;
      case VehicleType.VAN:
        iconData = Icons.airport_shuttle;
        iconColor = Colors.purple.shade700;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = theme.secondaryText;
    }
    return Icon(iconData, size: 24, color: iconColor);
  }

  Color _getStatusColor(DeliveryStatus status, FlutterFlowTheme theme) {
    switch (status) {
      case DeliveryStatus.ASSIGNED:
        return theme.primary;
      case DeliveryStatus.PICKED_UP:
        return theme.warning;
      case DeliveryStatus.COMPLETED:
        return theme.success;
      case DeliveryStatus.CANCELLED:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.ASSIGNED:
        return 'Assigned';
      case DeliveryStatus.PICKED_UP:
        return 'Picked Up';
      case DeliveryStatus.COMPLETED:
        return 'Completed';
      case DeliveryStatus.CANCELLED:
        return 'Cancelled';
      case DeliveryStatus.OPEN:
        return 'Open';
      case DeliveryStatus.UNKNOWN:
      default:
        return 'Unknown';
    }
  }
}
