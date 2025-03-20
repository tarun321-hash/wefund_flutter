import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';

class Account {
  final int userId;
  final String username;
  final String accountCategory;
  final String amount;
  final String platforms;
  final String accountName;

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
      userId: json['user_id'] ?? 0,
      username: json['Username'] ?? 'Unknown',
      accountCategory: json['Account Category'] ?? 'N/A',
      amount: json['Amount'] ?? '0',
      platforms: json['Platforms'] ?? 'N/A',
      accountName: json['Account Name'] ?? 'N/A',
    );
  }
}

class FundAccount extends StatefulWidget {
  const FundAccount({super.key});

  @override
  State<FundAccount> createState() => _FundAccountState();
}

class _FundAccountState extends State<FundAccount> {
  List<Account> accounts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  Future<void> fetchAccountData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://wefundclient.com/Crm/Crm/Id_api.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        if (jsonData.isNotEmpty) {
          setState(() {
            accounts = jsonData.map((data) => Account.fromJson(data)).toList();
          });
        } else {
          setState(() {
            errorMessage = "No data available";
          });
        }
      } else {
        throw Exception('Failed to load account data');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching data: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title:  Text('Account Details',style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,),
              centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), // iOS-style back arrow
            onPressed: () {
              Navigator.pop(context);
            },
          ),
            backgroundColor:
              themeProvider.isDarkMode ? Colors.black : Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : accounts.isNotEmpty
                  ? ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Account Name : ${account.accountName}",
                                  style:  TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp),
                                ),
                                Text(
                                  "amount: ${account.amount} Rs",
                                  style:  TextStyle(
                                      fontSize: 17.sp, color: Colors.green,  fontWeight: FontWeight.w500,),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              "User ID: ${account.userId}\n"
                              "Username: ${account.username}\n"
                              "Category: ${account.accountCategory}\n"
                              "Platform: ${account.platforms}",
                              style: TextStyle(fontSize: 16.sp,  fontWeight: FontWeight.w500,),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No accounts available")),
    );
  }
}
