// lib/setting.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wefund/ThemeProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDetailsPage extends StatefulWidget {
  const SettingsDetailsPage({super.key});
  @override
  State<SettingsDetailsPage> createState() => _SettingsDetailsPageState();
}

class _SettingsDetailsPageState extends State<SettingsDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // form keys
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // loading flag
  bool _isLoading = true;

  // country list must include a blank prompt first
  final List<String> _countries = [
    '',
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    // ... add the rest as needed
  ];

  // controllers for profile fields
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _userNameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl    = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _cityCtrl      = TextEditingController();
  final _zipCtrl       = TextEditingController();
  String _country = '';

  // controllers for password change
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl     = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  late String _email, _acctNo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAndFetchProfile();
  }
  


  @override
  void dispose() {
    _tabController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _userNameCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAndFetchProfile() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    _email  = prefs.getString('email') ?? '';
    _acctNo = prefs.getString('selectedAccountNumber') ?? '';
    _emailCtrl.text = _email;

    if (_email.isEmpty || _acctNo.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No account/email found.")),
      );
      return;
    }

    final resp = await http.post(
      Uri.parse('https://wefundclient.com/Crm/Crm/settings_api.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mode': 'fetch',
        'email': _email, 
        'account_number': _acctNo,
      }),
    );

    if (resp.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error ${resp.statusCode}")),
      );
      return;
    }

    final Map<String, dynamic> data = jsonDecode(resp.body);
    // populate controllers
    _firstNameCtrl.text = data['first_name'] ?? '';
    _lastNameCtrl.text  = data['last_name']  ?? '';
    _userNameCtrl.text  = data['username']   ?? '';
    _emailCtrl.text = _email;

    _mobileCtrl.text    = data['mobile_number'] ?? '';
    _addressCtrl.text   = data['address']    ?? '';
    _cityCtrl.text      = data['city']       ?? '';
    _zipCtrl.text       = data['zip']        ?? '';
    final fetchedCountry = data['country'] ?? '';

    // if fetched country isn't in our list, fallback to blank
    _country = _countries.contains(fetchedCountry)
        ? fetchedCountry
        : _countries.first;

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final resp = await http.post(
      Uri.parse('https://wefundclient.com/Crm/Crm/settings_api.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mode': 'update_profile',
        'email': _emailCtrl.text.trim(),
        'account_number': _acctNo,
        'first_name': _firstNameCtrl.text.trim(),
        'last_name':  _lastNameCtrl.text.trim(),
        'username':   _userNameCtrl.text.trim(),
        'mobile_number': _mobileCtrl.text.trim(),
        'address':    _addressCtrl.text.trim(),
        'city':       _cityCtrl.text.trim(),
        'zip':        _zipCtrl.text.trim(),
        'country':    _country,
      }),
    );
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body['error'] ?? "Update failed")),
      );
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    final resp = await http.post(
      Uri.parse('https://wefundclient.com/Crm/Crm/settings_api.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mode': 'update_password',
        'email': _emailCtrl.text.trim(),
        'account_number': _acctNo,
        'current_password': _currentPwdCtrl.text,
        'new_password':     _newPwdCtrl.text,
        'confirm_password': _confirmPwdCtrl.text,
      }),
    );
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed")),
      );
      _currentPwdCtrl.clear();
      _newPwdCtrl.clear();
      _confirmPwdCtrl.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body['error'] ?? "Password change failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor:
            themeProvider.isDarkMode ? Colors.black : Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 22.px, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          labelStyle:
              TextStyle(fontSize: 16.px, fontWeight: FontWeight.bold),
          unselectedLabelStyle:
              TextStyle(fontSize: 16.px, fontWeight: FontWeight.normal),
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
          const Documents(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(children: [
          _buildSectionTitle("Account Details", Icons.person),
           // ▶︎ Full Name
          _buildLabeledTextField("Full Name", _firstNameCtrl, true),

          // ▶︎ Last Name
          _buildLabeledTextField("Last Name", _lastNameCtrl, true),

          // ◀── INSERT USERNAME HERE ──▶
          _buildLabeledTextField("Username", _userNameCtrl, true),
          _buildLabeledTextField(
  "Email",
  _emailCtrl,      // ← use a real TextEditingController you declared
  true,            // ← mark it required if you want validation
  enabled: true,   // ← or just omit this parameter, since true is the default
),

          _buildLabeledTextField("Mobile number", _mobileCtrl, true),
          _buildLabeledTextField("Address", _addressCtrl, true),
          _buildLabeledTextField("City", _cityCtrl, true),
          // State is still here per your UI but won’t be saved
          
          _buildLabeledTextField("Zip", _zipCtrl, true),
          _buildDropdownField("Country", _country,
              (v) => setState(() => _country = v)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveProfile,
            child:
                const Text("Save Details", style: TextStyle(color: Colors.white, fontSize: 20)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 100),
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Change Password", Icons.lock),
          Form(
            key: _passwordFormKey,
            child: Column(children: [
              _buildLabeledTextField(
                  "Current Password", _currentPwdCtrl, true,
                  obscureText: true),
              _buildLabeledTextField("New Password", _newPwdCtrl, true,
                  obscureText: true),
              _buildLabeledTextField(
                  "Re-Enter New Password", _confirmPwdCtrl, true,
                  obscureText: true),
              SizedBox(height: 1.h),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text("Change Password",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 1.h),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildLabeledTextField(String label,
      TextEditingController ctrl, bool required,
      {bool obscureText = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          obscureText: obscureText,
          enabled: enabled,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          validator: required
              ? (value) =>
                  (value == null || value.trim().isEmpty) ? '$label is required' : null
              : null,
        ),
      ]),
    );
  }

  Widget _buildDropdownField(
      String label, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.isEmpty ? 'Select Country' : c)))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ]),
    );
  }
}



/// stub for your existing Documents widget:
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