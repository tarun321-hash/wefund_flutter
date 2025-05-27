
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wefund/api/login.dart';

class ResetPassword {
  String? status;
  String? message;

  ResetPassword({this.status, this.message});

  ResetPassword.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;
bool _isPasswordVisible = false; // Track password visibility
  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

   try {
      final response = await http.post(
        Uri.parse('https://wefundclient.com/Crm/Crm/reset_password_api.php'),
        body: {
          'code': _codeController.text,
          'new_password': _newPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        try {
          final ResetPassword resetResponse =
              ResetPassword.fromJson(json.decode(response.body));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resetResponse.message ?? 'Password reset processed',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor:
                  resetResponse.status == 'success' ? Colors.green : Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          if (resetResponse.status == 'success') {
            await Future.delayed(Duration(seconds: 2));
            // Navigate to LoginScreen and remove all previous routes
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false, // This removes all previous routes
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid JSON payload'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color.fromARGB(255, 140, 159, 193), Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Reset Code',
                          labelStyle: TextStyle(color: Colors.deepPurple),
                          prefixIcon:
                              Icon(Icons.lock_outline, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: TextStyle(color: Colors.deepPurple),
                          prefixIcon:
                              Icon(Icons.vpn_key, color: Colors.deepPurple),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: !_isPasswordVisible, // Toggle visibility
                      ),
                      SizedBox(height: 30),
                      _isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            )
                          : ElevatedButton(
                              onPressed: _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}