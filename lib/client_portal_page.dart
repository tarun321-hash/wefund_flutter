// lib/client_portal_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wefund/funded_account_form.dart';
import 'package:wefund/copy_trading_form.dart';
import 'package:wefund/live_account_form.dart';

class ClientPortalPage extends StatefulWidget {
  const ClientPortalPage({Key? key}) : super(key: key);

  @override
  _ClientPortalPageState createState() => _ClientPortalPageState();
}

class _ClientPortalPageState extends State<ClientPortalPage> {
  bool _checkingLogin = true;

  @override
  void initState() {
    super.initState();
    _verifyLogin();
  }

  Future<void> _verifyLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null || email.isEmpty) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    setState(() => _checkingLogin = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Portal',
            style: TextStyle(fontFamily: 'FredokaOne')),
        leading: BackButton(),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFFAF8FE),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            CircleAvatar(
              radius: 0,
              backgroundImage: AssetImage('assets/logo.png'),
            ),
            const SizedBox(height: 32),
            _buildFormButton(
              label: 'Create New Funded Account',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FundedAccountForm()),
              ),
            ),
            const SizedBox(height: 16),
            _buildFormButton(
              label: 'Create New Copy Trading',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CopyTradingForm(traderName: '')),

              ),
            ),
            const SizedBox(height: 16),
            _buildFormButton(
              label: 'Create New Live Account',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LiveAccountForm()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'FredokaOne',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
