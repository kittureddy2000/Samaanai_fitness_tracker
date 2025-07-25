import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/calorie_report.dart';
import 'daily_log_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with WidgetsBindingObserver {
  String _selectedPeriod = 'weekly';
  String _selectedReportType = 'calories'; // 'calories', 'weight', or 'glasses'
  CalorieReport? _currentReport;
  bool _isLoading = false;
  double? _liveBMR; // Store live BMR calculation
  
  // Navigation state for weekly reports
  DateTime _currentWeekStart = DateTime.now();
  
  // Date selection for monthly/yearly reports
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedYear = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDates();
    _loadReport();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app becomes active again
      _loadReport();
    }
  }
  
  // Public method to refresh reports (can be called from parent widgets)
  void refreshReports() {
    _loadReport();
  }
  
  void _initializeDates() {
    final now = DateTime.now();
    
    // Set current week start to last Wednesday
    _currentWeekStart = _getWeekStart(now);
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedYear = DateTime(now.year, 1, 1);
  }
  
  DateTime _getWeekStart(DateTime date) {
    // Find the Wednesday that starts the current week
    final dayOfWeek = date.weekday; // Monday = 1, Sunday = 7
    final daysFromWednesday = (dayOfWeek + 4) % 7; // Wednesday = 0
    return date.subtract(Duration(days: daysFromWednesday));
  }
  
  
  CalorieReport _filterMonthlyDataForWeek(CalorieReport monthlyReport, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    print('🔍 Filtering monthly data for week: ${weekStart.toString().split(' ')[0]} to ${weekEnd.toString().split(' ')[0]}');
    print('📅 Monthly report has ${monthlyReport.data.length} total entries');
    
    // Filter monthly data for the specific week
    final weekData = monthlyReport.data.where((data) {
      final entryDate = DateTime(data.date.year, data.date.month, data.date.day);
      final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekEndDate = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
      
      final isInWeek = (entryDate.isAtSameMomentAs(weekStartDate) ||
                       entryDate.isAtSameMomentAs(weekEndDate) ||
                       (entryDate.isAfter(weekStartDate) && entryDate.isBefore(weekEndDate.add(const Duration(days: 1)))));
      
      if (isInWeek) {
        print('  ✅ ${entryDate.toString().split(' ')[0]}: ${data.caloriesConsumed} calories consumed');
      }
      
      return isInWeek;
    }).toList();
    
    print('📊 Found ${weekData.length} entries for this week');
    
    // Recalculate totals for the week
    double totalCaloriesConsumed = 0;
    double totalCaloriesBurned = 0;
    double totalNetDeficit = 0;
    double totalBMR = 0;
    double totalGlasses = 0;
    
    for (final entry in weekData) {
      totalCaloriesConsumed += entry.caloriesConsumed;
      totalCaloriesBurned += entry.caloriesBurned;
      totalNetDeficit += entry.netCalorieDeficit;
      totalBMR += entry.bmr;
      totalGlasses += entry.glasses ?? 0;
    }
    
    final averageBMR = weekData.isNotEmpty ? totalBMR / weekData.length : monthlyReport.averageBMR;
    final averageGlasses = weekData.isNotEmpty ? totalGlasses / weekData.length : 0.0;
    
    return CalorieReport(
      period: 'weekly',
      startDate: weekStart,
      endDate: weekEnd,
      data: weekData,
      totalCaloriesConsumed: totalCaloriesConsumed,
      totalCaloriesBurned: totalCaloriesBurned,
      totalNetDeficit: totalNetDeficit,
      averageBMR: averageBMR,
      totalGlasses: totalGlasses,
      averageGlasses: averageGlasses,
      daysWithData: weekData.length,
      totalDays: 7,
    );
  }

  Future<void> _loadReport() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      CalorieReport report;
      
      // For now, let's use a simpler approach - get monthly data and filter it
      if (_selectedPeriod == 'weekly') {
        // Get current month data and filter for the specific week
        final monthlyReport = await context.read<FirebaseService>().generateCalorieReport(
          user.uid,
          'monthly',
        );
        report = _filterMonthlyDataForWeek(monthlyReport, _currentWeekStart);
      } else {
        // For monthly/yearly, use the original method
        report = await context.read<FirebaseService>().generateCalorieReport(
          user.uid,
          _selectedPeriod,
        );
      }
      
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
  
  void _goToPreviousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
    _loadReport();
  }
  
  void _goToNextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
    _loadReport();
  }
  
  void _selectMonth() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      selectableDayPredicate: (date) => date.day == 1, // Only allow first day of month
    );
    
    if (selectedDate != null) {
      setState(() {
        _selectedMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      });
      _loadReport();
    }
  }
  
  void _selectYear() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedYear,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      selectableDayPredicate: (date) => date.month == 1 && date.day == 1, // Only allow Jan 1st
    );
    
    if (selectedDate != null) {
      setState(() {
        _selectedYear = DateTime(selectedDate.year, 1, 1);
      });
      _loadReport();
    }
  }

  String _getChartTitle() {
    if (_selectedReportType == 'weight') {
      return 'Weight Progress - ${_selectedYear.year}';
    } else if (_selectedReportType == 'glasses') {
      return 'Water Intake Progress - ${_selectedYear.year}';
    }
    
    switch (_selectedPeriod) {
      case 'weekly':
        final endDate = _currentWeekStart.add(const Duration(days: 6));
        return 'Weekly Calorie Tracking\n${DateFormat('MMM d').format(_currentWeekStart)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
      case 'monthly':
        return 'Monthly Calorie Tracking - ${DateFormat('MMMM yyyy').format(_selectedMonth)}';
      case 'yearly':
        return 'Yearly Calorie Tracking - ${_selectedYear.year}';
      default:
        return 'Calorie Tracking';
    }
  }
  
  String _getChartDescription() {
    if (_selectedReportType == 'weight') {
      return 'Track your weight changes over time. Only shows days with recorded weight.';
    } else if (_selectedReportType == 'glasses') {
      return 'Track your daily water intake over time. Only shows days with recorded water intake.';
    }
    
    switch (_selectedPeriod) {
      case 'weekly':
        return 'Weekly view (Wednesday to Tuesday): Blue bars show calories consumed, green/red bars show net deficit (positive = good for weight loss)';
      case 'monthly':
        return 'Monthly overview: Shows net calorie deficit for each day. Positive values indicate calorie deficit (good for weight loss).';
      case 'yearly':
        return 'Yearly overview: Shows net calorie deficit trends. Positive values indicate calorie deficit (good for weight loss).';
      default:
        return 'Positive values indicate calorie deficit (good for weight loss). Only shows days with logged food or exercise.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedReportType == 'calories' ? 'Calorie Reports' : _selectedReportType == 'weight' ? 'Weight Reports' : 'Water Intake Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              _selectedReportType == 'calories' 
                  ? 'Track your calorie deficit over time'
                  : _selectedReportType == 'weight'
                  ? 'Track your weight changes over time'
                  : 'Track your daily water intake over time',
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
                        ButtonSegment(
                          value: 'glasses',
                          label: Text('Water'),
                          icon: Icon(Icons.local_drink),
                        ),
                      ],
                      selected: {_selectedReportType},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedReportType = selection.first;
                          // Auto-set yearly for weight and glasses reports
                          if (_selectedReportType == 'weight' || _selectedReportType == 'glasses') {
                            _selectedPeriod = 'yearly';
                          }
                        });
                        _loadReport();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Period Selection with Navigation
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
                    
                    // Period Type Selection (simplified for weight and glasses)
                    SegmentedButton<String>(
                      segments: (_selectedReportType == 'weight' || _selectedReportType == 'glasses') 
                          ? const [
                              ButtonSegment(
                                value: 'yearly',
                                label: Text('Yearly'),
                                icon: Icon(Icons.calendar_today),
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
                          // Auto-set yearly for weight and glasses reports
                          if (_selectedReportType == 'weight' || _selectedReportType == 'glasses') {
                            _selectedPeriod = 'yearly';
                          }
                        });
                        _loadReport();
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Navigation Controls
                    if (_selectedPeriod == 'weekly') ...[
                      Row(
                        children: [
                          IconButton(
                            onPressed: _goToPreviousWeek,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Previous Week',
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Week of ${DateFormat('MMM d, yyyy').format(_currentWeekStart)}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _currentWeekStart.isBefore(DateTime.now().subtract(const Duration(days: 7))) 
                                ? _goToNextWeek 
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Next Week',
                          ),
                        ],
                      ),
                    ] else if (_selectedPeriod == 'monthly') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectMonth,
                              icon: const Icon(Icons.calendar_month),
                              label: Text(DateFormat('MMMM yyyy').format(_selectedMonth)),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_selectedPeriod == 'yearly') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectYear,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_selectedYear.year.toString()),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DailyLogScreen(),
                      ),
                    );
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
            if (_selectedReportType == 'calories') ...[
              _buildSummaryCards(report),
              const SizedBox(height: 24),
            ] else if (_selectedReportType == 'glasses') ...[
              _buildGlassesSummaryCards(report),
              const SizedBox(height: 24),
            ],

            // Chart Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getChartTitle(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getChartDescription(),
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

  Widget _buildGlassesSummaryCards(CalorieReport report) {
    final glassesData = report.data.where((data) => data.glasses != null && data.glasses! > 0);
    final totalGlasses = glassesData.fold(0.0, (sum, data) => sum + data.glasses!);
    final averageGlasses = glassesData.isNotEmpty ? totalGlasses / glassesData.length : 0.0;
    final daysWithGlasses = glassesData.length;
    final goalAchieved = glassesData.where((data) => data.glasses! >= 8).length;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Glasses',
                '${totalGlasses.round()}',
                'glasses',
                Colors.cyan,
                Icons.local_drink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Daily Average',
                '${averageGlasses.toStringAsFixed(1)}',
                'glasses/day',
                Colors.blue,
                Icons.water_drop,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Days Logged',
                '$daysWithGlasses',
                'days',
                Colors.green,
                Icons.event_available,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Goal Achieved',
                '$goalAchieved',
                'days (8+ glasses)',
                goalAchieved > 0 ? Colors.green : Colors.orange,
                Icons.emoji_events,
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
    } else if (_selectedReportType == 'glasses') {
      return _buildGlassesChart(report);
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
        // Map to Wednesday-based week: Wed=1, Thu=2, Fri=3, Sat=4, Sun=5, Mon=6, Tue=7
        final wednesdayBasedDay = dayOfWeek == 3 ? 1 : // Wednesday -> 1
                                 dayOfWeek == 4 ? 2 : // Thursday -> 2
                                 dayOfWeek == 5 ? 3 : // Friday -> 3
                                 dayOfWeek == 6 ? 4 : // Saturday -> 4
                                 dayOfWeek == 7 ? 5 : // Sunday -> 5
                                 dayOfWeek == 1 ? 6 : // Monday -> 6
                                 7; // Tuesday -> 7
        weekData[wednesdayBasedDay] = data;
      }
      
      // Create bars for each day of the week (1-7, where 1=Wednesday)
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
                        // Show day names for weekly view (Wednesday to Tuesday)
                        const dayNames = ['', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue'];
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

  Widget _buildGlassesChart(CalorieReport report) {
    // Debug logging
    print('🚰 Building glasses chart with ${report.data.length} total data points');
    for (final data in report.data) {
      print('🚰 Date: ${data.date}, Glasses: ${data.glasses}');
    }
    
    // Filter data to only include entries with glasses
    final glassesData = report.data
        .where((data) => data.glasses != null && data.glasses! > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    print('🚰 Filtered to ${glassesData.length} entries with glasses data');

    if (glassesData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_drink, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No water intake data to display'),
            SizedBox(height: 8),
            Text('Add glasses of water in your daily log to see trends here', 
                 style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < glassesData.length; i++) {
      spots.add(FlSpot(i.toDouble(), glassesData[i].glasses!));
    }

    // Calculate min and max for better scaling
    final glasses = glassesData.map((d) => d.glasses!).toList();
    final minGlasses = glasses.reduce((a, b) => a < b ? a : b) - 1;
    final maxGlasses = glasses.reduce((a, b) => a > b ? a : b) + 1;

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
              interval: glassesData.length > 7 ? 2 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < glassesData.length) {
                  final date = glassesData[index].date;
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
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)} glasses',
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
        maxX: (glassesData.length - 1).toDouble(),
        minY: minGlasses,
        maxY: maxGlasses,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.cyan,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.cyan,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.cyan.withOpacity(0.2),
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
    } else if (_selectedReportType == 'glasses') {
      return _buildGlassesDataTable(report);
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

  Widget _buildGlassesDataTable(CalorieReport report) {
    final glassesData = report.data
        .where((data) => data.glasses != null && data.glasses! > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Water Intake')),
          DataColumn(label: Text('Goal Progress')),
        ],
        rows: glassesData.take(10).map((data) {
          final goalProgress = data.glasses! / 8.0; // Assuming 8 glasses daily goal
          final progressText = '${(goalProgress * 100).toStringAsFixed(0)}%';
          final isOnTrack = goalProgress >= 1.0;
          
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('MMM dd').format(data.date))),
              DataCell(Text('${data.glasses!.toStringAsFixed(0)} glasses')),
              DataCell(
                Text(
                  progressText,
                  style: TextStyle(
                    color: isOnTrack ? Colors.green : Colors.orange,
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