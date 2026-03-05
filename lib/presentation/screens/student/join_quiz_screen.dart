import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/navigation_extensions.dart';
import '../../../domain/entities/quiz.dart';
import '../../../domain/usecases/quiz_participation/join_quiz_use_case.dart';
import '../../providers/auth_providers.dart';
import '../../providers/quiz_providers.dart';

/// Quiz PIN entry screen for students
/// 
/// Features:
/// - PIN input field with numeric keyboard
/// - PIN validation and quiz lookup
/// - Quiz details display (title, description, time limit, question count)
/// - Start Quiz button
/// 
/// Requirements: 5.1, 5.2
class JoinQuizScreen extends ConsumerStatefulWidget {
  const JoinQuizScreen({super.key});

  @override
  ConsumerState<JoinQuizScreen> createState() => _JoinQuizScreenState();
}

class _JoinQuizScreenState extends ConsumerState<JoinQuizScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  Quiz? _foundQuiz;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              _buildHeaderSection(),
              const SizedBox(height: 32),

              // PIN input section
              _buildPinInputSection(),
              const SizedBox(height: 24),

              // Quiz details section (shown when quiz is found)
              if (_foundQuiz != null) ...[
                _buildQuizDetailsSection(),
                const SizedBox(height: 24),
              ],

              // Error message
              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: 24),
              ],

              // Action buttons
              _buildActionButtons(),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Icon(
          Icons.quiz,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Enter Quiz PIN',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit PIN provided by your teacher',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPinInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz PIN',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              letterSpacing: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a PIN';
            }
            if (value.length != 6) {
              return 'PIN must be 6 digits';
            }
            return null;
          },
          onChanged: (value) {
            // Clear previous error and quiz when PIN changes
            if (_errorMessage != null || _foundQuiz != null) {
              setState(() {
                _errorMessage = null;
                _foundQuiz = null;
              });
            }
            
            // Auto-lookup when 6 digits are entered
            if (value.length == 6) {
              _lookupQuiz();
            }
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _lookupQuiz,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Find Quiz'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizDetailsSection() {
    if (_foundQuiz == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quiz Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Quiz title
            _buildDetailRow(
              icon: Icons.title,
              label: 'Title',
              value: _foundQuiz!.title,
            ),
            const SizedBox(height: 12),
            
            // Quiz description
            if (_foundQuiz!.description.isNotEmpty) ...[
              _buildDetailRow(
                icon: Icons.description,
                label: 'Description',
                value: _foundQuiz!.description,
              ),
              const SizedBox(height: 12),
            ],
            
            // Question count
            _buildDetailRow(
              icon: Icons.help_outline,
              label: 'Questions',
              value: '${_foundQuiz!.questions.length} questions',
            ),
            const SizedBox(height: 12),
            
            // Time limit
            _buildDetailRow(
              icon: Icons.timer,
              label: 'Time Limit',
              value: _foundQuiz!.timeLimitMinutes != null
                  ? '${_foundQuiz!.timeLimitMinutes} minutes'
                  : 'No time limit',
            ),
            
            // Quiz status indicator
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _foundQuiz!.isActive 
                    ? Colors.green.shade100 
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _foundQuiz!.isActive ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: _foundQuiz!.isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _foundQuiz!.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: _foundQuiz!.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Quiz button (only shown when quiz is found and active)
        if (_foundQuiz != null && _foundQuiz!.isActive)
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _startQuiz,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Start Quiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Back to Home button
        OutlinedButton(
          onPressed: () => context.goToStudentHome(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }

  Future<void> _lookupQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundQuiz = null;
    });

    try {
      final pin = _pinController.text.trim();
      final quizRepository = ref.read(quizRepositoryProvider);
      final quiz = await quizRepository.getQuizByPin(pin);
      
      setState(() {
        _foundQuiz = quiz;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _startQuiz() async {
    if (_foundQuiz == null) return;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to start a quiz';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create join quiz use case
      final quizRepository = ref.read(quizRepositoryProvider);
      final attemptRepository = ref.read(attemptRepositoryProvider);
      final joinQuizUseCase = JoinQuizUseCase(quizRepository, attemptRepository);
      
      // Join the quiz
      await joinQuizUseCase(
        studentId: currentUser.id,
        pin: _pinController.text.trim(),
      );
      
      // Set the active attempt in the provider
      await ref.read(activeAttemptProvider.notifier).startAttempt(
        currentUser.id,
        _foundQuiz!.id,
      );
      
      // Navigate to quiz taking screen
      if (mounted) {
        context.goToQuizTaking(_foundQuiz!.id);
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('PIN') && errorString.contains('not found')) {
      return 'Quiz not found. Please check the PIN and try again.';
    }
    
    if (errorString.contains('no longer active')) {
      return 'This quiz is no longer active.';
    }
    
    if (errorString.contains('already have an active')) {
      return 'You already have an active quiz attempt. Please complete it first.';
    }
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }
    
    return 'An error occurred. Please try again.';
  }
}