import 'package:uuid/uuid.dart';
import '../entities/account/journal_entry.dart';
import '../entities/account/ledger.dart';
import '../repositories/i_accounting_repository.dart';
import '../../core/errors/exceptions.dart'; // Define custom exceptions

class AccountingService {
  final IAccountingRepository _repository;
  final Uuid _uuid = Uuid(); // For generating IDs

  // Ledgers are now managed via the repository
  // Map<String, Ledger> _ledgers; // Remove in-memory map

  AccountingService(this._repository);

  Future<void> addJournalEntry(JournalEntry entry) async {
    if (entry.id.isEmpty) {
      // Assign ID if not provided (or handle based on your ID strategy)
      // entry = entry.copyWith(id: _uuid.v4()); // Assuming copyWith
      // For simplicity, let's assume ID is generated elsewhere or passed in
    }

    if (!entry.isBalanced) {
      throw ValidationException('Journal entry is not balanced.');
    }

    // Fetch current ledgers involved to check existence and update balances
    final ledgerIds = entry.lines.map((line) => line.ledgerId).toSet();
    final currentLedgers = <String, Ledger>{};
    for (String id in ledgerIds) {
      final ledger = await _repository.getLedgerById(id);
      if (ledger == null) {
        throw NotFoundException('Ledger not found: $id');
      }
      currentLedgers[id] = ledger;
    }

    // Perform updates within a transaction if possible (handled in repository impl)
    try {
      // 1. Save the Journal Entry itself
      await _repository.saveJournalEntry(
        entry,
      ); // Repository handles saving lines too

      // 2. Update ledger balances
      for (var line in entry.lines) {
        final ledger = currentLedgers[line.ledgerId]!;
        // Use the logic defined in the Ledger entity
        ledger.updateBalance(line.amount, line.entryType);
        await _repository.updateLedgerBalance(ledger.id, ledger.balance);
      }
    } catch (e) {
      // Log error, potentially attempt rollback if repo doesn't handle transactions
      print("Error adding journal entry: $e");
      throw DataPersistenceException(
        'Failed to save journal entry and update ledgers.',
      );
    }
  }

  Future<double> getLedgerBalance(String ledgerId) async {
    final ledger = await _repository.getLedgerById(ledgerId);
    if (ledger == null) {
      throw NotFoundException('Ledger not found: $ledgerId');
    }
    return ledger.balance;
  }

  Future<List<Ledger>> getAllLedgers() async {
    return await _repository.getAllLedgers();
  }

  Future<List<JournalEntry>> getRecentJournalEntries({int limit = 10}) async {
    // Add logic to fetch recent entries via repository
    final allEntries = await _repository.getAllJournalEntries();
    allEntries.sort(
      (a, b) => b.date.compareTo(a.date),
    ); // Sort descending by date
    return allEntries.take(limit).toList();
  }

  // Method to initialize default ledgers if they don't exist
  Future<void> initializeDefaultLedgers() async {
    final existingLedgers = await _repository.getAllLedgers();
    if (existingLedgers.isEmpty) {
      print("Initializing default ledgers...");
      // Define your chart of accounts here
      final defaultLedgers = [
        Ledger(id: _uuid.v4(), name: 'Cash', groupId: 'Assets'),
        Ledger(id: _uuid.v4(), name: 'Bank Account', groupId: 'Assets'),
        Ledger(id: _uuid.v4(), name: 'Accounts Receivable', groupId: 'Assets'),
        Ledger(id: _uuid.v4(), name: 'Groceries Expense', groupId: 'Expenses'),
        Ledger(id: _uuid.v4(), name: 'Salary Income', groupId: 'Income'),
        Ledger(
          id: _uuid.v4(),
          name: 'Credit Card Payable',
          groupId: 'Liabilities',
        ),
        // Add more essential ledgers
      ];
      for (var ledger in defaultLedgers) {
        await _repository.saveLedger(ledger);
      }
      print("Default ledgers initialized.");
    }
  }
}
