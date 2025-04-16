import '../entities/account/journal_entry.dart';
import '../entities/account/ledger.dart';

abstract class IAccountingRepository {
  Future<void> saveJournalEntry(JournalEntry entry);
  Future<JournalEntry?> getJournalEntryById(String id);
  Future<List<JournalEntry>> getAllJournalEntries(); // Example method

  Future<void> saveLedger(Ledger ledger);
  Future<Ledger?> getLedgerById(String id);
  Future<List<Ledger>> getAllLedgers();
  Future<void> updateLedgerBalance(String ledgerId, double newBalance);
  Future<Map<String, Ledger>> getLedgerMap(); // To initialize service
}
