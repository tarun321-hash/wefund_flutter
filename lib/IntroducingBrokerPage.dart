// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wefund/ThemeProvider.dart';

// class IntroducingBrokerPage extends StatelessWidget {
//   final String referralLink =
//       "https://trade.wefund.in/register/?ref=QHDNMD";
//   final String referralCode = "QHDNMD";
//   final double referralBonus = 25000.00;
//   final int referredAccounts = 34000;

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Introducing Broker",
//           style: TextStyle(
//             fontSize: 22.sp,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios), // iOS-style back arrow
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
//       ),
//       body: Padding(
//         padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 "Earn commissions with our Affiliate Program!",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 5.h),
//               Column(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                         color: Colors.blueAccent,
//                         borderRadius: BorderRadius.circular(50.sp)),
//                     height: 2.h,
//                     width: double.infinity,
//                   ),
//                   Container(
//                     height: 24.h,
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Your Referral Link",
//                           style: TextStyle(
//                             fontSize: 20.sp,
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                         SizedBox(height: 2.h),
//                         Container(
//                           height: 5.h,
//                           width: double.infinity,
//                           padding: EdgeInsets.symmetric(horizontal: 1.w),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[400],
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               referralLink,
//                               style: TextStyle(fontSize: 16.sp),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 2.h),
//                         ElevatedButton(
//                           onPressed: () {
//                             Clipboard.setData(ClipboardData(text: referralLink));
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Referral link copied!")),
//                             );
//                           },
//                           child: Text(
//                             "Copy",
//                             style: TextStyle(fontSize: 16.sp),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20.sp),
//                             ),
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 12.w, vertical: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 2.h),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 1.w),
//                 child: Container(
//                   height: 35.h,
//                   width: double.infinity,
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Color(0xffE0FFFF),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Your Referral Code",
//                         style: TextStyle(
//                             fontSize: 18.sp, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 1.h),
//                       Text(
//                         referralCode,
//                         style: TextStyle(fontSize: 16.sp),
//                       ),
//                       SizedBox(height: 1.h),
//                       Text(
//                         "Your Referral Bonus",
//                         style: TextStyle(
//                             fontSize: 18.sp, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 1.h),
//                       Text("\$ 25000",
//                           style: TextStyle(
//                               fontSize: 18.sp, fontWeight: FontWeight.normal)),
//                       SizedBox(height: 1.h),
//                       ElevatedButton(
//                         onPressed: () {},
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey,
//                         ),
//                         child: Text(
//                           "Withdraw",
//                           style: TextStyle(fontSize: 18.sp, color: Colors.white),
//                         ),
//                       ),
//                       SizedBox(height: 1.h),
//                       Text(
//                         "Referred Accounts",
//                         style: TextStyle(
//                             fontSize: 18.sp, fontWeight: FontWeight.bold),
//                       ),
//                       Text("\$ 34000",
//                           style: TextStyle(
//                               fontSize: 17.sp, fontWeight: FontWeight.normal)),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 2.h),
//            Container(
//   padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
//   margin: EdgeInsets.only(bottom: 10),
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(8),
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         "Referred User List",
//         style: TextStyle(
//           fontSize: 18.sp,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//         ),
//       ),
//       SizedBox(height: 1.h),
      
//       Table(
//         columnWidths: {
//           0: FlexColumnWidth(2),  // Adjusts column width for bonus title
//           1: FlexColumnWidth(1),  // Adjusts column width for amount
//         },
//         border: TableBorder.all(color: Colors.black26, width: 1), // Adds border
//         children: [
//           _buildTableRow("Joining Income", "\$3000"),
//           _buildTableRow("Multilevel Bonus (Level Income)", "\$3000"),
//           _buildTableRow("Matching Bonus", "\$3500"),
//           _buildTableRow("Rank and Reward", "\$4000"),
//           _buildTableRow("Deposit Bonus (CS)", "\$3000"),
//           _buildTableRow("Club Income", "\$3500"),
//           _buildTableRow("Trading Revenue Bonus (M)", "\$4000"),
//           _buildTableRow("Profit Share Bonus", "\$3000"),
//         ],
//       ),
//     ],
//   ),
// ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// TableRow _buildTableRow(String title, String amount) {
//   return TableRow(
//     children: [
//       Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Text(
//           title,
//           style: TextStyle(fontSize: 16.sp, color: Colors.black,fontWeight: FontWeight.w400, ),
//         ),
//       ),
//       Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Text(
//           amount,
//           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.blue),
//         ),
//       ),
//     ],
//   );
// }}




// lib/IntroducingBrokerPage.dart



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wefund/account_provider.dart';
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/referral_history_page.dart';

// parse numeric or numeric‐string
num? _parseNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

class IbDetail {
  final int userId;
  final String ibAccountNumber;
  final String accountType;
  final String currency;
  final double commission;

  IbDetail({
    required this.userId,
    required this.ibAccountNumber,
    required this.accountType,
    required this.currency,
    required this.commission,
  });

  factory IbDetail.fromJson(Map<String, dynamic> j) {
    return IbDetail(
      userId: j['user_id'] is int
          ? j['user_id'] as int
          : int.parse(j['user_id'].toString()),
      ibAccountNumber: j['ib_account_number'] as String? ?? '',
      accountType: j['ib_commission_account_type'] as String? ?? '',
      currency: j['currency'] as String? ?? '',
      commission: (_parseNum(j['ib_commission']) ?? 0).toDouble(),
    );
  }
}

class IntroducingBrokerPage extends StatefulWidget {
  const IntroducingBrokerPage({Key? key}) : super(key: key);

  @override
  _IntroducingBrokerPageState createState() => _IntroducingBrokerPageState();
}

class _IntroducingBrokerPageState extends State<IntroducingBrokerPage> {
  late Future<List<IbDetail>> _detailsFuture;

  final List<String> _allTypes = [
    'Joining Income',
    'Multilevel Bonus',
    'Matching Bonus',
    'Active users in Funded Overall',
    'Users in Live+ Copy trading',
    'Rank and Reward',
    'Deposit Bonus (CS)',
    'Club Income',
    'Trading Profit Bonus (M)',
    'Profit Share Bonus',
  ];

  @override
  void initState() {
    super.initState();
    _detailsFuture = _fetchIbDetails();
  }

  Future<List<IbDetail>> _fetchIbDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final acctNo = prefs.getString('selectedAccountNumber') ?? '';
    if (email.isEmpty || acctNo.isEmpty) {
      throw Exception('No email or no selectedAccountNumber');
    }
    final resp = await http.post(
      Uri.parse('https://wefundclient.com/Crm/Crm/ib_api.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'account_number': acctNo,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }
    final List<dynamic> list = json.decode(resp.body);
    return list.map((e) => IbDetail.fromJson(e)).toList();
  }

  void _copyClip(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Introducing Broker'),
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: theme.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: FutureBuilder<List<IbDetail>>(
        future: _detailsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final details = snap.data!;
          if (details.isEmpty) {
            return const Center(child: Text('No IB data for this account'));
          }

          final first = details.first;
          final userId = first.userId;
          final link = 'https://www.wefundedfx.com/register?ref=$userId';
          final code = userId.toString();

          // Map accountType → IbDetail
          final byType = {for (var d in details) d.accountType: d};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // IB Account Number
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your IB Account Number',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          first.ibAccountNumber,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Referral Link
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Your Referral Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(link),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                          onPressed: () => _copyClip(link),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Referral Code
                Card(
                  color: Colors.lightBlue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Your Referral Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          code,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                          onPressed: () => _copyClip(code),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

// ─── View Clients Button ──────────────────────────────────────
ElevatedButton.icon(
  icon: const Icon(Icons.people),
  label: const Text('View Clients'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white, // ← this makes both icon & text white
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: () {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ReferralHistoryPage(),
    ));
  },
),



                const SizedBox(height: 24),

                // IB Commissions Header
                const Text(
                  'Your IB Commissions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Commission Cards
                Column(
                  children: _allTypes.map((type) {
                    final detail = byType[type];
                    final amount = detail?.commission.toStringAsFixed(2) ?? '0.00';
                    final currency = detail?.currency ?? '';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: theme.isDarkMode
                                  ? Colors.tealAccent
                                  : Colors.teal,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$amount $currency',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyClip(amount),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
