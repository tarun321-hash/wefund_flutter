import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';

class FundsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            labelColor: Colors.deepOrange, // Selected tab text & icon color
            unselectedLabelColor:
                Colors.grey, // Unselected tab text & icon color
            labelStyle: TextStyle(
              fontSize: 16.px,
              fontWeight: FontWeight.bold,
            ), // Selected tab text style
            unselectedLabelStyle: TextStyle(
              fontSize: 16.px,
              fontWeight: FontWeight.normal,
            ), // Unselected tab text style
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.money,
                        size:
                            20.sp), // Icon color will be handled automatically
                    SizedBox(width: 5),
                    Text("Deposit"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.money,
                        size:
                            20.sp), // Icon color will be handled automatically
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
            WithdrawPage(), // Withdraw screen
          ],
        ),
      ),
    );
  }
}

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  String depositAddress = "TJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv";
  String selectedMethod = "USDT TRC - 20";
  String? uploadedImagePath; File? qrImage; // Stores selected QR Code Image
  File? uploadedBankImage; // Stores selected Bank Transfer Image
  final picker = ImagePicker();
  final TextEditingController depositAmountController = TextEditingController();

  Future<void> _pickImage() async {
    if (await Permission.photos.request().isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          uploadedImagePath = image.path;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied! Please allow access to gallery."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      //  backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(13.sp),
            width: 42.h,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(10.sp),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Deposit",
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.sp),

                /// **Select Payment Method**
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select Payment Method:",
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 5.sp),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.sp),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMethod,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMethod = newValue!;
                        });
                      },
                      items: ["USDT TRC - 20", 
                      "UPI", 
                      "Bank Transfer"]
                          .map((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 12.sp),

                /// **USDT TRC - 20 Section**
                if (selectedMethod == "USDT TRC - 20") ...[
                  SizedBox(height: 1.h),

                  /// **QR Code**
                  Center(
                    child: Image.asset(
                      'assets/qr.jpeg',
                      height: 20.h,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  /// **Deposit Address**
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: SelectableText(
                            depositAddress,
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.w500),
                            maxLines: 1,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: depositAddress));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Copied!"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.sp, vertical: 5.sp),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5.sp),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.copy,
                                    color: Colors.white, size: 18.sp),
                                SizedBox(width: 5.sp),
                                Text("Copy",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.sp)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  /// **Deposit Warning**
                  Text(
                    "Deposit only TRC tokens to this address or else your funds will be lost forever.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                  ),
                  SizedBox(height: 1.h),
                ],

               SizedBox(height: 0.2.h),

                if (selectedMethod == "Bank Transfer") ...[
                  buildFixedTextField("Bank Name", "PUNJAB NATIONAL BANK"),
                  buildFixedTextField("Account Number", "0628100100008484"),
                  buildFixedTextField("IFSC Code", "PUNB0062810"),
                  SizedBox(height: 0.2.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Upload Bank Proof Image:",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 15.h,
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: uploadedBankImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 1.h),
                                Text("Click here to Upload Image",
                                    style: TextStyle(fontSize: 16)),
                              ],
                            )
                          : Image.file(uploadedBankImage!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
 
                
                if (selectedMethod == "Payment Proof") ...[
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 20.h,
                      width: double.infinity,
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: uploadedImagePath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload,
                                    size: 10.h, color: Colors.grey),
                                SizedBox(height: 1.h),
                                Text("Click here to Upload Image",
                                    style: TextStyle(fontSize: 18.sp)),
                              ],
                            )
                          : Image.file(File(uploadedImagePath!)),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],

                /// **Deposit Amount Input**
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter Deposit Amount (USD)",
                    style:
                        TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 1.h),
                TextField(
                  controller: depositAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter Deposit Amount",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.sp)),
                  ),
                ),
                SizedBox(height: 2.h),

                /// **Submit Button**
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                     String enteredAmount = depositAmountController.text.trim();
  double? depositValue = double.tryParse(enteredAmount);

  if (enteredAmount.isEmpty || depositValue == null || depositValue <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a valid deposit amount.")),
    );
    return;
  }

  if (selectedMethod == "Payment Proof" && uploadedImagePath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please upload a payment proof image.")),
    );
    return;
  }

  if (selectedMethod == "Bank Transfer" && uploadedBankImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please upload a bank proof image.")),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Deposit of \$${enteredAmount} submitted successfully!")),
  );

  // Perform actual deposit submission logic here (e.g., API call)
},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Submit",
                        style: TextStyle(fontSize: 18.sp, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget buildFixedTextField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[200], // Light grey to show it's non-editable
            ),
            child: Text(value,
                style: TextStyle(fontSize: 14, color: Colors.black)),
          ),
        ],
      ),
    );
  }


}



class WithdrawPage extends StatefulWidget {
  WithdrawPage({super.key});

  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
   final _formKey = GlobalKey<FormState>(); // Form key for validation

  String selectedMethod = "UPI"; // Default selection
  File? qrImage; // Stores selected QR Code Image
  final picker = ImagePicker(); // Image picker instance

  final TextEditingController amountController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  // Controllers for Bank Transfer details
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController branchController = TextEditingController();

  // Controller for UPI ID
  final TextEditingController upiController = TextEditingController();

  // Controllers for TRC-20 details
  final TextEditingController trc20AddressController = TextEditingController();
  final TextEditingController exchangeNameController = TextEditingController();

  // Function to pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        qrImage = File(pickedFile.path);
      });
    }
  }

  // Function to handle withdraw button click
  void _handleWithdraw() {
    if (_formKey.currentState!.validate()) {
      // Proceed with withdrawal logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Withdrawal request submitted successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            width: 42.h,
            child: Form(
              key: _formKey, // Attach the form key
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Withdrawal",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  /// Dropdown for Withdrawal Method
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
                        items: ["Bank Transfer", "UPI", "TRC-20"]
                            .map((String method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMethod = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 0.2.h),

                  /// Bank Transfer Fields
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

                  /// UPI Fields
                  if (selectedMethod == "UPI") ...[
                    buildTextField("UPI Address", "Enter UPI ID", upiController, true),
                    buildTextField("Full Name", "Enter Your Name", fullNameController, true),

                    /// QR Code Upload
                    SizedBox(height: 1.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Upload UPI QR Code:",
                          style: TextStyle(
                              fontSize: 14.px,
                              color: Colors.black,
                              fontWeight: FontWeight.w700)),
                    ),
                    SizedBox(height: 1.h),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: qrImage != null
                            ? Image.file(qrImage!, fit: BoxFit.cover)
                            : Icon(Icons.camera_alt,
                                color: Colors.grey, size: 40),
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],

                  /// TRC-20 Fields
                  if (selectedMethod == "TRC-20") ...[
                    buildTextField("TRC-20 Contract Address",
                        "Enter TRC-20 Address", trc20AddressController, true),
                    buildTextField("Withdrawal Exchange Name",
                        "Enter Exchange Name", exchangeNameController, false),
                  ],

                  /// Amount Input Field
                  buildTextField("Enter Amount", "Enter amount", amountController, true),

                  /// Withdraw Button
                  SizedBox(height: 1.h),
                  ElevatedButton(
                    onPressed: _handleWithdraw,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Withdraw", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Function to Build Text Fields with Validation
  Widget buildTextField(
      String label, String hint, TextEditingController controller, bool isRequired) {
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
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}