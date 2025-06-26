import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/flutter_flow/flutter_flow_theme.dart';

// ====== DAILY EARNINGS TAB ======
class DailyEarningsTab extends StatelessWidget {
  final String selectedPeriod;
  final DateTimeRange? selectedDateRange;
  final List<Map<String, dynamic>> dailyEarnings;

  const DailyEarningsTab({
    Key? key,
    required this.selectedPeriod,
    this.selectedDateRange,
    required this.dailyEarnings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> earnings = [];

    if (selectedPeriod == 'Today') {
      earnings = [dailyEarnings.first];
    } else if (selectedPeriod == 'This Week') {
      earnings = dailyEarnings;
    } else if (selectedPeriod == 'This Month') {
      earnings = dailyEarnings;
    } else if (selectedPeriod == 'Custom' && selectedDateRange != null) {
      // Filter earnings based on date range
      // In a real app, this would filter the actual data
      earnings = dailyEarnings;
    } else {
      earnings = dailyEarnings;
    }
    
    return Container(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: earnings.length,
        itemBuilder: (context, index) {
          final earning = earnings[index];
          final date = DateTime.parse(earning['date']);
          final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
              earning['date'];

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Date circle
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isToday
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Readex Pro',
                            color: isToday ? Colors.white : FlutterFlowTheme.of(context).primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: isToday ? Colors.white70 : FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isToday
                              ? 'Today'
                              : DateFormat('EEEE').format(date),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildEarningsDetailItem(
                              context,
                              Icons.directions_car_filled_outlined,
                              '${earning['trips']} trips',
                            ),
                            const SizedBox(width: 12),
                            _buildEarningsDetailItem(
                              context,
                              Icons.access_time_rounded,
                              '${earning['hours']} hrs',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${earning['amount'].toStringAsFixed(2)}',
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Readex Pro',
                        color: FlutterFlowTheme.of(context).primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(delay: 50.ms + (50.ms * index), duration: 300.ms)
            .moveY(begin: 10, end: 0, curve: Curves.easeOutQuad);
        },
      ),
    );
  }

  Widget _buildEarningsDetailItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: FlutterFlowTheme.of(context).secondaryText,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: FlutterFlowTheme.of(context).bodySmall,
        ),
      ],
    );
  }
}

// ====== BREAKDOWN TAB ======
class EarningsBreakdownTab extends StatelessWidget {
  const EarningsBreakdownTab({Key? key}) : super(key: key);

  // Earnings breakdown
  final List<Map<String, dynamic>> _earningsBreakdown = const [
    {'category': 'Base Fare', 'amount': 550.50, 'percentage': 65.0, 'color': Color(0xFF3F8CFF)},
    {'category': 'Tips', 'amount': 127.00, 'percentage': 15.0, 'color': Color(0xFF4CAF50)},
    {'category': 'Bonuses', 'amount': 101.50, 'percentage': 12.0, 'color': Color(0xFFFFB946)},
    {'category': 'Other', 'amount': 66.25, 'percentage': 8.0, 'color': Color(0xFF9747FF)},
  ];

  // Top earning areas
  final List<Map<String, dynamic>> _topEarningAreas = const [
    {'area': 'Downtown', 'amount': 325.50, 'percentage': 26.1},
    {'area': 'Uptown', 'amount': 287.25, 'percentage': 23.0},
    {'area': 'Midtown', 'amount': 262.75, 'percentage': 21.0},
    {'area': 'Westside', 'amount': 198.50, 'percentage': 15.9},
    {'area': 'Eastside', 'amount': 174.50, 'percentage': 14.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Earnings Breakdown Card
          _buildBreakdownSection(context)
              .animate()
              .fadeIn(duration: 400.ms),
          
          const SizedBox(height: 24),
          
          // Top Earning Areas Card
          _buildTopAreasSection(context)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Earnings Breakdown',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
        ),
        ...List.generate(_earningsBreakdown.length, (index) {
          final item = _earningsBreakdown[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['category'],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${item['amount'].toStringAsFixed(2)}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: item['percentage'] / 100),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 10,
                              backgroundColor: FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
                              color: item['color'] as Color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(value * 100).toInt()}%',
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(delay: 200.ms + (100.ms * index))
            .moveX(begin: 10, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
        }),
      ],
    );
  }

  Widget _buildTopAreasSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Top Earning Areas',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
        ),
        ...List.generate(_topEarningAreas.length, (index) {
          final area = _topEarningAreas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area['area'],
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${area['percentage'].toStringAsFixed(1)}% of your earnings',
                          style: FlutterFlowTheme.of(context).bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${area['amount'].toStringAsFixed(2)}',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
            .fadeIn(delay: 400.ms + (100.ms * index))
            .moveX(begin: 10, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
        }),
      ],
    );
  }
}