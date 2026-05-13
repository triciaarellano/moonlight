import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_style_tokens.dart';
import '../widgets/app_gradient_screen_shell.dart';
import '../widgets/input_fields.dart';
import '../widgets/settings/settings_top_header_section.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.isDayTheme = false,
  });

  final bool isDayTheme;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final nameParts = _splitName(user?.displayName);
    _firstNameController.text = nameParts[0];
    _lastNameController.text = nameParts[1];
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  List<String> _splitName(String? displayName) {
    final trimmed = displayName?.trim() ?? '';
    if (trimmed.isEmpty) {
      return const ['', ''];
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return [parts.first, ''];
    }
    return [parts.first, parts.sublist(1).join(' ')];
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please sign in again.')),
      );
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final updatedDisplayName =
        [firstName, lastName].where((value) => value.isNotEmpty).join(' ');

    if (updatedDisplayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }

    final existingName = user.displayName?.trim() ?? '';
    if (updatedDisplayName == existingName) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await user.updateDisplayName(updatedDisplayName);
      await user.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to update profile.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update profile.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppScreenPalette.fromIsDay(widget.isDayTheme);
    final borderColor = palette.cardBorder;
    final inputFillColor = palette.surface;
    final hintColor = palette.mutedText;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: palette.background,
        body: AppGradientScreenShell(
          gradient: palette.gradient,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SettingsTopHeaderSection(
                  title: 'Edit Profile',
                  textColor: palette.primaryText,
                  onBackPressed: () => Navigator.pop(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update your profile details',
                          style: TextStyle(
                            color: palette.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InputFields(
                                controller: _firstNameController,
                                hintText: 'First Name',
                                textCapitalization: TextCapitalization.words,
                                textColor: palette.primaryText,
                                hintColor: hintColor,
                                fillColor: inputFillColor,
                                borderColor: borderColor,
                                focusedBorderColor: palette.accent,
                                borderRadius: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InputFields(
                                controller: _lastNameController,
                                hintText: 'Last Name',
                                textCapitalization: TextCapitalization.words,
                                textColor: palette.primaryText,
                                hintColor: hintColor,
                                fillColor: inputFillColor,
                                borderColor: borderColor,
                                focusedBorderColor: palette.accent,
                                borderRadius: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InputFields(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                          textColor: palette.secondaryText,
                          hintColor: hintColor,
                          fillColor: inputFillColor,
                          borderColor: borderColor,
                          focusedBorderColor: palette.accent,
                          borderRadius: 12,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email changes are not available here.',
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.accent,
                              disabledBackgroundColor:
                                  palette.accent.withValues(alpha: 0.6),
                              foregroundColor: palette.onAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        palette.onAccent,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
