import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/navigation_extensions.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/teacher_providers.dart';

/// Quiz creation screen
/// 
/// Features:
/// - Quiz form with title and description inputs
/// - Time limit input with optional toggle
/// - Dynamic question list with add/remove functionality
/// - Question editor with text input and four option fields
/// - Correct answer selector (radio buttons)
/// - PIN input with auto-generate option
/// - Form validation for all required fields
/// - Display generated PIN after creation
/// 
/// Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.4
class CreateQuizScreen extends ConsumerStatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pinController = TextEditingController();
  final _timeLimitController = TextEditingController();
  
  bool _hasTimeLimit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with one empty question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizFormProvider.notifier).addQuestion();
    });
  }

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
    final formState = ref.watch(quizFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveQuiz,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(quizFormProvider.notifier).addQuestion(),
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
                      labelText: 'Custom PIN (optional)',
                      hintText: 'Leave empty to auto-generate',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (value) {
                      ref.read(quizFormProvider.notifier).updatePin(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _generatePin,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Students will use this PIN to join your quiz. If left empty, a PIN will be generated automatically.',
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
                  onPressed: () => ref.read(quizFormProvider.notifier).removeQuestion(index),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  void _generatePin() {
    final pin = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    _pinController.text = pin;
    ref.read(quizFormProvider.notifier).updatePin(pin);
  }

  Future<void> _saveQuiz() async {
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
      final createUseCase = ref.read(createQuizUseCaseProvider);
      final quiz = formNotifier.toQuiz(currentUser.id);
      
      final createdQuiz = await createUseCase(quiz);
      
      // Reset form
      formNotifier.reset();
      
      if (mounted) {
        // Show success dialog with PIN
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Quiz Created Successfully!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your quiz "${createdQuiz.title}" has been created.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Quiz PIN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        createdQuiz.pin,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Students can use this PIN to join your quiz.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.goToTeacherHome();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create quiz: $e')),
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