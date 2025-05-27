// lib/funded_account_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FundedAccountPage extends StatefulWidget {
  const FundedAccountPage({Key? key}) : super(key: key);

  @override
  State<FundedAccountPage> createState() => _FundedAccountPageState();
}

class _FundedAccountPageState extends State<FundedAccountPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _account;
  String? _userEmail;
  String? _selectedAcct;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    setState(() {
      _loading = true;
      _error = null;
      _account = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final acct  = prefs.getString('selectedAccountNumber') ?? '';

    if (email.isEmpty || acct.isEmpty) {
      setState(() {
        _error = 'No logged‐in email or no account selected.';
        _loading = false;
      });
      return;
    }

    _userEmail    = email;
    _selectedAcct = acct;

    try {
      final resp = await http.post(
        Uri.parse('https://wefundclient.com/Crm/Crm/fund_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'account_number': acct,
        }),
      );

      if (resp.statusCode != 200) {
        throw Exception('Server error ${resp.statusCode}');
      }

      final body = jsonDecode(resp.body);
      if (body is List && body.isNotEmpty) {
        // fund_api returns an array with 0 or 1 elements
        setState(() {
          _account = body[0] as Map<String, dynamic>;
        });
      } else {
        setState(() {
          _error = 'No funded account found for $acct.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch funded account.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funded Account'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_userEmail != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome, $_userEmail',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          child: ListTile(
                            leading: const Icon(Icons.account_balance_wallet),
                            title: Text('Account No: ${_account!['account_number']}'),
                            subtitle: Text('Balance: ${_account!['amount']}'),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
