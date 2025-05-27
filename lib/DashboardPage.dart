// lib/DashboardPage.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wefund/SettingsPage.dart';        // for the Client Portal tab
import 'package:wefund/copytrading.dart';         // CopyTradingPage
import 'package:wefund/pamm.dart';                // PAMMPage
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/account_provider.dart';    // your AccountProvider
import 'package:wefund/client_portal_page.dart'; 

class Dashboard {
  final String username;
  final String amount;
  final String accountStatus;

  Dashboard({
    required this.username,
    required this.amount,
    required this.accountStatus,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      username: json['username']?.toString() ?? 'N/A',
      amount: json['amount']?.toString() ?? '0.00',
      accountStatus: json['account_status']?.toString() ?? 'N/A',
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedTab = 'Copy Trading';
  Dashboard? dashboard;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Wait until AccountProvider has loaded the saved account:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadFromPrefs().then((_) {
        fetchDashboardData();
      });
    });
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // 1) get stored email
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isEmpty) {
      setState(() {
        errorMessage = 'No logged-in user found.';
        isLoading = false;
      });
      return;
    }

    // 2) get selected account
    final acctProv = context.read<AccountProvider>();
    final selected = acctProv.current;
    if (selected == null) {
      setState(() {
        errorMessage = 'No account selected.';
        isLoading = false;
      });
      return;
    }

    // 3) call your PHP API
    try {
      final resp = await http.post(
        Uri.parse('https://wefundclient.com/Crm/Crm/dashboard_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'account_number': selected.number,
        }),
      );

      if (resp.statusCode != 200) {
        throw Exception('Server error ${resp.statusCode}');
      }

      final decoded = json.decode(resp.body);

      Map<String, dynamic>? dataMap;
      if (decoded is List && decoded.isNotEmpty) {
        // array response → take first element
        dataMap = decoded.first as Map<String, dynamic>;
      } else if (decoded is Map<String, dynamic>) {
        // single-object response
        dataMap = decoded;
      }

      if (dataMap != null) {
        setState(() {
          dashboard = Dashboard.fromJson(dataMap!);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'No data returned for account ${selected.number}.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching dashboard: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: theme.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor:
            theme.isDarkMode ? Colors.black : Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                )
              : RefreshIndicator(
                  onRefresh: fetchDashboardData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: Text(
                          'Welcome WeFund',
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ACCOUNT STATUS CARD
                      if (dashboard != null) ...[
                        _buildAccountStatusCard(),
                        const SizedBox(height: 16),

                        // USER NAME
                        _buildInfoCard(
                            'User Name', dashboard!.username,
                            isBold: true),
                        const SizedBox(height: 16),

                        // BALANCE
                        _buildInfoCard(
                            'Balance', '\$ ${dashboard!.amount}'),
                        const SizedBox(height: 16),

                        // FREE MARGIN (static)
                        _buildInfoCard('Free Margin', '\$ 0.00'),
                        const SizedBox(height: 24),

                        // TABS
                        _buildTradingTabs(context),
                        const SizedBox(height: 24),

                        Center(
                          child: Text(
                            'No Users Found',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
    );
  }

  Widget _buildAccountStatusCard() {
    final status = dashboard!.accountStatus.toLowerCase();
    final color = (status == 'active')
        ? Colors.green
        : (status == 'inactive')
            ? Colors.red
            : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Status',
              style: TextStyle( fontSize: 18.sp)),
          const SizedBox(height: 8),
          Text(
            dashboard!.accountStatus,
            style: TextStyle(
                fontSize: 16.sp,
                color: Colors.green,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value,
      {bool isBold = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18.sp, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingTabs(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          _buildTabButton(context, 'Copy Trading', CopyTradingPage()),
          _buildTabButton(context, 'Client Portal', ClientPortalPage()),
          _buildTabButton(context, 'PAMM', PAMMPage()),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      BuildContext context, String title, Widget screen) {
    final active = (selectedTab == title);
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => selectedTab = title);
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.blue[100] : Colors.white,
            border: Border(
              bottom: BorderSide(
                  color: active ? Colors.orange : Colors.transparent,
                  width: 3),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 16.sp,
                  color: active ? Colors.orange : Colors.black,
                  fontWeight: active
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
          ),
        ),
      ),
    );
  }
}
