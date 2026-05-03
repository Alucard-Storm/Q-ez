import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/quiz_providers.dart';
import '../../providers/teacher_providers.dart';

/// Quiz edit screen
/// 
/// Features:
/// - Reuse quiz creation form with pre-filled data
/// - Update and cancel buttons
/// - Confirmation dialog for destructive changes
/// 
/// Requirements: 2.5, 2.7
class EditQuizScreen extends ConsumerStatefulWidget {
  final String quizId;

  const EditQuizScreen({
    super.key,
    required this.quizId,
  });

  @override
  ConsumerState<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends ConsumerState<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pinController = TextEditingController();
  final _timeLimitController = TextEditingController();
  
  bool _hasTimeLimit = false;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pinController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final quizAsync = ref.watch(quizByIdProvider(widget.quizId));
    final formState = ref.watch(quizFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBackPress(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateQuiz,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
        ],
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null || user.role != UserRole.teacher) {
            return const Center(child: Text('Access denied'));
          }

          return quizAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load quiz: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(quizByIdProvider(widget.quizId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (quiz) {
              // Load quiz data into form on first build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_hasChanges) {
                  _loadQuizData(quiz);
                }
              });

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildTimeLimitSection(),
                      const SizedBox(height: 24),
                      _buildPinSection(),
                      const SizedBox(height: 24),
                      _buildQuestionsSection(formState),
                      const SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(quizFormProvider.notifier).addQuestion();
          _markAsChanged();
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Question',
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title *',
                hintText: 'Enter quiz title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Quiz title is required';
                }
                return null;
              },
              onChanged: (value) {
                ref.read(quizFormProvider.notifier).updateTitle(value);
                _markAsChanged();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter quiz description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                ref.read(quizFormProvider.notifier).updateDescription(value);
                _markAsChanged();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLimitSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Limit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set time limit'),
              subtitle: const Text('Enable to set a time limit for this quiz'),
              value: _hasTimeLimit,
              onChanged: (value) {
                setState(() {
                  _hasTimeLimit = value;
                  if (!value) {
                    _timeLimitController.clear();
                    ref.read(quizFormProvider.notifier).updateTimeLimit(null);
                  }
                });
                _markAsChanged();
              },
            ),
            if (_hasTimeLimit) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Time Limit (minutes)',
                  hintText: 'Enter time limit in minutes',
                  border: OutlineInputBorder(),
                  suffixText: 'minutes',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_hasTimeLimit) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Time limit is required when enabled';
                    }
                    final timeLimit = int.tryParse(value);
                    if (timeLimit == null || timeLimit <= 0) {
                      return 'Please enter a valid time limit';
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  final timeLimit = int.tryParse(value);
                  ref.read(quizFormProvider.notifier).updateTimeLimit(timeLimit);
                  _markAsChanged();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPinSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quiz PIN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pinController,
                    decoration: const InputDecoration(
                      labelText: 'Quiz PIN *',
                      hintText: 'Enter quiz PIN',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quiz PIN is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      ref.read(quizFormProvider.notifier).updatePin(value);
                      _markAsChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _generatePin();
                    _markAsChanged();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Students use this PIN to join your quiz. Make sure it\'s unique.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(QuizFormState formState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${formState.questions.length} question${formState.questions.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (formState.questions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No questions added yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first question',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...formState.questions.asMap().entries.map(
                (entry) => _buildQuestionCard(entry.key, entry.value),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, QuestionFormData question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Question ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ref.read(quizFormProvider.notifier).removeQuestion(index);
                    _markAsChanged();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Question',
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: question.text,
              decoration: const InputDecoration(
                labelText: 'Question Text *',
                hintText: 'Enter your question',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Question text is required';
                }
                return null;
              },
              onChanged: (value) {
                final updatedQuestion = question.copyWith(text: value);
                ref.read(quizFormProvider.notifier).updateQuestion(index, updatedQuestion);
                _markAsChanged();
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Answer Options',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(4, (optionIndex) => _buildOptionField(index, question, optionIndex)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(int questionIndex, QuestionFormData question, int optionIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Radio<int>(
            value: optionIndex,
            groupValue: question.correctOptionIndex,
            onChanged: (value) {
              if (value != null) {
                final updatedQuestion = question.copyWith(correctOptionIndex: value);
                ref.read(quizFormProvider.notifier).updateQuestion(questionIndex, updatedQuestion);
                _markAsChanged();
              }
            },
          ),
          Expanded(
            child: TextFormField(
              initialValue: question.options[optionIndex],
              decoration: InputDecoration(
                labelText: 'Option ${String.fromCharCode(65 + optionIndex)} *',
                hintText: 'Enter answer option',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Option is required';
                }
                return null;
              },
              onChanged: (value) {
                final updatedOptions = List<String>.from(question.options);
                updatedOptions[optionIndex] = value;
                final updatedQuestion = question.copyWith(options: updatedOptions);
                ref.read(quizFormProvider.notifier).updateQuestion(questionIndex, updatedQuestion);
                _markAsChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadQuizData(dynamic quiz) {
    _titleController.text = quiz.title ?? '';
    _descriptionController.text = quiz.description ?? '';
    _pinController.text = quiz.pin ?? '';
    
    _hasTimeLimit = quiz.timeLimitMinutes != null;
    if (_hasTimeLimit) {
      _timeLimitController.text = quiz.timeLimitMinutes.toString();
    }

    // Load quiz data into form state
    ref.read(quizFormProvider.notifier).loadQuiz(quiz);
  }

  void _generatePin() {
    final pin = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    _pinController.text = pin;
    ref.read(quizFormProvider.notifier).updatePin(pin);
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _handleBackPress(BuildContext context) {
    if (_hasChanges) {
      _showDiscardChangesDialog(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showDiscardChangesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    final formNotifier = ref.read(quizFormProvider.notifier);
    if (!formNotifier.isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all required fields')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateUseCase = ref.read(updateQuizUseCaseProvider);
      final updatedQuiz = formNotifier.toQuiz(currentUser.id).copyWith(id: widget.quizId);
      
      await updateUseCase(updatedQuiz);
      
      // Refresh quiz data
      ref.invalidate(quizByIdProvider(widget.quizId));
      ref.invalidate(teacherQuizzesProvider(currentUser.id));
      ref.invalidate(teacherDashboardProvider(currentUser.id));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quiz: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}