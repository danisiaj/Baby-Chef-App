import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _busy = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String value, String value1) {
    if (value.length < 8 || value.length > 12) {
      return 'Password must be 8-12 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Add at least one uppercase letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Add at least one number';
    }
    if (!RegExp(r"""[!@#\$%\^&\*\(\)_\+\-=\[\]{};:\'"\\|,.<>\/\?]""")
        .hasMatch(value)) {
      return 'Add at least one special character';
    }
    if (value != value1) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _onCreatePressed() async {
    if (_busy) return;

    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    final passwordVerify = _confirmCtrl.text;
    final code = _codeCtrl.text.trim();

    final passwordError = _validatePassword(password, passwordVerify);
    setState(() {
      _firstNameError = firstName.isEmpty ? 'Required' : null;
      _lastNameError = lastName.isEmpty ? 'Required' : null;
      _emailError = email.isEmpty ? 'Required' : null;
      _usernameError = username.isEmpty ? 'Required' : null;
      _passwordError = password.isEmpty ? 'Required' : null;
      _confirmError = passwordVerify.isEmpty ? 'Required' : null;

      if (_passwordError == null && _confirmError == null && passwordError != null) {
        if (passwordError == 'Passwords do not match') {
          _confirmError = passwordError;
        } else {
          _passwordError = passwordError;
        }
      }
    });

    final hasErrors = _firstNameError != null ||
        _lastNameError != null ||
        _emailError != null ||
        _usernameError != null ||
        _passwordError != null ||
        _confirmError != null;
    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix highlighted fields.')),
      );
      return;
    }

    setState(() => _busy = true);

    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('createUserWithCode');
      await callable.call({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'username': username,
        if (code.isNotEmpty) 'code': code,
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created. Verify your email to continue.'),
        ),
      );
      setState(() => _busy = false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final message = switch (e) {
        FirebaseFunctionsException(:final code, :final message)
            when code == 'permission-denied' =>
          message ?? 'Invalid admin code',
        FirebaseFunctionsException(:final code, :final message)
            when code == 'already-exists' =>
          message ?? 'Email already in use',
        FirebaseFunctionsException(:final code, :final message)
            when code == 'invalid-argument' =>
          message ?? 'Invalid input',
        FirebaseFunctionsException(:final code, :final message)
            when code == 'unavailable' =>
          message ?? 'Service unavailable',
        FirebaseFunctionsException(:final message) =>
          message ?? 'Account creation failed',
        _ => 'Account creation failed',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                Text(
                  'Admin code is optional. Leave blank for clinician access.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _firstNameCtrl,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_firstNameError != null) setState(() => _firstNameError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'First name',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    errorText: _firstNameError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lastNameCtrl,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_lastNameError != null) setState(() => _lastNameError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Last name',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    errorText: _lastNameError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(CupertinoIcons.mail),
                    errorText: _emailError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _userCtrl,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_usernameError != null) setState(() => _usernameError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(CupertinoIcons.person),
                    errorText: _usernameError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_passwordError != null || _confirmError != null) {
                      setState(() {
                        _passwordError = null;
                        _confirmError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(CupertinoIcons.lock),
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_confirmError != null) setState(() => _confirmError = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: const Icon(CupertinoIcons.lock),
                    errorText: _confirmError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codeCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Admin code (optional)',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _onCreatePressed,
                    child: _busy
                        ? const CircularProgressIndicator()
                        : const Text('Create account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
