import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wefund/ThemeProvider.dart';

class SettingsDetailsPage extends StatefulWidget {
  const SettingsDetailsPage({super.key});

  @override
  State<SettingsDetailsPage> createState() => _SettingsDetailsPageState();
}

class _SettingsDetailsPageState extends State<SettingsDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange, // Selected tab text & icon color
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(
            fontSize: 16.px,
            fontWeight: FontWeight.bold,
          ), // Selected tab text style
          unselectedLabelStyle: TextStyle(
            fontSize: 16.px,
            fontWeight: FontWeight.normal,
          ), // Unselected tab text style

          tabs: [
            Tab(icon: Icon(Icons.person, size: 20.sp), text: "Profile"),
            Tab(icon: Icon(Icons.file_present, size: 20.sp), text: "Documents"),
          ],
        ),
      ),
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          Documents(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildDropdown(
                "Language", ["English", "Hindi", "Spanish"], "English"),
            SizedBox(height: 20),
            _buildSectionTitle("Account Details", Icons.person),
            _buildLabeledTextField("Full Name", "Enter Full Name", true),
            _buildLabeledTextField("Email", "support@wefundglobalfx.com", true),
            _buildLabeledTextField("Mobile number", "8742082357", true),
            _buildLabeledTextField("Address", "Enter Your Address", true),
            _buildLabeledTextField("City", "Enter City", true),
            _buildLabeledTextField("State", "Enter State", true),
            _buildLabeledTextField("Zip", "Enter Zip", true),
            _buildLabeledTextField("Country", "Enter Country", true),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Handle save details action
                }
              },
              child: Text("Save Details",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 100),
              ),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("Change Password", Icons.lock),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _buildLabeledTextField(
                      "Current Password", "Current Password", true,
                      obscureText: true),
                  _buildLabeledTextField("New Password", "New Password", true,
                      obscureText: true),
                  _buildLabeledTextField(
                      "Re-Enter New Password", "Re-Enter New Password", true,
                      obscureText: true),
                  SizedBox(height: 1.h),
                  ElevatedButton(
                    onPressed: () {
                      if (_passwordFormKey.currentState!.validate()) {
                        // Handle change password action
                      }
                    },
                    child: Text("Change Password",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(String label, String hint, bool required,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          TextFormField(
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            validator: required
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedItem,
                isExpanded: true,
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

class Documents extends StatefulWidget {
  const Documents({super.key});

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  Map<String, File?> uploadedImages = {};
  final List<String> documentTypes = [
    "Address proof (Front)",
    "Address proof (Back)",
    "National ID proof (Front)",
    "National ID proof (Back)",
    "Bank Statement",
    "Other Proofs",
  ];

  Future<void> _pickImage(String documentType) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        uploadedImages[documentType] = File(pickedFile.path);
      });
    }
  }

  void _submitDocuments() {
    bool allUploaded =
        documentTypes.every((type) => uploadedImages[type] != null);

    if (allUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("All documents uploaded successfully!")));
      // Proceed with submission logic (e.g., API call)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please upload all required documents.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   appBar: AppBar(title: Text("Upload Documents")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              height: 5.h,
              width: double.infinity,
              decoration: BoxDecoration(
               color: Colors.grey[400], // Light grey background
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Upload Documents",
                      style:
                          TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left,
                    ),SizedBox(width: 2.w,),
                    Icon(Icons.upload_file)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...documentTypes
                    .map((type) => _buildUploadSection(type))
                    .toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: _submitDocuments,
                  child: Text("Submit",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () => _pickImage(title),
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: uploadedImages[title] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      uploadedImages[title]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                        Text("Click here to Upload Image"),
                      ],
                    ),
                  ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
