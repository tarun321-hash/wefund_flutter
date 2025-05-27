import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefund/BottomNavigationBar.dart';
import 'package:wefund/DashboardPage.dart';
import 'package:wefund/IntroducingBrokerPage.dart';
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/copytrading.dart';
import 'package:wefund/funded_account_page.dart';
import 'package:wefund/fundspage.dart';
import 'package:wefund/pamm.dart';
import 'package:wefund/setting.dart';
import 'package:wefund/client_portal_page.dart';
import 'package:wefund/account_provider.dart';
import 'package:wefund/api/login.dart';

import 'package:shared_preferences/shared_preferences.dart';


class Account {
  int? userId;
  String? accountNumber;
  String? amount;

  Account({this.userId, this.accountNumber, this.amount});

  Account.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] != null
        ? int.tryParse(json['user_id'].toString())
        : null;
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

class SettingsPage extends StatefulWidget {
  SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Account? account;
    // ── live P&L fields ─────────────────────────────
  bool _liveLoading    = true;
  String? _liveError;
  double _liveBalance  = 0.0;
  // double _liveEquity   = 0.0;
  // double _liveFreeMargin = 0.0;

  bool isLoading = true;
  String errorMessage = '';

    @override
void initState() {
  super.initState();
  // load which account was selected
  context.read<AccountProvider>().loadFromPrefs();
  // 1) your old account‐list loader
  fetchAccountData().then((_) {
    // 2) then hit the live‐balance API
    _fetchLiveBalance();
  });
}

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // if your account selection can change, re-fetch live PnL
  //    _fetchLiveBalance();
  // }

  Future<void> _fetchLiveBalance() async {
  setState(() {
    _liveLoading = true;
    _liveError   = null;
  });

  try {
    final prefs  = await SharedPreferences.getInstance();
    final jwt    = prefs.getString('jwt') ?? '';
    final userId = prefs.getInt('selectedUserId');
    if (userId == null) throw Exception('No account selected');

    final resp = await http.post(
      Uri.parse('https://wefundclient.com/Crm/Crm/sync_balance.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({ 'userId': userId }),
    );

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final Map<String, dynamic> result = jsonDecode(resp.body);
    if (result['status'] != 'ok') {
      throw Exception(result['message'] ?? 'Unknown sync error');
    }

    setState(() {
      _liveBalance = (result['balance'] as num).toDouble();
      _liveLoading = false;
    });
  } catch (e) {
    setState(() {
      _liveError   = e.toString();
      _liveLoading = false;
    });
  }
}



  // Future<void> fetchAccountData() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('https://wefundclient.com/Crm/Crm/accbal_api.php'),
  //     );

  //     if (response.statusCode == 200) {
  //       final jsonData = json.decode(response.body);
  //       setState(() {
  //         account = Account.fromJson(jsonData);
  //         isLoading = false;
  //         errorMessage = '';
  //       });
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //         errorMessage = 'Server error: ${response.statusCode}';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       errorMessage = 'Error: $e';
  //     });
  //   }
  // }


    



  Future<void> fetchAccountData() async {
  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
   // 1) read saved email
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final selectedAcct = prefs.getString('selectedAccountNumber');
      if (email.isEmpty) {
        setState(() {
          errorMessage = 'No logged-in email found.';
          isLoading = false;
        });
        return;
      }

      // 2) call POST /accbal_api.php
      final response = await http.post(
        Uri.parse('https://wefundclient.com/Crm/Crm/accbal_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
    );

    // 3) handle response
    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) {
      throw Exception('No account data returned');
    }

    // pick the user‐chosen account, or default to the first
    final Map<String, dynamic> chosen = (selectedAcct != null && selectedAcct.isNotEmpty)
      ? data.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['account_number']?.toString() == selectedAcct,
          orElse: () => data.first as Map<String, dynamic>,
        )
      : data.first as Map<String, dynamic>;

    setState(() {
      account   = Account.fromJson(chosen);
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      errorMessage = 'Error: $e';
      isLoading    = false;
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
    final acctProv = context.watch<AccountProvider>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    // ── NEW: turn your stored String into a double (or fallback to the raw string) ──
    final raw = acctProv.current?.balance ?? '0';
final storedBalanceText = double.tryParse(raw) != null
    ? double.parse(raw).toStringAsFixed(2)
    : raw;

    final List<Map<String, dynamic>> settingsOptions = [
      {
        'icon': Icons.explore,
        'text': 'Dashboard',
        'color': Colors.green,
        'page': DashboardPage()
      },
      {
        'icon': Icons.groups,
        'text': 'Introducing Broker',
        'color': Colors.blue,
        'page': IntroducingBrokerPage()
      },
      {
        'icon': Icons.attach_money,
        'text': 'Funds',
        'color': Colors.amber,
        'isFunds': true,
        'page': SizedBox(),
      },
      // {'divider': true},
      {
        'icon': 'assets/crown.png', // Path to image
        'text': 'Copy Trading',
        'color': Colors.green,
        'page': CopyTradingPage(),
      },
      {
        'icon': 'assets/c.png', // Path to image
        'text': 'PAMM',
        'color': Colors.yellow,
        'page': PAMMPage()
      },
      {
        'icon': Icons.person,
        'text': 'Client Portal',
        'color': Colors.blue,
        'page': ClientPortalPage(),
      },
      {
        'icon': Icons.account_balance_wallet,
        'text': 'Funded Account',
        'color': Colors.blue,
        'page': FundedAccountPage(),
      },
      // {'divider': true},
      {
        'icon': Icons.settings,
        'text': 'Settings',
        'color': Colors.green,
        'page': SettingsDetailsPage()
      },
      {
        'icon': Icons.question_mark,
        'text': 'Support',
        'color': Colors.yellow,
        'page': SupportPage()
      },
      {'themeToggle': true},
      {
        'icon': Icons.sync,
        'text': 'Update Available',
        'badge': true,
        'color': Colors.blue,
        'page': UpdatePage()
      },
      {
        'icon': 'assets/s.png', // Path to image
        'text': 'Privacy Policy',
        'color': Colors.blue,
        'page': PrivacyPolicyPage()
      },
      {
        'icon': 'assets/line.png', // Path to image
        'text': 'Delete Account',
        'color': Colors.red,
        'isDelete': true,
      },
      {
        'icon': Icons.logout,
        'text': 'Logout',
        'color': Colors.red,
        'isLogout': true,
      },
    ];

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
      ? Colors.black
      : Colors.white,              // ← add this line
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 22.px,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Column(
        children: [
          Column(
            children: [
              Image.asset(
                "assets/logo.png",
                scale: 9.sp,
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AartiCapitalDetailsPage()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Text("WEFUNDEDFX",
                              style: TextStyle(
                                  fontSize: 16.px,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AartiCapitalDetailsPage()));
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18.px,
                        color: Colors.grey,
                      )),
                  SizedBox(width: 6.w),
                ],
              ),
              SizedBox(height: 1.h),

Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Column(
    children: [
      // 1) Account number
      Text(
        'Ac No : ${acctProv.current?.number ?? '–'}',
        style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal
        ),
      ),

      const SizedBox(height: 4),

      // 2) Balance (fall back to storedBalanceText on error)
      Text(
        'Balance : \$${_liveLoading || _liveError != null 
            ? storedBalanceText 
            : _liveBalance.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          // show teal if live succeeded, grey if loading, orange if error
          color: _liveLoading
            ? Colors.grey
            : (_liveError != null ? Colors.orange : Colors.teal),
        ),
      ),
    ],
  ),
),




            ],
          ),


          Expanded(
            child: ListView.builder(
              itemCount: settingsOptions.length,
              itemBuilder: (context, index) {
                var item = settingsOptions[index];

                if (item.containsKey('divider')) {
                  return Divider(
                    thickness: 0.w,
                    color: themeProvider.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[300],
                  );
                }

                if (item.containsKey('themeToggle')) {
                  return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4), // Adjust padding

                      leading: Container(
                        width: 40, // Adjust as needed
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red, // Background color
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              8.0), // Adjust padding if needed
                          child: Image.asset(
                            'assets/contrast.png', // Asset image
                            fit: BoxFit.contain,
                            color: Colors.white, // Make image white
                          ),
                        ),
                      ),
                      title: Text("Default Theme"),
                      trailing: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.grey.shade300), // Add light border
                        ),
                        child: ToggleButtons(
                          borderColor: Colors.transparent,
                          selectedBorderColor: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(10),
                          isSelected: [
                            !themeProvider.isDarkMode,
                            themeProvider.isDarkMode
                          ],
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child:
                                  Text("Light", style: TextStyle(fontSize: 14)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child:
                                  Text("Dark", style: TextStyle(fontSize: 14)),
                            ),
                          ],
                          onPressed: (index) {
                            themeProvider.toggleTheme(
                                index == 1); // Set dark mode if index is 1
                          },
                        ),
                      ));
                }

                return ListTile(
  contentPadding: EdgeInsets.symmetric(horizontal: 17, vertical: 7),
  visualDensity: VisualDensity.compact,
  tileColor: Colors.transparent,
  shape: Border(
    bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
  ),
  leading: Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: item['color'],
      borderRadius: BorderRadius.circular(8),
    ),
    child: item['icon'] is String
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(item['icon'], fit: BoxFit.contain, color: Colors.white),
          )
        : Icon(item['icon'], color: Colors.white, size: 24),
  ),
  title: Text(item['text'], style: TextStyle(fontSize: 18.px)),
  trailing: Icon(Icons.arrow_forward_ios, size: 16.px, color: Colors.grey),
  onTap: () async {
  if (item['isDelete'] == true) {
    _showDeleteConfirmationDialog(context);
  } else if (item['isLogout'] == true) {
    _showLogoutDialog(context);
  } else if (item['isFunds'] == true) {
    // load the saved JWT:
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt') ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FundsPage(jwt: jwt)),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => item['page']),
    );
  }
},

);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Loads the account the user tapped, if any, from SharedPreferences.
Future<void> _loadSelectedAccount() async {
  final prefs = await SharedPreferences.getInstance();
  final no  = prefs.getString('selectedAccountNumber');
  final amt = prefs.getString('selectedAccountAmount');
  if (no != null && no.isNotEmpty) {
    setState(() {
      account   = Account(accountNumber: no, amount: amt);
      isLoading = false;
    });
  }
}


  void _showDeleteConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Delete Account"),
        content: Text("Do you wish to request deletion of this account?"),
        actions: [
          TextButton(
            child: Text("CANCEL"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("CONFIRM"),
            onPressed: () async {
              Navigator.of(context).pop(); // close dialog

              // 1) Grab current account info
              final prefs = await SharedPreferences.getInstance();
              final acctNo = prefs.getString('selectedAccountNumber') ?? 'N/A';
              final email  = prefs.getString('email') ?? 'N/A';

              // 2) Show confirmation snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(
                  "Delete request sent. We'll contact you soon."
                )),
              );

              // 3) Launch mailto: with prefilled body
              final subject = Uri.encodeComponent("Account Deletion Request");
              final body = Uri.encodeComponent(
                "Hello WeFund Team,\n\n"
                "Please delete the following account per my request:\n\n"
                "• Account Number: $acctNo\n"
                "• Registered Email: $email\n\n"
                "Thank you."
              );
              final uri = Uri.parse("mailto:support@wefundglobalfx.com"
                  "?subject=$subject&body=$body");
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ],
      );
    },
  );
}


void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Logout Alert"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            child: Text("CANCEL"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("EXIT"),
            onPressed: () async {
              // 1) Only clear the login/session keys, leave your "rememberMe" and credentials intact
              final prefs = await SharedPreferences.getInstance();

              await prefs.remove('isLoggedIn');
              await prefs.remove('selectedAccountNumber');
              await prefs.remove('selectedAccountAmount');

              // 2) Navigate back to the login screen (removing all other routes)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}

}

// class MAMPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("MAM")),
//       body: Center(child: Text("MAM Page")),
//     );
//   }
// }

// class ClientPortalPage extends StatelessWidget {
//   const ClientPortalPage({super.key});

//   Future<void> _launchURL() async {
//     final Uri uri = Uri.parse('https://www.wefundglobalfx.com/copy-traders');

//     if (await canLaunchUrl(uri)) {
//       await launchUrl(
//         uri,
//         mode: LaunchMode.externalApplication, // Open in browser
//       );
//     } else {
//       debugPrint("Could not open the link: $uri");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Client Portal",
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
//           textAlign: TextAlign.center,
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios), // iOS-style back arrow
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Profile Image
//               Container(
//                 height: 20.h,
//                 width: 40.w,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   image: DecorationImage(
//                     image: AssetImage("assets/1.png"), // Ensure image exists
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 3.h), // Space between image and button

//               // Create Account Button
//               ElevatedButton(
//                 onPressed: _launchURL,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   "Create Account",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Dummy Next Page
class NextPage extends StatefulWidget {
  const NextPage({
    super.key,
  });

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus(); // Hide keyboard

      // Navigate to the next screen after 1 second
onPressed: () async {
      final prefs = await SharedPreferences.getInstance();
  final jwt   = prefs.getString('jwt') ?? '';

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => BottomNavigationBarWidget(
        jwt: jwt,
        initialIndex: 4,
      ),
    ),
    (route) => false,
  );
};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Login Page",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 80),
                  SizedBox(height: 20),
                  Text("Login to WEFUND",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.blue),
                      labelText: "Email or Account ID",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),

                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      } else if (value.length < 6) {
                        return "Password must be at least 6 characters long";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),

                  // Login Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 100),
                    ),
                    onPressed: _login,
                    child: Text("Log In",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  SizedBox(height: 10),

                  // Sign Up Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Not Registered yet?",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        SizedBox(width: 5),
                        Text("Sign up",
                            style: TextStyle(fontSize: 18, color: Colors.blue))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
  });

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void _signup() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      onPressed: () async {
      final prefs = await SharedPreferences.getInstance();
  final jwt   = prefs.getString('jwt') ?? '';

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => BottomNavigationBarWidget(
        jwt: jwt,
        initialIndex: 4,
      ),
    ),
    (route) => false,
  );
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 80),
                  SizedBox(height: 20),
                  Text("Sign Up to WEFUND",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter your full name";
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.blue),
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.blue),
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) return "Enter your phone number";
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 100),
                    ),
                    onPressed: _signup,
                    child: Text("Sign Up",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Get.off(() => NextPage());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                        SizedBox(width: 5),
                        Text("Sign In",
                            style: TextStyle(fontSize: 18, color: Colors.blue))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Replace your old SupportPage with this:

// lib/SettingsPage.dart (or wherever your SupportPage lives)


class SupportPage extends StatelessWidget {
  static const _telegramUsername = 'wefundsupport';
  static const _supportEmail = 'support@wefundedfx.com';

  Future<void> _openTelegram(BuildContext context) async {
    final telegramUri = Uri.parse('tg://resolve?domain=$_telegramUsername');
    final webUri = Uri.parse('https://t.me/$_telegramUsername');

    // Try opening in Telegram app
    try {
      await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
      return;
    } catch (_) {
      // Native Telegram failed, fall through to web
    }

    // Fallback: open in browser
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    } catch (_) {
      // both failed
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Telegram.')),
    );
  }

  Future<void> _sendEmail(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      // you can add default subject/body here:
      // query: 'subject=Support Request&body=Hello, ...'
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email client.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        centerTitle: true,
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: theme.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Telegram Support Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.telegram,
                        size: 72,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Need help? Chat with us on Telegram",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _openTelegram(context),
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: Text(
                          "@$_telegramUsername",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Email Support Card
              SizedBox(
  width: double.infinity,                   // ← forces full width
  child: Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.email,
                        size: 72,
                        color: theme.isDarkMode
                            ? Colors.orangeAccent
                            : Colors.deepOrange,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Prefer email? Reach us at",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _supportEmail,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _sendEmail(context),
                        icon: const Icon(Icons.mail_outline, color: Colors.white),
                        label: const Text(
                          "Email Support",
                          style:
                              TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class UpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Available",
          style: TextStyle(
            fontSize: 22.px,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // iOS-style back arrow
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          height: 30.h,
          width: double.infinity,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo.png", // Replace with your logo path
                height: 100,
              ),
              SizedBox(height: 2.h),
              Text(
                "Version 1.0.0",
                style: TextStyle(fontSize: 18.px, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              Text(
                "Update Available Please Update Your\nAarti Capitals Application",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Privacy Policy",
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This privacy policy",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1.h),
              Text(
                "**Information Collection and Use**\n\n"
                "The Application collects information when you download and use it. This information may include: \n"
                "- Your device's IP address\n"
                "- The pages of the Application you visit, the time and date of your visit, and time spent on pages\n"
                "- The operating system you use\n"
                "- The Application does not gather precise location information\n\n"
                "**Third Party Access**\n\n"
                "Aggregated, anonymized data is periodically transmitted to external services to improve the app and service.\n"
                "The app uses third-party services with their own privacy policies: \n"
                "- [Google Play Services](https://www.google.com/policies/privacy/)\n\n"
                "**Opt-Out Rights**\n\n"
                "You can stop all collection of information by uninstalling the app.\n\n"
                "**Data Retention Policy**\n\n"
                "User data is retained as long as you use the app. To request data deletion, email WEFUND@gmail.com.\n\n"
                "**Children**\n\n"
                "The app does not knowingly collect data from children under 13. If you discover such data, contact WEFUND@gmail.com.\n\n"
                "**Security**\n\n"
                "The Service Provider implements safeguards to protect your information.\n\n"
                "**Changes**\n\n"
                "This Privacy Policy may be updated periodically. Continued use of the app implies consent to the updated policy.\n\n"
                "**Contact Us**\n\n"
                "For questions, contact WEFUND@gmail.com.\n\n"
                "*Privacy Policy effective as of 2025-02-24.*",
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class AartiCapitalDetailsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     // Sample data for accounts
//     final List<Map<String, String>> accounts = [
//       {"accountNo": "10009", "balance": "0.00"},
//       {"accountNo": "10011", "balance": "0.00"},
//       {"accountNo": "10010", "balance": "9999.60"},
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Account List",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
//         iconTheme: IconThemeData(
//             color: themeProvider.isDarkMode ? Colors.white : Colors.black),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Text(
//               "Welcome WeFundedFX",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: accounts.length,
//                 itemBuilder: (context, index) {
//                   final account = accounts[index];
//                   return Card(
//                     elevation: 2,
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: Colors.green,
//                         child: Icon(Icons.person, color: Colors.white),
//                       ),
//                       title: Text(
//                         "Account No : ${account['accountNo']}",
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text("Balance : ${account['balance']}"),
//                       trailing: const Icon(Icons.arrow_forward_ios),
//                       onTap: () {
//                         // Handle on tap
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class AartiCapitalDetailsPage extends StatefulWidget {
  const AartiCapitalDetailsPage({Key? key}) : super(key: key);

  @override
  _AartiCapitalDetailsPageState createState() => _AartiCapitalDetailsPageState();
}

class _AartiCapitalDetailsPageState extends State<AartiCapitalDetailsPage> {
  List<Account> accounts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  try {
    // 1) get saved email
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isEmpty) {
      setState(() {
        errorMessage = "No user email found.";
        isLoading = false;
      });
      return;
    }

    // 2) POST to accbal_api.php
    final response = await http.post(
      Uri.parse('https://wefundclient.com/Crm/Crm/accbal_api.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final List<dynamic> raw = json.decode(response.body);
    if (raw.isEmpty) {
      throw Exception('No accounts returned for $email');
    }

    // 3) Map into model
    final fetched = raw
        .cast<Map<String, dynamic>>()
        .map((e) => Account.fromJson(e))
        .toList();

    // 4) Auto-select the very first one if none chosen yet
    final selectedAcct = prefs.getString('selectedAccountNumber') ?? '';
    if (selectedAcct.isEmpty) {
  final first = fetched.first;
  await Provider.of<AccountProvider>(context, listen: false)
      .select(first.accountNumber!, first.amount!);
  await prefs.setString('selectedAccountNumber', first.accountNumber!);
  await prefs.setString('selectedAccountAmount', first.amount!);
  await prefs.setInt('selectedUserId', first.userId!);
    }

    // 5) Update local state
    setState(() {
      accounts = fetched;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      errorMessage = "Error fetching accounts: $e";
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account List",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor:
            themeProvider.isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : (errorMessage != null
                ? Center(child: Text(errorMessage!))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome WeFundedFX",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: accounts.length,
                          itemBuilder: (context, index) {
                            final acc = accounts[index];
                            return Card(
                              elevation: 2,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.person,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  "Account No : ${acc.accountNumber}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    Text("Balance : \$${acc.amount}"),
                                trailing: const Icon(
                                    Icons.arrow_forward_ios),
                                onTap: () async {
  // 1) update your AccountProvider
  Provider.of<AccountProvider>(context, listen: false)
      .select(acc.accountNumber!, acc.amount!);

  // 2) save the user_id and account_number into prefs
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedAccountNumber', acc.accountNumber!);
  await prefs.setString('selectedAccountAmount', acc.amount!);
  if (acc.userId != null) {
    await prefs.setInt('selectedUserId', acc.userId!);
  }

  // 3) navigate to the SettingsPage, replacing this page
 
  final jwt   = prefs.getString('jwt') ?? '';
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => BottomNavigationBarWidget(
        jwt: jwt,
        initialIndex: 4,  // the index of your Settings tab
      ),
    ),
    (route) => false,
  );
},


                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }
}