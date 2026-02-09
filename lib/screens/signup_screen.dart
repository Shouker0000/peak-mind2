import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../utils/stage_grade_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();

  String? _selectedStage;
  String? _selectedGrade;
  bool _isLoading = false;
  bool _obscurePassword = true;

  List<String> _availableGrades = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  void _onStageChanged(String? newStage) {
    setState(() {
      _selectedStage = newStage;
      _selectedGrade = null; // Reset grade when stage changes
      _availableGrades = StageGradeHelper.getGradesForStage(newStage ?? '');
    });
  }

  Future<void> _signup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _birthYearController.text.isEmpty ||
        _selectedStage == null ||
        _selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with email and password
      final user = await _authService.signup(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        // Create user model
        UserModel userModel = UserModel(
          uid: user.uid,
          email: _emailController.text.trim(),
          displayName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          birthYear: int.parse(_birthYearController.text),
          stage: _selectedStage!,
          grade: _selectedGrade!,
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        // Update Firebase Auth display name
        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Account created successfully!'),
              backgroundColor: Color(0xFF25A0DC),
            ),
          );

          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF142132),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF142132),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create your account and start learning',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Full Name
            Text(
              'Full Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person, color: Color(0xFF25A0DC)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF25A0DC),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email, color: Color(0xFF25A0DC)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF25A0DC),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Number
            Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF25A0DC)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF25A0DC),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Birth Year
            Text(
              'Birth Year',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _birthYearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your birth year (e.g., 2005)',
                prefixIcon:
                    const Icon(Icons.calendar_today, color: Color(0xFF25A0DC)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF25A0DC),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stage (Educational Level)
            Text(
              'Educational Stage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text('Select your stage'),
                ),
                value: _selectedStage,
                onChanged: _onStageChanged,
                items: StageGradeHelper.getAllStages()
                    .map((stage) => DropdownMenuItem(
                          value: stage,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              stage.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF142132),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Grade (appears only if stage is selected)
            if (_selectedStage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grade',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('Select your grade'),
                      ),
                      value: _selectedGrade,
                      onChanged: (value) {
                        setState(() {
                          _selectedGrade = value;
                        });
                      },
                      items: _availableGrades
                          .map((grade) => DropdownMenuItem(
                                value: grade,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Text(
                                    grade,
                                    style: const TextStyle(
                                      color: Color(0xFF142132),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Password
            Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF25A0DC)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF25A0DC),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF25A0DC),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25A0DC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _signup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF25A0DC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
