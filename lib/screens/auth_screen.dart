import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/input_fields.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  bool isLoading = false;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!isSignIn && password != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isSignIn) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user?.updateDisplayName(
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSignIn
              ? 'Signed in successfully'
              : 'Account created successfully'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      // Navigate to home screen after successful login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBorderColor = Colors.white.withValues(alpha: 0.2);
    final authHintColor = Colors.white.withValues(alpha: 0.5);
    final authFillColor = Colors.white.withValues(alpha: 0.1);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1C0A4A),
                Color(0xFF0A0118),
                Color(0xFF2D1265),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with conditional text
                  Text(
                    isSignIn ? 'Welcome Back' : 'Create Account',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle with conditional text
                  Text(
                    isSignIn
                        ? 'Sign in to your account'
                        : 'Join us to get started',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!isSignIn) ...[
                    Row(
                      children: [
                        Expanded(
                          child: InputFields(
                            controller: firstNameController,
                            hintText: 'First Name',
                            hintColor: authHintColor,
                            fillColor: authFillColor,
                            borderColor: authBorderColor,
                            borderRadius: 12,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InputFields(
                            controller: lastNameController,
                            hintText: 'Last Name',
                            hintColor: authHintColor,
                            fillColor: authFillColor,
                            borderColor: authBorderColor,
                            borderRadius: 12,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Email field
                  InputFields(
                    controller: emailController,
                    hintText: 'Email',
                    hintColor: authHintColor,
                    fillColor: authFillColor,
                    borderColor: authBorderColor,
                    borderRadius: 12,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  InputFields(
                    controller: passwordController,
                    obscureText: true,
                    hintText: 'Password',
                    hintColor: authHintColor,
                    fillColor: authFillColor,
                    borderColor: authBorderColor,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password field (only for Sign Up)
                  if (!isSignIn) ...[
                    InputFields(
                      controller: confirmPasswordController,
                      obscureText: true,
                      hintText: 'Confirm Password',
                      hintColor: authHintColor,
                      fillColor: authFillColor,
                      borderColor: authBorderColor,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Forgot Password link (only for Sign In)
                  if (isSignIn) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Submit button with conditional text
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF2B125A)),
                              ),
                            )
                          : Text(
                              isSignIn ? 'Sign In' : 'Create Account',
                              style: const TextStyle(
                                color: Color(0xFF2B125A),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Toggle between Sign In and Sign Up
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSignIn
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignIn = !isSignIn;
                            });
                          },
                          child: Text(
                            isSignIn ? 'Sign Up' : 'Sign In',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
