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



import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';

class Account {
  String? accountNumber;
  String? iBAccountNumber;
  String? iBCommission;
  String? currency;
  String? iBCommissionAccountType;

  Account(
      {this.accountNumber,
      this.iBAccountNumber,
      this.iBCommission,
      this.currency,
      this.iBCommissionAccountType});

  Account.fromJson(Map<String, dynamic> json) {
    accountNumber = json['Account Number'];
    iBAccountNumber = json['IB Account Number'];
    iBCommission = json['IB Commission'];
    currency = json['Currency'];
    iBCommissionAccountType = json['IB Commission Account Type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Account Number'] = this.accountNumber;
    data['IB Account Number'] = this.iBAccountNumber;
    data['IB Commission'] = this.iBCommission;
    data['Currency'] = this.currency;
    data['IB Commission Account Type'] = this.iBCommissionAccountType;
    return data;
  }
}

class IntroducingBrokerPage extends StatefulWidget {
  @override
  _IntroducingBrokerPageState createState() => _IntroducingBrokerPageState();
}

class _IntroducingBrokerPageState extends State<IntroducingBrokerPage> {
  final String referralLink = "https://trade.wefund.in/register/?ref=QHDNMD";
  final String referralCode = "QHDNMD";

  List<Map<String, String>> bonusList = [];

  @override
  void initState() {
    super.initState();
    fetchBonusData();
  }

 Future<void> fetchBonusData() async {
  try {
    final response = await http.get(Uri.parse("https://wefundclient.com/Crm/Crm/ib_api.php"));

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);

      // Ensure decodedData is a list, otherwise handle accordingly
      if (decodedData is List) {
        setState(() {
          bonusList = decodedData.map<Map<String, String>>((data) {
            return {
              "title": data["IB Commission Account Type"]?.toString() ?? "Unknown",
              "amount": "₹${data["IB Commission"]?.toString() ?? "0"}"
            };
          }).toList();
        });
      } else {
        throw Exception("API response is not a list.");
      }
    } else {
      throw Exception("Failed to load data. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching data: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Introducing Broker",
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      ),
      body: Padding(
         padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Earn commissions with our Affiliate Program!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),
  Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(50.sp)),
                    height: 2.h,
                    width: double.infinity,
                  ),
                  Container(
                    height: 24.h,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Your Referral Link",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          height: 5.h,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              referralLink,
                              style: TextStyle(fontSize: 16.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: referralLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Referral link copied!")),
                            );
                          },
                          child: Text(
                            "Copy",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.sp),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Container(
                  height: 35.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xffE0FFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Your Referral Code",
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        referralCode,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Your Referral Bonus",
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h),
                      Text("\$ 25000",
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.normal)),
                      SizedBox(height: 1.h),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: Text(
                          "Withdraw",
                          style: TextStyle(fontSize: 18.sp, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Referred Accounts",
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      Text("\$ 34000",
                          style: TextStyle(
                              fontSize: 17.sp, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ),
              // Referral Section
             // _buildReferralSection(),

              SizedBox(height: 2.h),

              // Bonus Table
              _buildBonusTable(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildReferralSection() {
  //   return Column(
  //     children: [
  //       Container(
  //         height: 24.h,
  //         padding: EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Text(
  //               "Your Referral Link",
  //               style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),
  //             ),
  //             SizedBox(height: 2.h),
  //             Container(
  //               height: 5.h,
  //               width: double.infinity,
  //               padding: EdgeInsets.symmetric(horizontal: 1.w),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[400],
  //                 borderRadius: BorderRadius.circular(5),
  //               ),
  //               child: Align(
  //                 alignment: Alignment.centerLeft,
  //                 child: Text(
  //                   referralLink,
  //                   style: TextStyle(fontSize: 16.sp),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 2.h),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Clipboard.setData(ClipboardData(text: referralLink));
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text("Referral link copied!")),
  //                 );
  //               },
  //               child: Text("Copy", style: TextStyle(fontSize: 16.sp)),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.blue,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(20.sp),
  //                 ),
  //                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildBonusTable() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Referred User List",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 1.h),

          // Table with dynamic data
          Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            border: TableBorder.all(color: Colors.black26, width: 1),
            children: bonusList.isNotEmpty
                ? bonusList.map((bonus) => _buildTableRow(bonus["title"]!, bonus["amount"]!)).toList()
                : [_buildTableRow("Loading...", "Please wait")],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, String amount) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            amount,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
