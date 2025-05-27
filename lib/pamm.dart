// lib/pamm.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/account_provider.dart';

/// Model for a single PAMM entry
class Pamm {
  final String traderName;
  final String traderType;

  Pamm({
    required this.traderName,
    required this.traderType,
  });

  factory Pamm.fromJson(Map<String, dynamic> json) {
    return Pamm(
      traderName: json['Trader Name']?.toString() ?? 'N/A',
      traderType: json['Trader Type']?.toString() ?? 'N/A',
    );
  }
}

/// The PAMMPage displays a list of the current user’s PAMM accounts
class PAMMPage extends StatefulWidget {
  const PAMMPage({Key? key}) : super(key: key);

  @override
  _PAMMPageState createState() => _PAMMPageState();
}

class _PAMMPageState extends State<PAMMPage> {
  List<Pamm> _accounts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userEmail;
  String? _selectedAccountNumber;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    // 1) Load saved email
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isEmpty) {
      // not logged in, redirect to login
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    // 2) Load selected account number from your AccountProvider
    final acctProv = context.read<AccountProvider>();
    await acctProv.loadFromPrefs(); // ensure it has loaded from SharedPreferences
    final acctNo = acctProv.current?.number;
    if (acctNo == null || acctNo.isEmpty) {
      setState(() {
        _errorMessage = 'No account selected.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _userEmail = email;
      _selectedAccountNumber = acctNo;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 3) POST both email and account_number
      final response = await http.post(
        Uri.parse('https://wefundclient.com/Crm/Crm/pammtrading_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'account_number': acctNo,
        }),
      );

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
        return;
      }

      final body = jsonDecode(response.body);
      if (body is List) {
        _accounts = body
            .cast<Map<String, dynamic>>()
            .map((e) => Pamm.fromJson(e))
            .toList();
        setState(() {
          _isLoading = false;
        });
      } else if (body is Map && body['error'] != null) {
        setState(() {
          _errorMessage = body['error'].toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No PAMM data for account $acctNo.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PAMM Accounts',
          style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading:
            BackButton(color: theme.isDarkMode ? Colors.white : Colors.black),
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_userEmail != null && _selectedAccountNumber != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'User: $_userEmail\nAccount: $_selectedAccountNumber',
                  style:
                      TextStyle(fontSize: 14.px, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style:
                                TextStyle(fontSize: 16.sp, color: Colors.red),
                          ),
                        )
                      : _buildAccountList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList() {
    if (_accounts.isEmpty) {
      return Center(
        child: Text(
          'No PAMM accounts found.',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.builder(
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final p = _accounts[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          child: ListTile(
            title: Text(
              p.traderName,
              style:
                  TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              p.traderType,
              style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
            ),
          ),
        );
      },
    );
  }
}
