// lib/copytrading.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/account_provider.dart';
import 'package:wefund/copy_trading_form.dart';

class TradingAccount {
  final String traderName;
  final String traderType;

  TradingAccount({
    required this.traderName,
    required this.traderType,
  });

  factory TradingAccount.fromJson(Map<String, dynamic> json) {
    return TradingAccount(
      traderName: json['Trader Name'] as String,
      traderType: json['Trader Type'] as String,
    );
  }
}

class CopyTradingPage extends StatefulWidget {
  const CopyTradingPage({Key? key}) : super(key: key);

  @override
  _CopyTradingPageState createState() => _CopyTradingPageState();
}

class _CopyTradingPageState extends State<CopyTradingPage> {
  bool _loading = true;
  String? _error;
  List<TradingAccount> _accounts = [];
  String? _userEmail;
  String? _selectedAccountNumber;

  @override
  void initState() {
    super.initState();
    // load prefs & fetch in post-frame so Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndFetch());
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final acctNo = prefs.getString('selectedAccountNumber') ?? '';

    if (email.isEmpty || acctNo.isEmpty) {
      // if not logged in or no account selected, bail
      setState(() {
        _error = 'Please log in and select an account first.';
        _loading = false;
      });
      return;
    }

    setState(() {
      _userEmail = email;
      _selectedAccountNumber = acctNo;
      _loading = true;
      _error = null;
      _accounts = [];
    });

    try {
      final resp = await http.post(
        Uri.parse('https://wefundclient.com/Crm/Crm/Copytrading_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'account_number': acctNo,
        }),
      );

      if (resp.statusCode != 200) {
        throw Exception('Server returned ${resp.statusCode}');
      }

      final body = jsonDecode(resp.body);
      if (body is List) {
        _accounts = body
            .cast<Map<String, dynamic>>()
            .map((e) => TradingAccount.fromJson(e))
            .toList();
        if (_accounts.isEmpty) {
          _error = 'No copy-trading data for account $acctNo.';
        }
      } else if (body is Map && body['error'] != null) {
        _error = body['error'] as String;
      } else {
        _error = 'Unexpected response format.';
      }
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Copy Trading Accounts',
          style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        leading: BackButton(color: theme.isDarkMode ? Colors.white : Colors.black),
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
                  style: TextStyle(fontSize: 16.px, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _accounts.length,
                          itemBuilder: (context, index) {
                            final acct = _accounts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 3,
                              child: ListTile(
                                title: Text(acct.traderName),
                                subtitle: Text(acct.traderType),
                                trailing: ElevatedButton(
                                  child: const Text('Add'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CopyTradingForm(
                                          traderName: acct.traderName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
