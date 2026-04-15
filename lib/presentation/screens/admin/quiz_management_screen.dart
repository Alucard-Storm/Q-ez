import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/quiz.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/admin_providers.dart';

/// Quiz management screen for admins
/// 
/// Features:
/// - Quiz list showing all quizzes from all teachers
/// - Search and filter by teacher
/// - Quiz cards with title, teacher name, and action buttons
/// - Edit quiz functionality with admin override
/// - Delete quiz with confirmation and cascade warning
/// - Activate/deactivate toggle for quizzes
/// 
/// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5
class QuizManagementScreen extends ConsumerStatefulWidget {
  const QuizManagementScreen({super.key});

  @override
  ConsumerState<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends ConsumerState<QuizManagementScreen> {
  String _searchQuery = '';
  String? _selectedTeacherId;
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
        title: const Text('Quiz Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

          return _buildQuizManagement(context, ref);
        },
      ),
    );
  }

  Widget _buildQuizManagement(BuildContext context, WidgetRef ref) {
    final allQuizzesAsync = ref.watch(allQuizzesProvider);
    final allTeachersAsync = ref.watch(allTeachersProvider);

    return Column(
      children: [
        // Search and filter section
        _buildSearchAndFilter(context, allTeachersAsync),
        
        // Quiz list
        Expanded(
          child: allQuizzesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorWidget('Failed to load quizzes', error),
            data: (quizzes) => _buildQuizList(context, ref, quizzes, allTeachersAsync),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, AsyncValue<List<Teacher>> allTeachersAsync) {
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
              hintText: 'Search quizzes by title or description...',
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
          
          // Teacher filter
          allTeachersAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
            data: (teachers) => Row(
              children: [
                const Text(
                  'Filter by teacher:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTeacherChip('All Teachers', null),
                        const SizedBox(width: 8),
                        ...teachers.map((teacher) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildTeacherChip(teacher.name, teacher.id),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherChip(String label, String? teacherId) {
    final isSelected = _selectedTeacherId == teacherId;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTeacherId = selected ? teacherId : null;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildQuizList(
    BuildContext context,
    WidgetRef ref,
    List<Quiz> quizzes,
    AsyncValue<List<Teacher>> allTeachersAsync,
  ) {
    // Filter quizzes based on search query and teacher
    final filteredQuizzes = quizzes.where((quiz) {
      final matchesSearch = _searchQuery.isEmpty ||
          quiz.title.toLowerCase().contains(_searchQuery) ||
          quiz.description.toLowerCase().contains(_searchQuery);
      
      final matchesTeacher = _selectedTeacherId == null || quiz.teacherId == _selectedTeacherId;
      
      return matchesSearch && matchesTeacher;
    }).toList();

    if (filteredQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedTeacherId != null
                  ? 'No quizzes match your filters'
                  : 'No quizzes found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            if (_searchQuery.isNotEmpty || _selectedTeacherId != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedTeacherId = null;
                  });
                },
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allQuizzesProvider);
        ref.invalidate(allTeachersProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = filteredQuizzes[index];
          return allTeachersAsync.when(
            loading: () => _buildQuizCardLoading(quiz),
            error: (error, stack) => _buildQuizCard(context, ref, quiz, 'Unknown Teacher'),
            data: (teachers) {
              final teacher = teachers.firstWhere(
                (t) => t.id == quiz.teacherId,
                orElse: () => Teacher(
                  id: quiz.teacherId,
                  email: 'unknown@example.com',
                  name: 'Unknown Teacher',
                  role: UserRole.teacher,
                  createdAt: DateTime.now(),
                  lastLoginAt: DateTime.now(),
                  createdQuizIds: [],
                ),
              );
              return _buildQuizCard(context, ref, quiz, teacher.name);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, WidgetRef ref, Quiz quiz, String teacherName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created by: $teacherName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (quiz.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          quiz.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'PIN: ${quiz.pin}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: quiz.isActive 
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: quiz.isActive 
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        quiz.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: quiz.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Quiz statistics
            Row(
              children: [
                Icon(
                  Icons.quiz,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${quiz.questions.length} questions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                if (quiz.timeLimitMinutes != null) ...[
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.timeLimitMinutes} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(quiz.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditQuizDialog(context, ref, quiz),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleQuizActive(context, ref, quiz),
                    icon: Icon(
                      quiz.isActive ? Icons.pause : Icons.play_arrow,
                      size: 16,
                    ),
                    label: Text(quiz.isActive ? 'Deactivate' : 'Activate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: quiz.isActive ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, ref, quiz),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Quiz',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCardLoading(Quiz quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading teacher info...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuizDialog(BuildContext context, WidgetRef ref, Quiz quiz) {
    final titleController = TextEditingController(text: quiz.title);
    final descriptionController = TextEditingController(text: quiz.description);
    final pinController = TextEditingController(text: quiz.pin);
    final timeLimitController = TextEditingController(
      text: quiz.timeLimitMinutes?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Time Limit (minutes)',
                  border: OutlineInputBorder(),
                  hintText: 'Leave empty for no time limit',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateQuiz(
                context,
                ref,
                quiz,
                titleController.text,
                descriptionController.text,
                pinController.text,
                timeLimitController.text.isEmpty 
                    ? null 
                    : int.tryParse(timeLimitController.text),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuiz(
    BuildContext context,
    WidgetRef ref,
    Quiz quiz,
    String newTitle,
    String newDescription,
    String newPin,
    int? newTimeLimit,
  ) async {
    try {
      final useCase = ref.read(manageQuizzesUseCaseProvider);
      
      final updatedQuiz = quiz.copyWith(
        title: newTitle,
        description: newDescription,
        pin: newPin,
        timeLimitMinutes: newTimeLimit,
      );
      
      await useCase.updateQuiz(updatedQuiz);
      
      // Refresh the quiz list
      ref.invalidate(allQuizzesProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quiz: $e')),
        );
      }
    }
  }

  Future<void> _toggleQuizActive(BuildContext context, WidgetRef ref, Quiz quiz) async {
    try {
      final useCase = ref.read(manageQuizzesUseCaseProvider);
      await useCase.setQuizActive(quiz.id, !quiz.isActive);
      
      // Refresh the quiz list
      ref.invalidate(allQuizzesProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              quiz.isActive 
                  ? 'Quiz deactivated successfully'
                  : 'Quiz activated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle quiz status: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${quiz.title}"?'),
            const SizedBox(height: 8),
            const Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text('• The quiz and all its questions'),
            const Text('• All student attempts and results'),
            const Text('• Quiz analytics and statistics'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteQuiz(context, ref, quiz);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuiz(BuildContext context, WidgetRef ref, Quiz quiz) async {
    try {
      final useCase = ref.read(manageQuizzesUseCaseProvider);
      await useCase.deleteQuiz(quiz.id);
      
      // Refresh the quiz list
      ref.invalidate(allQuizzesProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete quiz: $e')),
        );
      }
    }
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
            onPressed: () {
              ref.invalidate(allQuizzesProvider);
              ref.invalidate(allTeachersProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}