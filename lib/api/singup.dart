import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:country_code_picker/country_code_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wefund/api/login.dart';


import 'package:wefund/BottomNavigationBar.dart'; // your bottom nav import

class SignupResponse {
  final String status;
  final String message;
  SignupResponse({required this.status, required this.message});
  factory SignupResponse.fromJson(Map<String, dynamic> json) =>
      SignupResponse(status: json['status'], message: json['message']);
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl    = TextEditingController();
  final TextEditingController emailCtrl    = TextEditingController();
  final TextEditingController emailOtpCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController smsOtpCtrl = TextEditingController();

bool _smsOtpSent    = false;
bool _smsVerified   = false;
String? _smsOtpCode;
String _completePhoneNumber = '';

  // state
  bool _obscurePwd      = true;
  bool _isLoading       = false;
  bool _isSmsLoading    = false; 
  bool _isEmailLoading  = false;
  bool _emailOtpSent    = false;
  bool _emailVerified   = false;
  String _countryCode   = '+1'; 
  String? _emailOtpCode;  // store server‐sent OTP

  static const _baseUrl = 'https://wefundclient.com/Crm/Crm';

  @override
void dispose() {
  fullNameCtrl.dispose();
  phoneCtrl.dispose();
  emailCtrl.dispose();
  emailOtpCtrl.dispose();
  passwordCtrl.dispose();
  smsOtpCtrl.dispose();
  super.dispose();
}

Future<void> _sendSmsOtp() async {
  setState(() => _isSmsLoading = true);
  try {
    final resp = await http.post(
      Uri.parse('$_baseUrl/send_sms_otp.php'),
      headers: {'Content-Type':'application/json'},
      body: json.encode({'mobile_number': _completePhoneNumber}),
    );
    if (resp.statusCode != 200) {
      throw 'Server error: ${resp.statusCode}';
    }
    final body = resp.body.trim();
    if (body.isEmpty) throw 'Empty response';
    final j = json.decode(body) as Map<String, dynamic>;

    if (j['status'] == 'success') {
      setState(() => _smsOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SMS OTP sent'), backgroundColor: Colors.blueAccent),
      );
    } else {
      throw j['message'] ?? 'Failed to send OTP';
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  } finally {
    setState(() => _isSmsLoading = false);
  }
}

Future<void> _verifySmsOtp() async {
  setState(() => _isSmsLoading = true);
  try {
    final resp = await http.post(
      Uri.parse('$_baseUrl/verify_sms_otp.php'),
      headers: {'Content-Type':'application/json'},
      body: json.encode({
        'mobile_number': _completePhoneNumber,
        'sms_otp': smsOtpCtrl.text.trim(),
      }),
    );
    if (resp.statusCode != 200) {
      throw 'Server error: ${resp.statusCode}';
    }
    final body = resp.body.trim();
    if (body.isEmpty) throw 'Empty response';
    final j = json.decode(body) as Map<String, dynamic>;

    if (j['status'] == 'success') {
      setState(() => _smsVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone verified ✔️')),
      );
    } else {
      throw j['message'] ?? 'Invalid OTP';
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  } finally {
    setState(() =>_isSmsLoading = false);
  }
}




  // 1) Send OTP to email
  Future<void> _sendEmailOtp() async {
    setState(() => _isEmailLoading = true);
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/send_email_otp.php'),
        headers: {'Content-Type':'application/json'},
        body: json.encode({'email': emailCtrl.text.trim()}),
      );
      if (resp.statusCode != 200) {
        throw 'Server error: ${resp.statusCode}';
      }
      final j = json.decode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && j['status']=='success') {
        // assume server also returns the OTP for test / or skip
        _emailOtpCode = j['otp']?.toString();
        setState(() {
          _emailOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your email'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw j['message'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isEmailLoading = false);
    }
  }

  // 2) Verify entered OTP
  Future<void> _verifyEmailOtp() async {
    setState(() => _isEmailLoading = true);
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/verify_email_otp.php'),
        headers: {'Content-Type':'application/json'},
        body: json.encode({
      'email': emailCtrl.text.trim(),
      'otp':   emailOtpCtrl.text.trim(),
    }),
      );
      if (resp.statusCode != 200) {
        throw 'Server error: ${resp.statusCode}';
      }
      print('form_api resp.status=${resp.statusCode} body=');
print(resp.body);

      final j = json.decode(resp.body) as Map<String, dynamic>;


      if (j['status'] == 'success') {
        setState(() => _emailVerified = true);
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified ✔️'), backgroundColor: Colors.green),
        );
      } else {
        throw j['message'] ?? 'Invalid OTP';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isEmailLoading = false);
    }
  }

  // 3) Final signup
  Future<void> _submit() async {
  if (!_formKey.currentState!.validate() || !_emailVerified || !_smsVerified) {
    if (!_emailVerified || !_smsVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify both email & phone'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  setState(() => _isLoading = true);
  try {
    final resp = await http.post(
      Uri.parse('$_baseUrl/form_api.php'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'username'      : fullNameCtrl.text.trim(),
        'email'         : emailCtrl.text.trim(),
        'mobile_number' : _completePhoneNumber,  // ← was wrong before
        'app_password'  : passwordCtrl.text.trim(),
      }),
    );

    final body = resp.body.trim();      // strip any stray whitespace
    final j    = json.decode(body);     
    final result = SignupResponse.fromJson(j);

    if (resp.statusCode == 200 && result.status == 'success') {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.message),
             backgroundColor: Colors.green),
  );

  // ★ Instead of auto-logging in, send them back to the Login screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => LoginScreen()),
  );
}    else {
      throw result.message;
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // white background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign Up to WEFUND',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // 1) Full name
                  TextFormField(
                    controller: fullNameCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Enter your full name' : null,
                  ),
                  const SizedBox(height: 16),

                  // 2) Phone with built‑in country selector
IntlPhoneField(
  initialCountryCode: 'IN',
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),
    labelText: 'Phone Number',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
  ),
  onChanged: (phone) {
    setState(() {
      _completePhoneNumber = phone.completeNumber;
    });
  },
  validator: (phone) =>
    phone == null || phone.number.isEmpty ? 'Enter phone number' : null,
),


                  const SizedBox(height: 16),
                  // ─── Mobile OTP Row ─────────────────────────────────────────────────
Row(
  children: [
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,        // ← add this
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: (_isSmsLoading || _smsVerified) ? null : _sendSmsOtp,
        child: _isSmsLoading
    ? SizedBox(
        width:16, height:16,
        child: CircularProgressIndicator(strokeWidth:2,color:Colors.white))
    : Text(_smsOtpSent ? 'Resend SMS OTP' : 'Send SMS OTP'),
      ),
    ),
  ],
),


if (_smsOtpSent && !_smsVerified) ...[
  const SizedBox(height: 12),
  TextFormField(
    controller: smsOtpCtrl,
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.sms, color: Colors.blueAccent),
      labelText: 'Enter SMS OTP',
      border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.number,
    maxLength: 6,
  ),
  Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,        // ← add this
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: _verifySmsOtp,
    child: const Text('Verify SMS OTP'),
  ),
),


],
const SizedBox(height: 16),
// ─────────────────────────────────────────────────────────────────────


                  // 3) Email + Send OTP / Verify
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Enter email';
                      if (!v.contains('@'))    return 'Invalid email';
                      return null;
                    },
                    enabled: !_emailVerified,
                  ),
                  const SizedBox(height: 8),
                  Row(
  children: [
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,        // ← add this
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: (_isEmailLoading || _emailVerified) ? null : _sendEmailOtp,
        child: _isEmailLoading
    ? SizedBox(
        width:16, height:16,
        child: CircularProgressIndicator(strokeWidth:2,color:Colors.white))
    : Text(_emailOtpSent ? 'Resend OTP' : 'Send OTP'),

      ),
    ),
  ],
),


                  if (_emailOtpSent && !_emailVerified) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailOtpCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.vpn_key, color: Colors.blueAccent),
                        labelText: 'Enter OTP',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                    const SizedBox(height: 8),
                    Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,        // ← add this
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: _verifyEmailOtp,
    child: const Text('Verify OTP'),
  ),
),

                  ],

                  const SizedBox(height: 16),

                  // 4) Password
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: _obscurePwd,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePwd
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePwd = !_obscurePwd),
                      ),
                    ),
                    validator: (v) {
                      if (v!.isEmpty)        return 'Enter password';
                      if (v.length < 6)      return 'Min 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 5) Submit
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Have an account? ',
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
