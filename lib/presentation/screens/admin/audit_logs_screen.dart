import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/quiz_attempt.dart';
import '../../../domain/usecases/admin/view_audit_logs_use_case.dart';
import '../../providers/auth_providers.dart';
import '../../providers/admin_providers.dart';

/// Audit logs screen for admins
/// 
/// Features:
/// - Log list with timestamps and admin actions
/// - Filter by admin, action type, and date range
/// - Security violations with student and quiz details
/// - Log export functionality
/// 
/// Requirements: 10.4, 15.8
class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  String _searchQuery = '';
  SecurityViolationType? _selectedViolationType;
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportLogs(context, ref),
            tooltip: 'Export Logs',
          ),
        ],
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user logged in'));
          }

          if (user.role != UserRole.admin) {
            return const Center(child: Text('Access denied: Admin role required'));
          }

          return _buildAuditLogs(context, ref);
        },
      ),
    );
  }

  Widget _buildAuditLogs(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(auditLogsProvider);

    return Column(
      children: [
        // Search and filter section
        _buildSearchAndFilter(context),
        
        // Audit logs list
        Expanded(
          child: auditLogsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorWidget('Failed to load audit logs', error),
            data: (logs) => _buildLogsList(context, ref, logs),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by student name or quiz title...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),
          
          // Filters row
          Row(
            children: [
              // Violation type filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Violation Type:',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildViolationTypeChip('All', null),
                          const SizedBox(width: 8),
                          _buildViolationTypeChip('Tab Switch', SecurityViolationType.tabSwitch),
                          const SizedBox(width: 8),
                          _buildViolationTypeChip('App Switch', SecurityViolationType.appSwitch),
                          const SizedBox(width: 8),
                          _buildViolationTypeChip('Copy Attempt', SecurityViolationType.copyAttempt),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Date range filter
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _selectedDateRange == null
                        ? 'Select Date Range'
                        : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              if (_selectedDateRange != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateRange = null;
                    });
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  tooltip: 'Clear date filter',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViolationTypeChip(String label, SecurityViolationType? type) {
    final isSelected = _selectedViolationType == type;
    
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedViolationType = selected ? type : null;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Widget _buildLogsList(BuildContext context, WidgetRef ref, List<AuditLogEntry> logs) {
    // Filter logs based on search query, violation type, and date range
    final filteredLogs = logs.where((log) {
      final matchesSearch = _searchQuery.isEmpty ||
          log.studentName.toLowerCase().contains(_searchQuery) ||
          log.quizTitle.toLowerCase().contains(_searchQuery);
      
      final matchesViolationType = _selectedViolationType == null ||
          log.violations.any((v) => v.type == _selectedViolationType);
      
      final matchesDateRange = _selectedDateRange == null ||
          (log.attemptDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
           log.attemptDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));
      
      return matchesSearch && matchesViolationType && matchesDateRange;
    }).toList();

    if (filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _hasActiveFilters()
                  ? 'No logs match your filters'
                  : 'No security violations found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            if (_hasActiveFilters()) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedViolationType = null;
                    _selectedDateRange = null;
                  });
                },
                child: const Text('Clear all filters'),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'All quiz attempts are clean!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(auditLogsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredLogs.length,
        itemBuilder: (context, index) {
          final log = filteredLogs[index];
          return _buildLogCard(context, ref, log);
        },
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, WidgetRef ref, AuditLogEntry log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: log.isFlagged ? Colors.red.shade100 : Colors.orange.shade100,
          child: Icon(
            log.isFlagged ? Icons.flag : Icons.warning,
            color: log.isFlagged ? Colors.red : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          'Security Violation${log.totalViolations > 1 ? 's' : ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${log.studentName}'),
            Text('Quiz: ${log.quizTitle}'),
            Text('Date: ${_formatDateTime(log.attemptDate)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: log.isFlagged ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: log.isFlagged ? Colors.red.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${log.totalViolations} violation${log.totalViolations > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: log.isFlagged ? Colors.red : Colors.orange,
                ),
              ),
            ),
            if (log.isFlagged) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FLAGGED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Violation Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...log.violations.map((violation) => _buildViolationDetail(violation)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewStudentDetails(context, ref, log.studentId),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('View Student'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewQuizDetails(context, ref, log.quizId),
                        icon: const Icon(Icons.quiz, size: 16),
                        label: const Text('View Quiz'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationDetail(SecurityViolation violation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            _getViolationIcon(violation.type),
            size: 16,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_getViolationDescription(violation.type)} at ${_formatTime(violation.timestamp)}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getViolationIcon(SecurityViolationType type) {
    switch (type) {
      case SecurityViolationType.tabSwitch:
        return Icons.tab;
      case SecurityViolationType.appSwitch:
        return Icons.apps;
      case SecurityViolationType.copyAttempt:
        return Icons.content_copy;
    }
  }

  String _getViolationDescription(SecurityViolationType type) {
    switch (type) {
      case SecurityViolationType.tabSwitch:
        return 'Switched browser tab';
      case SecurityViolationType.appSwitch:
        return 'Switched to another app';
      case SecurityViolationType.copyAttempt:
        return 'Attempted to copy content';
    }
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
           _selectedViolationType != null ||
           _selectedDateRange != null;
  }

  void _viewStudentDetails(BuildContext context, WidgetRef ref, String studentId) {
    // TODO: Navigate to student details or show student info dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View student details: $studentId')),
    );
  }

  void _viewQuizDetails(BuildContext context, WidgetRef ref, String quizId) {
    // TODO: Navigate to quiz details or show quiz info dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View quiz details: $quizId')),
    );
  }

  void _exportLogs(BuildContext context, WidgetRef ref) {
    // TODO: Implement log export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality will be implemented in a future update'),
      ),
    );
  }

  Widget _buildErrorWidget(String title, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(auditLogsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}