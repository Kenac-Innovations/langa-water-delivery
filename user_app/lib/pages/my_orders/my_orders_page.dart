import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/water_oder/water_order_bloc_bloc.dart';
import 'package:langas_user/bloc/water_oder/water_order_bloc_event.dart';
import 'package:langas_user/bloc/water_oder/water_order_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/flutter_flow/flutter_flow_util.dart';
import 'package:langas_user/models/water_order_model.dart';
import 'package:langas_user/pages/my_orders/order_card.dart';
import 'package:collection/collection.dart';
import 'package:langas_user/util/apps_enums.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  bool _isSearching = false;
  String _searchQuery = '';
  WaterOrderStatus? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<WaterOrderBloc>()
          .add(FetchClientRecentDeliveries(clientId: authState.user.userId));
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _onRefresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<WaterOrderBloc>()
          .add(FetchClientRecentDeliveries(clientId: authState.user.userId));
    }
  }

  Map<DateTime, List<WaterOrder>> _groupOrdersByDate(List<WaterOrder> orders) {
    return groupBy(
        orders,
        (order) => DateTime(
            order.orderDate.year, order.orderDate.month, order.orderDate.day));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: WaterOrderStatus.values
                .where((s) => s != WaterOrderStatus.UNKNOWN)
                .map((status) => ChoiceChip(
                      label: Text(MyOrdersPageStateStringExtension(status.name)
                          .capitalize()),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedStatus = status;
                          } else {
                            _selectedStatus = null; // Allow deselecting
                          }
                        });
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 60.0,
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 24.0),
          onPressed: () => context.goNamed('HomePage'),
        ),
        title: _isSearching
            ? _buildSearchField(theme)
            : const Text("My Orders",
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        actions: _buildAppBarActions(theme),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        top: true,
        child: BlocBuilder<WaterOrderBloc, WaterOrderState>(
          builder: (context, state) {
            if (state is WaterOrderLoading) {
              return _buildLoadingIndicator();
            }
            if (state is WaterOrderListLoadSuccess) {
              if (state.paginatedResponse.content.isEmpty) {
                return _buildEmptyState();
              }
              // Apply search and filter
              final filteredOrders =
                  state.paginatedResponse.content.where((order) {
                final searchLower = _searchQuery.toLowerCase();
                final orderIdMatch =
                    order.orderId.toString().contains(searchLower);
                final addressMatch = order.deliveries.any((d) => d
                    .dropOffLocation.dropOffLocation
                    .toLowerCase()
                    .contains(searchLower));
                final statusMatch = _selectedStatus == null ||
                    order.orderStatus == _selectedStatus;
                return (orderIdMatch || addressMatch) && statusMatch;
              }).toList();

              final sortedOrders = filteredOrders
                ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
              final groupedOrders = _groupOrdersByDate(sortedOrders);
              final sortedDates = groupedOrders.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final ordersForDate = groupedOrders[date]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 12.0, left: 4.0),
                          child: Text(DateFormat('d MMM, yyyy').format(date),
                              style: theme.labelLarge),
                        ),
                        ...ordersForDate
                            .map((order) => OrderCard(order: order))
                            .toList(),
                      ],
                    );
                  },
                ),
              );
            }
            if (state is WaterOrderFailure) {
              return _buildErrorState(state.failure.message);
            }
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(FlutterFlowTheme theme) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      cursorColor: Colors.white,
      style: theme.bodyLarge.override(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Search by Order ID or Address...',
        hintStyle: TextStyle(color: Colors.white),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
    );
  }

  List<Widget> _buildAppBarActions(FlutterFlowTheme theme) {
    return [
      _isSearching
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            )
          : IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => _isSearching = true),
            ),
      IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.white),
        onPressed: _showFilterSheet,
      ),
    ];
  }

  Widget _buildLoadingIndicator() {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(color: theme.primary, size: 50.0),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text('Loading your orders...', style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                color: Colors.grey.shade400, size: 80),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Could not load orders',
                  textAlign: TextAlign.center, style: theme.titleLarge),
            ),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                    fontFamily: 'Poppins', color: theme.secondaryText)),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_rounded,
              color: theme.secondaryText.withOpacity(0.5), size: 90),
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text('No Orders Found', style: theme.headlineSmall),
          ),
          Text('Your placed orders will appear here.',
              style: theme.labelMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

extension MyOrdersPageStateStringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
