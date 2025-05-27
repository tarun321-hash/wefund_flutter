// lib/referral_history_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Model for a single referral record.
class ReferralRecord {
  final String date;
  final String username;
  final String email;
  final String category;
  final String accountName;
  final String referredAccountNumber;   // NEW
  final double amount;

  ReferralRecord({
    required this.date,
    required this.username,
    required this.email,
    required this.category,
    required this.accountName,
    required this.referredAccountNumber, // NEW
    required this.amount,
  });

  factory ReferralRecord.fromJson(Map<String, dynamic> json) {
    return ReferralRecord(
      date: json['created_at'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      category: json['accounts_category'] as String,
      accountName: json['account_name'] as String,
      referredAccountNumber: json['referred_account_number'] as String, // NEW
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
    );
  }
}

/// A page that displays your referral history in a vertical list of cards.
class ReferralHistoryPage extends StatefulWidget {
  const ReferralHistoryPage({Key? key}) : super(key: key);

  @override
  _ReferralHistoryPageState createState() => _ReferralHistoryPageState();
}

class _ReferralHistoryPageState extends State<ReferralHistoryPage> {
  late Future<List<ReferralRecord>> _historyFuture;
  static const _apiUrl =
      'https://wefundclient.com/Crm/Crm/referral_history_api.php';

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<List<ReferralRecord>> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final acct = prefs.getString('selectedAccountNumber') ?? '';
    if (email.isEmpty || acct.isEmpty) {
      throw Exception('Missing stored email or account number');
    }

    final resp = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'account_number': acct}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Server returned HTTP ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonResp = json.decode(resp.body);
    if (!jsonResp.containsKey('referralHistory')) {
      throw Exception('Malformed response: no referralHistory');
    }

    final raw = jsonResp['referralHistory'] as List<dynamic>;
    return raw
        .map((e) => ReferralRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Referred Clients'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<ReferralRecord>>(
        future: _historyFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No referrals yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final r = items[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            r.date,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name & referred account number
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 6),
                          Text(r.username, style: const TextStyle(fontSize: 16)),
                          const Spacer(),
                          const Icon(Icons.account_circle_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            r.referredAccountNumber, // show it here
                            style: const TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Email
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(r.email, style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Category
                      Row(
                        children: [
                          const Icon(Icons.category, size: 16),
                          const SizedBox(width: 6),
                          Text(r.category, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Account name
                      Row(
                        children: [
                          const Icon(Icons.home_work, size: 16),
                          const SizedBox(width: 6),
                          Text(r.accountName, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Amount
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '\$${r.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
