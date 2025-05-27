import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wefund/BottomNavigationBar.dart';
import 'package:wefund/forgot_password.dart';
import 'package:wefund/api/singup.dart';
import 'package:wefund/Positions.dart';
import 'package:wefund/History.dart';


class Login {
  final bool success;
  final String message;

  Login({required this.success, required this.message});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Something went wrong',
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _obscureText  = true;
  bool _isLoading    = false;
  bool _rememberMe   = false;

  @override
  void initState() {
    super.initState();
    emailController    = TextEditingController();
    passwordController = TextEditingController();
    _bootstrap();       // <— load saved creds & maybe auto-navigate
  }

  /// Load "remember me" credentials and then check if
  /// the user is already logged in (regardless of remember).
  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Restore e-mail/password if they had asked us to "Remember Me"
    final savedRemember = prefs.getBool('rememberMe') ?? false;
    if (savedRemember) {
      emailController.text    = prefs.getString('email')    ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = true;
    }

    // 2) If they ever logged in before, send them right in.
    final already   = prefs.getBool('isLoggedIn') ?? false;
final storedJwt = prefs.getString('jwt');  // may be null

if (already && storedJwt != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BottomNavigationBarWidget(
          jwt: storedJwt,        // non‐null here
          initialIndex: 0,
        ),
      ),
    );
  });
}

  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    const loginUrl = "https://wefundclient.com/Crm/Crm/login_api.php";
    const balUrl   = "https://wefundclient.com/Crm/Crm/accbal_api.php";

    try {
      // 1) Perform login
      final loginResp = await http.post(
        Uri.parse(loginUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'app_password': passwordController.text.trim(),
        }),
      );

      final loginData = jsonDecode(loginResp.body) as Map<String, dynamic>;
      
      final success   = loginData['success'] == true;
      final message   = loginData['message'] ?? 'Unknown error';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (!success) {
        setState(() => _isLoading = false);
        return;
      }

      // 2) Persist login + “remember me”
      final jwt   = loginData['jwt'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', jwt);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email',    emailController.text.trim());
      await prefs.setString('password', passwordController.text.trim());
      await prefs.setBool('rememberMe', _rememberMe);

      // 3) Fetch that user’s accounts
      final balResp = await http.post(
        Uri.parse(balUrl),
        headers: { "Content-Type": "application/json" },
        body: jsonEncode({ "email": emailController.text.trim() }),
      );
      if (balResp.statusCode == 200) {
        final List<dynamic> accounts = jsonDecode(balResp.body);
        if (accounts.isNotEmpty) {
          final acct = accounts.first as Map<String, dynamic>;
          await prefs.setString('selectedAccountNumber',
              acct['account_number'].toString());
          await prefs.setString('selectedAccountAmount',
              acct['amount'].toString());
        }
      }

      // 4) Navigate into your main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BottomNavigationBarWidget(
            jwt: jwt,
            initialIndex: 4, // 0 = Trade tab (PositionsPage)
          ),
        ),
      );
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $err"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 80),
                    const SizedBox(height: 20),
                    const Text(
                      "Login to WEFUND",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Enter your email" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Enter your password";
                        }
                        if (v.length < 6) {
                          return "Password must be ≥ 6 chars";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ForgotPasswordFlowScreen()),
                        ),
                        child: const Text("Forgot Password?",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      title: const Text("Remember Me"),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 15),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 100),
                            ),
                            child: const Text("Log In",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SignupScreen()),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Not Registered yet?",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          SizedBox(width: 5),
                          Text("Sign up",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.blue)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
