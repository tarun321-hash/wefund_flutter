import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordFlowScreen extends StatefulWidget {
  @override
  _ForgotPasswordFlowScreenState createState() =>
      _ForgotPasswordFlowScreenState();
}

class _ForgotPasswordFlowScreenState extends State<ForgotPasswordFlowScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  int _step = 0; // 0 = enter email, 1 = enter code, 2 = set new password

  // replace with your real URLs:
  final _sendCodeUrl = 'https://wefundclient.com/Crm/Crm/forgot_password_api.php';
  final _verifyCodeUrl = 'https://wefundclient.com/Crm/Crm/verify_reset_code_api.php';
  final _resetPassUrl = 'https://wefundclient.com/Crm/Crm/reset_password_api.php';

 Future<void> _next() async {
  setState(() { _loading = true; _error = null; });

  try {
    http.Response resp;

    Map<String, String> jsonBody;
    String url;

    if (_step == 0) {
      url = _sendCodeUrl;
      jsonBody = {'email': _emailCtrl.text.trim()};
    } else if (_step == 1) {
      url = _verifyCodeUrl;
      jsonBody = {
        'email': _emailCtrl.text.trim(),
        'code':  _codeCtrl.text.trim(),
      };
    } else {
      if (_newPassCtrl.text != _confirmPassCtrl.text) {
        throw 'Passwords do not match';
      }
      url = _resetPassUrl;
      jsonBody = {
        'email':        _emailCtrl.text.trim(),
        'code':         _codeCtrl.text.trim(),
        'new_pass':     _newPassCtrl.text,
        'confirm_pass': _confirmPassCtrl.text,
      };
    }

    resp = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(jsonBody),
    );

    if (resp.statusCode != 200) {
      throw 'Server error: ${resp.statusCode}';
    }

    final jsonResp = json.decode(resp.body);
    if (jsonResp['status'] != 'success') {
      throw jsonResp['message'] ?? 'Unknown error';
    }

    // advance step or pop…
    if (_step < 2) {
      setState(() => _step += 1);
    } else {
      Navigator.of(context).pop();
    }
  } catch (e) {
    setState(() => _error = e.toString());
  } finally {
    setState(() => _loading = false);
  }
}

  Widget _buildCard() {
    switch (_step) {
      case 0:
        return _EmailStep(
          controller: _emailCtrl,
        );
      case 1:
        return _CodeStep(
          controller: _codeCtrl,
        );
      case 2:
        return _NewPasswordStep(
          newPassCtrl: _newPassCtrl,
          confirmPassCtrl: _confirmPassCtrl,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String get _buttonText {
    switch (_step) {
      case 0:
        return 'Send Code';
      case 1:
        return 'Verify Code';
      case 2:
        return 'Reset Password';
      default:
        return 'Next';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildCard(),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _next,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _buttonText,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                      ],
                    ),
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

/// Step 1: Enter email
class _EmailStep extends StatelessWidget {
  final TextEditingController controller;
  const _EmailStep({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Enter your registered email',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
            labelText: 'Email',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

/// Step 2: Enter code
class _CodeStep extends StatelessWidget {
  final TextEditingController controller;
  const _CodeStep({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Enter the 6‑digit code sent to your email',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.vpn_key, color: Colors.blueAccent),
            labelText: 'Verification Code',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
      ],
    );
  }
}

/// Step 3: New password
class _NewPasswordStep extends StatelessWidget {
  final TextEditingController newPassCtrl;
  final TextEditingController confirmPassCtrl;
  const _NewPasswordStep({
    required this.newPassCtrl,
    required this.confirmPassCtrl,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Set your new password',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: newPassCtrl,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
            labelText: 'New Password',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPassCtrl,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
            labelText: 'Confirm Password',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
