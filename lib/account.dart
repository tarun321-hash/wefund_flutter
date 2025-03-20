import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Account {
  int userId;
  String username;
  String accountCategory;
  String amount;
  String platforms;
  String accountName;

  Account({
    required this.userId,
    required this.username,
    required this.accountCategory,
    required this.amount,
    required this.platforms,
    required this.accountName,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      userId: json['user_id'],
      username: json['Username'],
      accountCategory: json['Account Category'],
      amount: json['Amount'],
      platforms: json['Platforms'],
      accountName: json['Account Name'],
    );
  }
}

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Account? account;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  Future<void> fetchAccountData() async {
    final response = await http.get(
      Uri.parse('https://wefundclient.com/Crm/Crm/Id_api.php'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        account = Account.fromJson(jsonData);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load account data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Details')),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : account != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Ac No : ${account!.userId}",
                          style: TextStyle(fontSize: 16)),
                      Text("Balance : ${account!.amount}",
                          style: TextStyle(fontSize: 16)),
                    ],
                  )
                : Text("Failed to load data"),
      ),
    );
  }
}
