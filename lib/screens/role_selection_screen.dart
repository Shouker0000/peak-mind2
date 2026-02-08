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
    setState(() => _isLoading = true);

    try {
      print('📝 Signing up: ${widget.email}');

      var user = await _authService.signUp(
        email: widget.email,
        password: widget.password,
        name: widget.name,
        role: _selectedRole,
      );

      print('✅ Signup successful: ${user?.id}');

      if (mounted) {
        if (user != null) {
          // Return true to indicate success
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      print('❌ Signup error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peak Mind',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            const Text('Choose to join as?'),
            const SizedBox(height: 40),
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
            CustomButton(
              label: 'Create Account',
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
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(description, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
