import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FundsPage extends StatelessWidget {
  final String jwt;
  const FundsPage({Key? key, required this.jwt}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // FundsPage doesn't itself use `selectedMethod`, so no currency here
    final themeProvider = Provider.of<ThemeProvider>(context);
    


    return DefaultTabController(
      length: 2, // Ensure this matches the number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "FUNDS",
            style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), // iOS-style back arrow
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 16.px, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                TextStyle(fontSize: 16.px, fontWeight: FontWeight.normal),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.money, size: 20.sp),
                    SizedBox(width: 5),
                    Text("Deposit"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.money, size: 20.sp),
                    SizedBox(width: 5),
                    Text("Withdraw"),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor:
              themeProvider.isDarkMode ? Colors.black : Colors.white,
          iconTheme: IconThemeData(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            DepositPage(), // Deposit screen
            WithdrawPage(jwt: jwt),
          ],
        ),
      ),
    );
  }
}

class DepositPage extends StatefulWidget {
  const DepositPage({Key? key}) : super(key: key);
  @override
  _DepositPageState createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  String? _email, _accountNumber;
  File? trcScreenshot, bepScreenshot, upiScreenshot, bankScreenshot;                           // ← FIX1: separate File vars for each method
  final TextEditingController fullNameController    = TextEditingController();
  final TextEditingController depositAmountController = TextEditingController();
  // final TextEditingController bepAddressController   = TextEditingController();                // ← FIX2: BEP-20 address controller
  final picker = ImagePicker();

 final String trc20Address = "TJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv";
final String bep20Address = "0x70B1053B873028ed1Bd3411A4e0d43ED6E276B78";

  String selectedMethod = "USDT TRC - 20";

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _email         = prefs.getString('email')                ?? '';
        _accountNumber = prefs.getString('selectedAccountNumber') ?? '';
      });
    });
  }

  Future<File?> _pickScreenshot() async {                              // ← FIX3: generic picker that returns File
    if (!await Permission.photos.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Allow gallery access!")),
      );
      return null;
    }
    final x = await picker.pickImage(source: ImageSource.gallery);
    return x != null ? File(x.path) : null;
  }

  Future<void> _handleDeposit() async {
    final amtText = depositAmountController.text.trim();
    final depositValue = double.tryParse(amtText);
    if (depositValue == null || depositValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid deposit amount.")),
      );
      return;
    }

    // 2) assemble payload (pure data—no widgets here!)                            // ← FIX4: removed all buildTextField calls
    final payload = <String, dynamic>{
      "email": _email,
      "account_number": _accountNumber,
      "full_name": fullNameController.text.trim(),
      "method": selectedMethod,
      "amount": depositValue,
      "currency": (selectedMethod == "UPI" || selectedMethod == "Bank Transfer") ? "INR" : "USD",
      if (selectedMethod == "USDT TRC - 20")  
  "deposit_address": trc20Address,
if (selectedMethod == "USDT BEP - 20")  
  "deposit_address": bep20Address,

      if (selectedMethod == "UPI")           "upi_id": "wefu20@axisbank",
      if (selectedMethod == "Bank Transfer") ...{
        "bank_name": "Axis Bank",
        "bank_account_number": "924010025197811",
        "ifsc": "UTIB0000720",
        "branch": "",
        "attachment_path": bankScreenshot?.path ?? "",
      },
      "screenshot_path": selectedMethod.startsWith("USDT")
        ? (selectedMethod == "USDT TRC - 20" ? trcScreenshot?.path : bepScreenshot?.path) ?? ""
        : (selectedMethod == "UPI" ? upiScreenshot?.path : bankScreenshot?.path) ?? "",
    };

    final uri = Uri.parse('https://wefundclient.com/Crm/Crm/deposit_api.php');
    try {
      final resp = await http.post(uri, headers: {'Content-Type':'application/json'}, body: jsonEncode(payload));
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['status']=='ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deposit #${data['request_id']} submitted')),
        );
        fullNameController.clear();
        depositAmountController.clear();
        setState(() => selectedMethod = "USDT TRC - 20");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = (selectedMethod == "UPI" || selectedMethod == "Bank Transfer") ? "INR" : "USD";
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(13.sp),
            width: 42.h,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(10.sp),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 2)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Text(
    "Deposit",
    style: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.bold,
    ),
  ),
  SizedBox(height: 16.sp),

              // Payment Method Dropdown
              Align(alignment: Alignment.centerLeft, child: Text("Select Payment Method:", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700))),
              SizedBox(height: 5.sp),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5.sp)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMethod,
                    isExpanded: true,
                    onChanged: (v) => setState(() => selectedMethod = v!),
                    items: ["USDT TRC - 20", "USDT BEP - 20", "UPI", "Bank Transfer"]
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  ),
                ),
              ),

              // USDT QR & Upload screenshot (for both TRC & BEP)
              if (selectedMethod.startsWith("USDT")) ...[                                     // ← FIX5: use square brackets
                SizedBox(height: 2.h),
                Image.asset('assets/qr.jpeg', height: 20.h),
                SizedBox(height: 1.h),
                buildCopyAddressField(),
                                // separated out for clarity
                SizedBox(height: 1.h),
                uploadField("Upload Screenshot", () async {                                 // ← FIX6: unified upload widget
                  final f = await _pickScreenshot();
                  if (f != null) setState(() {
                    if (selectedMethod=="USDT TRC - 20") trcScreenshot = f;
                    else                               bepScreenshot = f;
                  });
                }, selectedMethod=="USDT TRC - 20" ? trcScreenshot : bepScreenshot),
              ],

              // Bank Transfer
              if (selectedMethod=="Bank Transfer") ...[
                SizedBox(height: 2.h),
                buildFixedTextField("Bank Name", "Axis Bank"),
                buildFixedTextField("Account Number", "924010025197811"),
                buildFixedTextField("IFSC Code", "UTIB0000720"),
                SizedBox(height: 1.h),
                uploadField("Upload Bank Proof", () async {                                // ← FIX7: bank screenshot
                  final f = await _pickScreenshot();
                  if (f != null) setState(() => bankScreenshot = f);
                }, bankScreenshot),
              ],

              // UPI
              if (selectedMethod=="UPI") ...[
                SizedBox(height: 2.h),
                Row(children:[
                  Text("UPI ID:", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  SizedBox(width: 2.w),
                  Expanded(child: SelectableText("wefu20@axisbank", style: TextStyle(fontSize: 16.sp))),
                  IconButton(icon: Icon(Icons.copy), onPressed: (){
                    Clipboard.setData(ClipboardData(text:"wefu20@axisbank"));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
                  })
                ]),
                SizedBox(height: 1.h),
                uploadField("Upload Screenshot", () async {                               // ← FIX8: UPI screenshot
                  final f = await _pickScreenshot();
                  if (f != null) setState(() => upiScreenshot = f);
                }, upiScreenshot),
              ],

              // Full name + Amount + Submit
              SizedBox(height: 2.h),
              buildTextField("Full Name", "Enter your name", fullNameController),
              SizedBox(height: 2.h),
              Align(alignment: Alignment.centerLeft, child: Text("Enter Amount ($currency)", style: TextStyle(fontSize:17.sp, fontWeight:FontWeight.bold))),
              SizedBox(height: 1.h),
              TextField(
                controller: depositAmountController,
                keyboardType: TextInputType.numberWithOptions(decimal:true),
                decoration: InputDecoration(
                  hintText: "Amount in $currency",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp)),
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
  onPressed: _handleDeposit,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    minimumSize: Size(double.infinity, 50),
  ),
  child: Text(
    "Deposit",
    style: TextStyle(color: Colors.white),
  ),
),

            ]),
          ),
        ),
      ),
    );
  }

  /// Renders the deposit address in a non-overflowing, selectable text field
/// with a blue “Copy” button on the right.
Widget buildCopyAddressField() {
  // choose the right address string:
  final address = selectedMethod == "USDT TRC - 20"
    ? trc20Address
    : bep20Address;

  return Container(
    margin: EdgeInsets.symmetric(vertical: 8.sp),
    padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.sp),
    ),
    child: Row(
      children: [
        Expanded(
          child: SelectableText(
            address,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            maxLines: 1,
           
          ),
        ),
        SizedBox(width: 8.sp),
        TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            padding:
                EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.sp),
            ),
          ),
          icon: Icon(Icons.copy, color: Colors.white, size: 16.sp),
          label: Text("Copy",
              style: TextStyle(color: Colors.white, fontSize: 14.sp)),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: address));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Address copied!")),
            );
          },
        ),
      ],
    ),
  );
}


  @override
void dispose() {
  fullNameController.dispose();
  depositAmountController.dispose();
  
  super.dispose();
}


  Widget uploadField(String label, VoidCallback onTap, File? file) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text(label, style: TextStyle(fontSize:14.sp, fontWeight: FontWeight.w700)),
      SizedBox(height:6.sp),
      GestureDetector(
        onTap: onTap,
        child: Container(
          height:15.h,
          width: double.infinity,
          decoration: BoxDecoration(border:Border.all(color:Colors.grey), borderRadius:BorderRadius.circular(8.sp)),
          child: file==null
            ? Center(child: Icon(Icons.cloud_upload, size:40, color:Colors.grey))
            : Image.file(file, fit: BoxFit.cover),
        ),
      ),
    ]);
  }

  Widget buildFixedTextField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical:6.sp),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text(label, style: TextStyle(fontSize:14.sp, fontWeight:FontWeight.w600)),
        SizedBox(height:4.sp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal:12.sp, vertical:14.sp),
          decoration: BoxDecoration(border:Border.all(color:Colors.grey), borderRadius:BorderRadius.circular(5.sp), color:Colors.grey[200]),
          child: Text(value, style: TextStyle(fontSize:14.sp)),
        ),
      ]),
    );
  }

  Widget buildTextField(String label, String hint, TextEditingController ctrl) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical:6.sp),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text(label, style: TextStyle(fontSize:14.sp, fontWeight:FontWeight.w600)),
        SizedBox(height:4.sp),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp)),
          ),
        ),
      ]),
    );
  }
}

class WithdrawPage extends StatefulWidget {
  final String jwt;
  const WithdrawPage({Key? key, required this.jwt}) : super(key: key);

  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  String selectedMethod = "UPI";
  int? _requestId;
  String _userEmail = '';  
  
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _otpSent     = false;
  bool _otpVerified = false;
  File? qrImage;
  final picker = ImagePicker();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountHolderController =
      TextEditingController();
  final TextEditingController accountNumberController =
      TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController upiController = TextEditingController();
  final TextEditingController trc20AddressController =
      TextEditingController();
    //  final TextEditingController bepAddressController   = TextEditingController();
  final TextEditingController exchangeNameController =
      TextEditingController();

    @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      final savedEmail = prefs.getString('email') ?? '';
      final savedAcct  = prefs.getString('selectedAccountNumber') ?? '';

      setState(() {
        _userEmail = savedEmail;
        _emailController.text = savedEmail;

        // **Pull in the account number** so SQL lookup will succeed
        accountNumberController.text = savedAcct;
      });
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => qrImage = File(pickedFile.path));
    }
  }

  Future<void> _handleWithdraw() async {
  // 1) validate form
  // if (!_formKey.currentState!.validate()) return;

  // 2) assemble payload
  final payload = <String, dynamic>{
    "email": _userEmail,
    "account_number": accountNumberController.text.trim(),
    "method": selectedMethod,
    "amount": double.parse(amountController.text.trim()),
    // currency matches what your PHP expects
    "currency": (selectedMethod == "UPI" || selectedMethod == "Bank Transfer") ? "INR" : "USD",
    "full_name": fullNameController.text.trim(),
    // only include the optional ones if non-empty:
    if (selectedMethod == "Bank Transfer") ...{
      "bank_name": bankNameController.text.trim(),
      "account_holder": accountHolderController.text.trim(),
      "withdraw_account_number": accountNumberController.text.trim(),
      "ifsc": ifscController.text.trim(),
      "branch": branchController.text.trim(),
    },
    if (selectedMethod == "UPI") ...{
      "upi_id": upiController.text.trim(),
      // you could upload the image separately if needed
    },
    if (selectedMethod == "TRC-20") ...{
      "trc20_address": trc20AddressController.text.trim(),
      "exchange_name": exchangeNameController.text.trim(),
    },
  };

  // 3) call the PHP API
  final uri = Uri.parse('https://wefundclient.com/Crm/Crm/withdraw_request_api.php');
  try {
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200 && data['status'] == 'ok') {
      final id = data['request_id'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal submitted! Request #$id')),
      );
      // optional: navigate away or clear form
        // ── Clear all fields & reset state ───────
  fullNameController.clear();
  amountController.clear();
  bankNameController.clear();
  accountHolderController.clear();
  accountNumberController.clear();
  ifscController.clear();
  branchController.clear();
  upiController.clear();
  trc20AddressController.clear();
  exchangeNameController.clear();
  setState(() {
    _otpSent = false;
    _otpVerified = false;
    selectedMethod = "UPI"; // or your default
  });
    } else {
      final msg = data['message'] ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $msg')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Network error: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    // 🔹 Pull withdrawCurrency out before widget tree:
    final withdrawCurrency =
        (selectedMethod == "UPI" || selectedMethod == "Bank Transfer")
            ? "INR"
            : "USD";

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 2),
              ],
            ),
            width: 42.h,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Withdrawal",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  TextFormField(
  controller: _emailController,
  readOnly: true,
  decoration: InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(),
  ),
),

SizedBox(height: 8),
  // ── Always-visible Full Name ─────────────
  buildTextField(
    "Full Name",
    "Enter Your Name",
    fullNameController,
    true
  ),

SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Select Withdrawal Method:",
                        style: TextStyle(
                            fontSize: 14.px,
                            color: Colors.black,
                            fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMethod,
                        isExpanded: true,
                        items: ["Bank Transfer", "UPI", "TRC-20", "BEP-20"]
                            .map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => selectedMethod = v!),
                      ),
                    ),
                  ),
                  SizedBox(height: 0.2.h),

                  if (selectedMethod == "Bank Transfer") ...[
                    buildTextField("Bank Name", "Enter Bank Name",
                        bankNameController, true),
                    buildTextField("Account Holder Name",
                        "Enter Account Holder Name", accountHolderController, true),
                    buildTextField("Account Number", "Enter Account Number",
                        accountNumberController, true),
                    buildTextField(
                        "IFSC CODE", "Enter IFSC Code", ifscController, true),
                    buildTextField(
                        "Branch", "Enter Branch", branchController, false),
                  ],

                  if (selectedMethod == "UPI") ...[
                    buildTextField(
                        "UPI Address", "Enter UPI ID", upiController, true),
                  
                  ],

                  if (selectedMethod == "TRC-20") ...[
                    buildTextField("TRC-20 Contract Address",
                        "Enter TRC-20 Address", trc20AddressController, true),
                    buildTextField("Withdrawal Exchange Name",
                        "Enter Exchange Name", exchangeNameController, false),
                  ],

                  if (selectedMethod == "BEP-20") ...[
  buildTextField("BEP-20 Address", "Enter your BEP-20 address", trc20AddressController, true),
  buildTextField("Exchange Name", "Enter exchange name (optional)", exchangeNameController, false),

],


                  // **Amount Input Field** uses withdrawCurrency
                  buildTextField(
                    "Enter Amount ($withdrawCurrency)",
                    "Enter amount in $withdrawCurrency",
                    amountController,
                    true,
                  ),

                  SizedBox(height: 1.h),

                  // Send OTP button
ElevatedButton(
  onPressed: _otpSent ? null : _sendOtp,
  child: Text(_otpSent ? 'OTP Sent' : 'Send OTP'),
),

SizedBox(height: 8),

// OTP entry + verify
if (_otpSent) ...[
  TextFormField(
    controller: _otpController,
    decoration: InputDecoration(
      labelText: 'Enter OTP',
      border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.number,
  ),
  SizedBox(height: 8),
  ElevatedButton(
    onPressed: _otpVerified ? null : _verifyOtp,
    child: Text(_otpVerified ? 'OTP Verified' : 'Verify OTP'),
  ),
  SizedBox(height: 16),
],
                  ElevatedButton(
                    onPressed: _otpVerified ? _handleWithdraw : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child:
                        Text("Withdraw", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hint,
      TextEditingController controller, bool isRequired) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "$label is required";
                    }
                    return null;
                  }
                : null,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp() async {
  final prefs = await SharedPreferences.getInstance();
  final jwt   = prefs.getString('jwt') ?? '';
  final email = prefs.getString('email') ?? '';

  final resp = await http.post(
    Uri.parse('https://wefundclient.com/Crm/Crm/send_otp.php'),
    headers: {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'email': email}),
  );

  final data = jsonDecode(resp.body);
  if (resp.statusCode==200 && data['status']=='ok') {
    setState(() {
      _otpSent   = true;
      _requestId = data['request_id'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP sent to $email')),
    );
  } else {
    final msg = data['message'] ?? 'Failed to send OTP';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

Future<void> _verifyOtp() async {
  if (_requestId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No OTP request to verify')),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final jwt   = prefs.getString('jwt') ?? '';

  final resp = await http.post(
    Uri.parse('https://wefundclient.com/Crm/Crm/verify_otp.php'),
    headers: {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'request_id': _requestId,
      'otp':        _otpController.text.trim(),
    }),
  );

  final data = jsonDecode(resp.body);
  if (resp.statusCode==200 && data['status']=='ok') {
    setState(() => _otpVerified = true);
    ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('OTP verified')));
  } else {
    final msg = data['message'] ?? 'Invalid OTP';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}




}
