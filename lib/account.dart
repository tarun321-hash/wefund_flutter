import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Account {
  String? accountNumber;
  String? amount;

  Account({this.accountNumber, this.amount});

  Account.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number']?.toString() ?? 'N/A';
    amount = json['amount']?.toString() ?? 'N/A';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['account_number'] = accountNumber;
    data['amount'] = amount;
    return data;
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Account? account;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  Future<void> fetchAccountData() async {
    try {
      final response = await http.get(
        Uri.parse('https://wefundclient.com/Crm/Crm/accbal_api.php'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          account = Account.fromJson(jsonData);
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchAccountData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade100, Colors.white],
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                )
              : account != null && errorMessage == null
                  ? RefreshIndicator(
                      onRefresh: _refreshData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.account_balance,
                                    size: 60,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Account No: ${account!.accountNumber}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Balance: ${account!.amount}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage ?? 'Failed to load data',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _refreshData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
