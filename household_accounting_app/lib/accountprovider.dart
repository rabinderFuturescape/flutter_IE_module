import 'package:flutter/foundation.dart';
import '../../domain/entities/account/journal_entry.dart';
import '../../domain/entities/account/ledger.dart';
import '../../domain/usecases/accounting_service.dart';

class AccountingProvider with ChangeNotifier {
  final AccountingService _accountingService;

  AccountingProvider(this._accountingService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Ledger> _ledgers = [];
  List<Ledger> get ledgers => List.unmodifiable(_ledgers);

  List<JournalEntry> _recentEntries = [];
  List<JournalEntry> get recentEntries => List.unmodifiable(_recentEntries);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> initialize() async {
    await _accountingService
        .initializeDefaultLedgers(); // Ensure defaults exist
    await fetchLedgers();
    await fetchRecentEntries();
  }

  Future<void> fetchLedgers() async {
    _setLoading(true);
    _setError(null);
    try {
      _ledgers = await _accountingService.getAllLedgers();
    } catch (e) {
      _setError("Failed to fetch ledgers: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRecentEntries() async {
    _setLoading(true);
    _setError(null);
    try {
      _recentEntries = await _accountingService.getRecentJournalEntries();
    } catch (e) {
      _setError("Failed to fetch recent entries: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addEntry(JournalEntry entry) async {
    _setLoading(true);
    _setError(null);
    try {
      await _accountingService.addJournalEntry(entry);
      // Refresh relevant data after adding
      await fetchLedgers();
      await fetchRecentEntries();
      return true; // Indicate success
    } catch (e) {
      print("Error in provider addEntry: $e"); // Log for debugging
      _setError("Failed to add journal entry: ${e.toString()}");
      return false; // Indicate failure
    } finally {
      _setLoading(false);
    }
  }
}
