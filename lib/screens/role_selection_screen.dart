import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/custom_button.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const RoleSelectionScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = AppConstants.roleStudent;
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  Future<void> _completeSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var user = await _authService.signUp(
        email: widget.email,
        password: widget.password,
        name: widget.name,
        role: _selectedRole,
      );

      if (mounted) {
        if (user != null) {
          Navigator.of(context).pushReplacementNamed('/courses');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign up failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Peak Mind',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose to join as?',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.lightTextColor,
              ),
            ),
            const SizedBox(height: 40),

            // Student Option
            _RoleOption(
              title: 'Student',
              description: 'Learn from expert instructors',
              icon: Icons.person,
              isSelected: _selectedRole == AppConstants.roleStudent,
              onTap: () {
                setState(() {
                  _selectedRole = AppConstants.roleStudent;
                });
              },
            ),
            const SizedBox(height: 16),

            // Teacher Option
            _RoleOption(
              title: 'Teacher',
              description: 'Share your knowledge with students',
              icon: Icons.school,
              isSelected: _selectedRole == AppConstants.roleTeacher,
              onTap: () {
                setState(() {
                  _selectedRole = AppConstants.roleTeacher;
                });
              },
            ),

            const Spacer(),

            // Continue Button
            CustomButton(
              label: 'Continue',
              onPressed: _completeSignUp,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: title,
              groupValue: isSelected ? title : '',
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}
