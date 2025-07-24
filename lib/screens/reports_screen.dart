import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/calorie_report.dart';
import '../widgets/profile_menu_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'weekly';
  String _selectedReportType = 'calories'; // 'calories' or 'weight'
  CalorieReport? _currentReport;
  bool _isLoading = false;
  double? _liveBMR; // Store live BMR calculation

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final report = await context.read<FirebaseService>().generateCalorieReport(
        user.uid,
        _selectedPeriod,
      );
      
      // Get live BMR calculation (correct value)
      final liveBMR = await context.read<FirebaseService>().calculateBMR(user.uid);
      
      // Additional validation of the report data
      if (report.data.any((data) => 
          data.bmr.isNaN || 
          data.caloriesConsumed.isNaN || 
          data.caloriesBurned.isNaN || 
          data.netCalorieDeficit.isNaN)) {
        throw Exception('Report contains invalid numeric data');
      }
      
      setState(() {
        _currentReport = report;
        _liveBMR = liveBMR;
      });
    } catch (e) {
      print('Report loading error: $e'); // Debug logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load report: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Set to null to show error state
        setState(() {
          _currentReport = null;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              _selectedReportType == 'calories' ? 'Calorie Reports' : 'Weight Reports',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedReportType == 'calories' 
                  ? 'Track your calorie deficit over time'
                  : 'Track your weight changes over time',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Report Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'calories',
                          label: Text('Calories'),
                          icon: Icon(Icons.local_fire_department),
                        ),
                        ButtonSegment(
                          value: 'weight',
                          label: Text('Weight'),
                          icon: Icon(Icons.monitor_weight),
                        ),
                      ],
                      selected: {_selectedReportType},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedReportType = selection.first;
                        });
                        _loadReport();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Period Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Period',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: _selectedReportType == 'weight' 
                          ? const [
                              ButtonSegment(
                                value: 'weekly',
                                label: Text('Weekly'),
                                icon: Icon(Icons.view_week),
                              ),
                              ButtonSegment(
                                value: 'monthly',
                                label: Text('Monthly'),
                                icon: Icon(Icons.calendar_month),
                              ),
                            ]
                          : const [
                              ButtonSegment(
                                value: 'weekly',
                                label: Text('Weekly'),
                                icon: Icon(Icons.view_week),
                              ),
                              ButtonSegment(
                                value: 'monthly',
                                label: Text('Monthly'),
                                icon: Icon(Icons.calendar_month),
                              ),
                              ButtonSegment(
                                value: 'yearly',
                                label: Text('Yearly'),
                                icon: Icon(Icons.calendar_today),
                              ),
                            ],
                      selected: {_selectedPeriod},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedPeriod = selection.first;
                        });
                        _loadReport();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Loading or Report Content
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _currentReport == null
                      ? _buildNoDataWidget()
                      : _buildReportContent(),
            ),
          ],
        ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Data Available',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start logging your food and exercise to see reports',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadReport,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    final report = _currentReport!;
    
    // Check if report has meaningful data
    if (report.data.isEmpty) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timeline_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Daily Entries Found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some daily food and exercise logs to see your calorie deficit trends',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to daily log screen
                    Navigator.of(context).pop(); // Go back to dashboard
                  },
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Add Daily Log'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(report),
            const SizedBox(height: 24),

            // Chart Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedReportType == 'weight' 
                          ? 'Weight Progress'
                          : (_selectedPeriod == 'weekly' 
                              ? 'Weekly Calorie Tracking (Tue-Mon)'
                              : 'Net Calorie Deficit Over Time'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedReportType == 'weight'
                          ? 'Track your weight changes over time. Only shows days with recorded weight.'
                          : (_selectedPeriod == 'weekly'
                              ? 'Weekly view (Tuesday to Monday): Blue bars show calories consumed, green/red bars show net deficit (positive = good for weight loss)'
                              : 'Positive values indicate calorie deficit (good for weight loss). Only shows days with logged food or exercise.'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: _buildChart(report),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Table
            if (report.data.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detailed Data',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Report Period: ${report.period}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'From ${DateFormat('MMM d, yyyy').format(report.startDate)} to ${DateFormat('MMM d, yyyy').format(report.endDate)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Showing ${report.daysWithData} days with logged data out of ${report.totalDays} total days in ${report.period} period.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDataTable(report),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(CalorieReport report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Deficit',
                '${report.totalNetDeficit.round()}',
                'kcal',
                report.totalNetDeficit >= 0 ? Colors.green : Colors.red,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Avg BMR',
                '${_liveBMR?.round() ?? report.averageBMR.round()}',
                'kcal/day',
                Colors.blue,
                Icons.local_fire_department,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Consumed',
                '${report.totalCaloriesConsumed.round()}',
                'kcal',
                Colors.orange,
                Icons.restaurant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Burned',
                '${report.totalCaloriesBurned.round()}',
                'kcal',
                Colors.purple,
                Icons.fitness_center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(CalorieReport report) {
    if (report.data.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    if (_selectedReportType == 'weight') {
      return _buildWeightChart(report);
    }

    // Sort data by date to ensure proper ordering
    final sortedData = List<CalorieReportData>.from(report.data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <BarChartGroupData>[];
    
    if (_selectedPeriod == 'weekly') {
      // For weekly reports, group by day of week
      final weekData = <int, CalorieReportData>{};
      
      for (final data in sortedData) {
        final dayOfWeek = data.date.weekday; // Monday = 1, Sunday = 7
        // Map to Tuesday-based week: Tue=1, Wed=2, Thu=3, Fri=4, Sat=5, Sun=6, Mon=7
        final tuesdayBasedDay = dayOfWeek == 2 ? 1 : // Tuesday -> 1
                               dayOfWeek == 3 ? 2 : // Wednesday -> 2
                               dayOfWeek == 4 ? 3 : // Thursday -> 3
                               dayOfWeek == 5 ? 4 : // Friday -> 4
                               dayOfWeek == 6 ? 5 : // Saturday -> 5
                               dayOfWeek == 7 ? 6 : // Sunday -> 6
                               7; // Monday -> 7
        weekData[tuesdayBasedDay] = data;
      }
      
      // Create bars for each day of the week (1-7, where 1=Tuesday)
      for (int day = 1; day <= 7; day++) {
        final data = weekData[day];
        if (data != null) {
          spots.add(
            BarChartGroupData(
              x: day,
              barRods: [
                // Calories consumed bar (blue)
                BarChartRodData(
                  toY: data.caloriesConsumed,
                  color: Colors.blue,
                  width: 15,
                  borderRadius: BorderRadius.circular(2),
                ),
                // Net deficit bar (green/red)
                BarChartRodData(
                  toY: data.netCalorieDeficit.abs(),
                  color: data.netCalorieDeficit >= 0 ? Colors.green : Colors.red,
                  width: 15,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          );
        } else {
          // Empty bars for days without data
          spots.add(
            BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: 0,
                  color: Colors.transparent,
                  width: 15,
                ),
                BarChartRodData(
                  toY: 0,
                  color: Colors.transparent,
                  width: 15,
                ),
              ],
            ),
          );
        }
      }
    } else {
      // For monthly/yearly reports, use the original design with proper spacing
      for (int i = 0; i < sortedData.length; i++) {
        final data = sortedData[i];
        double xValue;
        
        if (_selectedPeriod == 'monthly') {
          xValue = data.date.day.toDouble();
        } else {
          final dayOfYear = data.date.difference(DateTime(data.date.year)).inDays + 1;
          xValue = dayOfYear.toDouble();
        }
        
        spots.add(
          BarChartGroupData(
            x: xValue.toInt(),
            barRods: [
              BarChartRodData(
                toY: data.netCalorieDeficit.abs(),
                color: data.netCalorieDeficit <= 0 ? Colors.green : Colors.red,
                width: 20,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        );
      }
    }

    // Calculate max Y value
    double maxY = 100;
    double minY = 0;
    
    if (sortedData.isNotEmpty) {
      final allValues = sortedData.expand((data) => [
        data.caloriesConsumed,
        data.netCalorieDeficit.abs(),
      ]).toList();
      
      maxY = allValues.reduce((a, b) => a > b ? a : b) + 200;
      
      if (_selectedPeriod != 'weekly') {
        minY = sortedData.map((d) => d.netCalorieDeficit).reduce((a, b) => a < b ? a : b) - 100;
      }
    }

    return Column(
      children: [
        // Legend for weekly view
        if (_selectedPeriod == 'weekly') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Calories Consumed', Colors.blue),
              const SizedBox(width: 20),
              _buildLegendItem('Net Deficit', Colors.green),
            ],
          ),
          const SizedBox(height: 16),
        ],
        
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: minY,
              barGroups: spots,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.round()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _selectedPeriod == 'weekly' ? 1 : (_selectedPeriod == 'yearly' ? 30 : 5),
                    getTitlesWidget: (value, meta) {
                      if (_selectedPeriod == 'weekly') {
                        // Show day names for weekly view (Tuesday to Monday)
                        const dayNames = ['', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon'];
                        final index = value.toInt();
                        if (index >= 0 && index < dayNames.length) {
                          return Text(
                            dayNames[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                      } else if (_selectedPeriod == 'monthly') {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      } else {
                        final date = DateTime(DateTime.now().year).add(Duration(days: value.toInt() - 1));
                        return Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: _selectedPeriod == 'weekly' ? 500 : 200,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart(CalorieReport report) {
    // Filter data to only include entries with weight
    final weightData = report.data
        .where((data) => data.weight != null && data.weight! > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (weightData.isEmpty) {
      return const Center(child: Text('No weight data to display'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < weightData.length; i++) {
      spots.add(FlSpot(i.toDouble(), weightData[i].weight!));
    }

    // Calculate min and max for better scaling
    final weights = weightData.map((d) => d.weight!).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxWeight = weights.reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: weightData.length > 7 ? 2 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < weightData.length) {
                  final date = weightData[index].date;
                  return Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}lbs',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        minX: 0,
        maxX: (weightData.length - 1).toDouble(),
        minY: minWeight,
        maxY: maxWeight,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.blue,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDataTable(CalorieReport report) {
    if (_selectedReportType == 'weight') {
      return _buildWeightDataTable(report);
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('BMR')),
          DataColumn(label: Text('Consumed')),
          DataColumn(label: Text('Burned')),
          DataColumn(label: Text('Net Deficit')),
        ],
        rows: report.data.take(10).map((data) {
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('MMM dd').format(data.date))),
              DataCell(Text('${_liveBMR?.round() ?? data.bmr.round()}')),
              DataCell(Text('${data.caloriesConsumed.round()}')),
              DataCell(Text('${data.caloriesBurned.round()}')),
              DataCell(
                Text(
                  '${data.netCalorieDeficit.round()}',
                  style: TextStyle(
                    color: data.netCalorieDeficit >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeightDataTable(CalorieReport report) {
    final weightData = report.data
        .where((data) => data.weight != null && data.weight! > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Weight (lbs)')),
          DataColumn(label: Text('Change')),
        ],
        rows: weightData.take(10).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final prevWeight = index > 0 ? weightData[index - 1].weight : null;
          final change = prevWeight != null ? data.weight! - prevWeight : 0.0;
          
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('MMM dd').format(data.date))),
              DataCell(Text('${data.weight!.toStringAsFixed(1)} lbs')),
              DataCell(
                Text(
                  index > 0 ? '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} lbs' : '-',
                  style: TextStyle(
                    color: index > 0 
                        ? (change <= 0 ? Colors.green : Colors.red)
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
} 