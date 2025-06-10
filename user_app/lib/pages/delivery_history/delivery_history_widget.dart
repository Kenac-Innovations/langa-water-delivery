import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_state.dart';
import 'package:langas_user/models/delivery_model.dart';
import 'package:langas_user/util/apps_enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeliveryHistoryWidget extends StatefulWidget {
  const DeliveryHistoryWidget({super.key});

  @override
  State<DeliveryHistoryWidget> createState() => _DeliveryHistoryWidgetState();
}

class _DeliveryHistoryWidgetState extends State<DeliveryHistoryWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final unfocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String? _clientId;
  List<Delivery> _deliveries = [];
  int _currentPage = 0;
  int _totalPages = 1; // Assume at least one page initially
  bool _isLastPage = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _clientId = authState.user.userId.toString();
      _fetchHistory(page: 1, isRefresh: true);
    } else {
      print("Error: User not authenticated in DeliveryHistoryWidget");
    }
  }

  void _fetchHistory({required int page, bool isRefresh = false}) {
    if (_clientId != null) {
      context.read<DeliveriesBloc>().add(
            FetchDeliveriesRequested(
              clientId: _clientId!,
              isHistory: true,
              pageNumber: page,
              pageSize: 15, // Adjust page size as needed
            ),
          );
      if (isRefresh) {
        // Reset state on refresh
        setState(() {
          _deliveries = [];
          _currentPage = 1;
          _isLastPage = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLastPage) {
      setState(() {
        _isLoadingMore = true;
      });
      _fetchHistory(page: _currentPage + 1);
    }
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.COMPLETED:
        return FlutterFlowTheme.of(context).success;
      case DeliveryStatus.CANCELLED:
        return FlutterFlowTheme.of(context).error;
      default:
        return FlutterFlowTheme.of(context).secondaryText;
    }
  }

  void _showToast(String message, {required bool success}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: success ? Colors.green : Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showRatingDialog(Delivery delivery) {
    // Implement rating dialog if needed for history items
    _showToast("Rating functionality not implemented for history.",
        success: false);
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () => unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            "DELIVERY HISTORY",
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          actions: [
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.refresh_rounded,
                color: FlutterFlowTheme.of(context).info,
                size: 24.0,
              ),
              onPressed: () => _fetchHistory(page: 0, isRefresh: true),
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: BlocConsumer<DeliveriesBloc, DeliveriesState>(
              listener: (context, state) {
            if (state is DeliveriesSuccess) {
              setState(() {
                // Append new items, avoid duplicates
                final newDeliveries = state.response.content
                    .where((newDelivery) => !_deliveries.any((existing) =>
                        existing.deliveryId == newDelivery.deliveryId))
                    .toList();
                _deliveries.addAll(newDeliveries);
                _currentPage = state.response.pagination.pageNumber;
                _totalPages = state.response.pagination.totalPages;
                _isLastPage = (_currentPage + 1) >= _totalPages;
                _isLoadingMore = false;
              });
            } else if (state is DeliveriesFailure) {
              _showToast("Error loading history: ${state.failure.message}",
                  success: false);
              setState(() {
                _isLoadingMore = false;
              });
            } else if (state is DeliveriesLoading && _deliveries.isEmpty) {
              // Handled by builder
            } else if (state is DeliveriesLoading && _deliveries.isNotEmpty) {
              setState(() {
                _isLoadingMore = true;
              }); // Show loading indicator at bottom
            }
          }, builder: (context, state) {
            if (state is DeliveriesLoading && _deliveries.isEmpty) {
              return _buildLoadingIndicator();
            } else if (state is DeliveriesFailure && _deliveries.isEmpty) {
              return _buildErrorState(state.failure.message);
            } else if (_deliveries.isEmpty && state is! DeliveriesLoading) {
              return _buildEmptyState();
            } else {
              return _buildDeliveriesList();
            }
          }),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SpinKitSpinningLines(
        color: FlutterFlowTheme.of(context).primary,
        size: 50.0,
        lineWidth: 2,
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: Colors.grey.shade400, size: 60),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Could not load history: $message',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: () => _fetchHistory(page: 0, isRefresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeliveriesList() {
    return RefreshIndicator(
      onRefresh: () async => _fetchHistory(page: 0, isRefresh: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: _deliveries.length +
                (_isLoadingMore ? 1 : 0), // Add space for loader
            itemBuilder: (context, index) {
              if (index == _deliveries.length) {
                return _buildPaginationLoadingIndicator();
              }
              return _buildDeliveryCard(_deliveries[index]);
            }),
      ),
    );
  }

  Widget _buildPaginationLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_outlined,
            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.6),
            size: 80,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'No Delivery History',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            'Your completed or cancelled deliveries will appear here.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    String statusText = delivery.deliveryStatus.name.replaceAll('_', ' ');
    statusText =
        statusText[0].toUpperCase() + statusText.substring(1).toLowerCase();
    String formattedDate = "Date N/A"; // Default
    // Assuming deliveryDate is available and needs formatting
    // if (delivery.deliveryDate != null) {
    //    formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(delivery.deliveryDate!);
    // }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ID: TK${delivery.deliveryId}",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          fontWeight: FontWeight.w500,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(delivery.deliveryStatus)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      statusText,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(delivery.deliveryStatus),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16,
                            color: FlutterFlowTheme.of(context).secondaryText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formattedDate, // Use formatted date
                            style: FlutterFlowTheme.of(context).bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context)
                          .alternate
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "\$${delivery.priceAmount.toStringAsFixed(2)}",
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleMediumFamily,
                            color: FlutterFlowTheme.of(context).primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: FlutterFlowTheme.of(context).alternate,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.location_on,
                              color: Colors.white, size: 16),
                        ),
                        Container(
                          width: 2,
                          height: 60,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                      style: BorderStyle.solid))),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.location_on,
                              color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pickup Location",
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleMediumFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black),
                          ),
                          Text(
                            delivery.pickupLocation,
                            style: FlutterFlowTheme.of(context).bodyMedium,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Drop-Off Location",
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleMediumFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            delivery.dropOffLocation,
                            style: FlutterFlowTheme.of(context).bodyMedium,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Rating Section (Optional for History)
              // if (delivery.deliveryStatus == DeliveryStatus.COMPLETED) ...[
              //    const SizedBox(height: 16),
              //    _buildRatingSection(delivery),
              // ]
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildRatingSection(Delivery delivery) {
  //    // Placeholder - Adapt rating logic if needed for history
  //    bool isRated = false; // Check if user has rated this specific delivery
  //    double currentRating = 0.0; // Get stored rating if available

  //    return isRated
  //      ? Container(...) // Display existing rating
  //      : ElevatedButton.icon(...); // Show rate button
  // }
}
