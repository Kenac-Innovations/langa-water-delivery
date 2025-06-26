import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:langas_driver/pages/earnings/earnings_tab_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DriverEarningsWidget extends StatefulWidget {
  const DriverEarningsWidget({super.key});

  @override
  State<DriverEarningsWidget> createState() => _DriverEarningsWidgetState();
}

class _DriverEarningsWidgetState extends State<DriverEarningsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  // Selected filter period
  String _selectedPeriod = 'This Week';

  // Selected date range
  DateTimeRange? _selectedDateRange;

  // Selected tab
  int _selectedTabIndex = 0;

  // Dummy data for earnings
  final Map<String, dynamic> _earningsSummary = {
    'total': 1248.50,
    'today': 135.75,
    'week': 845.25,
    'month': 3250.75,
  };

  // Dummy data for daily earnings
  final List<Map<String, dynamic>> _dailyEarnings = [
    {
      'date': '2025-03-17',
      'amount': 135.75,
      'trips': 7,
      'hours': 6.0,
      'tips': 18.50
    },
    {
      'date': '2025-03-16',
      'amount': 165.50,
      'trips': 11,
      'hours': 8.5,
      'tips': 25.00
    },
    {
      'date': '2025-03-15',
      'amount': 187.25,
      'trips': 12,
      'hours': 9.5,
      'tips': 32.75
    },
    {
      'date': '2025-03-14',
      'amount': 156.00,
      'trips': 10,
      'hours': 8.0,
      'tips': 22.00
    },
    {
      'date': '2025-03-13',
      'amount': 98.25,
      'trips': 6,
      'hours': 5.0,
      'tips': 12.25
    },
    {
      'date': '2025-03-12',
      'amount': 142.75,
      'trips': 9,
      'hours': 7.0,
      'tips': 19.50
    },
    {
      'date': '2025-03-11',
      'amount': 125.50,
      'trips': 8,
      'hours': 6.5,
      'tips': 15.75
    },
  ];

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  // Helper methods to get earnings data based on selected period
  double _getPeriodEarnings() {
    switch (_selectedPeriod) {
      case 'Today':
        return _earningsSummary['today'];
      case 'This Week':
        return _earningsSummary['week'];
      case 'This Month':
        return _earningsSummary['month'];
      case 'Custom':
        // For custom date range, we would calculate based on the selected dates
        // In this demo, we'll just return the weekly earnings
        return _earningsSummary['week'];
      default:
        return _earningsSummary['total'];
    }
  }

  int _getPeriodTrips() {
    if (_selectedPeriod == 'Today') {
      return _dailyEarnings.first['trips'];
    }

    // Sum trips for period
    return _dailyEarnings.fold(0, (sum, item) => sum + item['trips'] as int);
  }

  double _getPeriodHours() {
    if (_selectedPeriod == 'Today') {
      return _dailyEarnings.first['hours'];
    }

    // Sum hours for period
    return _dailyEarnings.fold(
        0.0, (sum, item) => sum + item['hours'] as double);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
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

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_unfocusNode)
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
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'MY EARNINGS',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              _buildFilterAndSummary()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .moveY(begin: 20, end: 0),
              Expanded(
                child: _buildTabContent()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterAndSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selection
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white),
                      isExpanded: true,
                      elevation: 2,
                      dropdownColor: FlutterFlowTheme.of(context).primary,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                          ),
                      items: <String>[
                        'Today',
                        'This Week',
                        'This Month',
                        'Custom'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPeriod = newValue;
                            if (newValue != 'Custom') {
                              _selectedDateRange = null;
                            } else if (_selectedDateRange == null) {
                              // Set default date range for custom selection
                              final now = DateTime.now();
                              _selectedDateRange = DateTimeRange(
                                start: now.subtract(const Duration(days: 7)),
                                end: now,
                              );
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              if (_selectedPeriod == 'Custom') const SizedBox(width: 10),
              if (_selectedPeriod == 'Custom')
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.date_range, color: Colors.white),
                    onPressed: () => _selectDateRange(context),
                    tooltip: _selectedDateRange != null
                        ? '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}'
                        : 'Select Dates',
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Earnings amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_getPeriodEarnings().toStringAsFixed(2)}',
                style: FlutterFlowTheme.of(context).displaySmall.override(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _selectedPeriod == 'Custom' && _selectedDateRange != null
                      ? '(${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)})'
                      : '($_selectedPeriod)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _buildStatPill(
                  '${_getPeriodTrips()} trips', Icons.directions_car_outlined),
              const SizedBox(width: 12),
              _buildStatPill(
                  '${_getPeriodHours()} hrs', Icons.access_time_rounded),
            ],
          ),

          const SizedBox(height: 12),

          // Tabs
          Row(
            children: [
              _buildTabButton('Daily', 0),
              const SizedBox(width: 12),
              _buildTabButton('Breakdown', 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return DailyEarningsTab(
          selectedPeriod: _selectedPeriod,
          selectedDateRange: _selectedDateRange,
          dailyEarnings: _dailyEarnings,
        );
      case 1:
        return const EarningsBreakdownTab();
      default:
        return DailyEarningsTab(
          selectedPeriod: _selectedPeriod,
          selectedDateRange: _selectedDateRange,
          dailyEarnings: _dailyEarnings,
        );
    }
  }
}
