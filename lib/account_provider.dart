import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple model to hold one account’s data
class AccountModel {
  final String number;
  final String balance;
  AccountModel({required this.number, required this.balance});
}

/// Our ChangeNotifier which:
///  • holds the currently selected account
///  • exposes a `select(...)` method to switch it
///  • auto-loads from shared_prefs when told to
class AccountProvider extends ChangeNotifier {
  /// Whether we are currently loading from prefs
  bool loading = false;

  /// The currently selected account (or null)
  AccountModel? current;

  /// Call this once at startup (e.g. in main) to load whatever was last selected
  Future<void> loadFromPrefs() async {
    loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final no  = prefs.getString('selectedAccountNumber') ?? '';
    final bal = prefs.getString('selectedAccountAmount') ?? '';

    if (no.isNotEmpty && bal.isNotEmpty) {
      current = AccountModel(number: no, balance: bal);
    }

    loading = false;
    notifyListeners();
  }

  /// Whenever you pick a new account, call this:
  Future<void> select(String newNumber, String newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccountNumber', newNumber);
    await prefs.setString('selectedAccountAmount', newBalance);

    current = AccountModel(number: newNumber, balance: newBalance);
    notifyListeners();
  }
}
