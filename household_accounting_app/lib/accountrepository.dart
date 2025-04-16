import 'package:uuid/uuid.dart'; // For generating line IDs if needed
import '../../domain/entities/account/entry_type.dart';
import '../../domain/entities/account/journal_entry.dart';
import '../../domain/entities/account/journal_line.dart';
import '../../domain/entities/account/ledger.dart';
import '../../domain/repositories/i_accounting_repository.dart';
import '../datasources/local/sqlite_database_helper.dart';
import '../../core/utils/db_constants.dart'; // For column names

class AccountingRepositoryImpl implements IAccountingRepository {
  final SqliteDatabaseHelper _dbHelper;
  final Uuid _uuid = Uuid(); // For generating IDs for lines if needed

  AccountingRepositoryImpl(this._dbHelper);

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    final entryMap = entry.toMap(); // Assumes JournalEntry has toMap
    final lineMaps =
        entry.lines.map((line) {
          // Ensure each line has a unique ID if needed by the table schema
          final lineMap = line.toMap(); // Assumes JournalLine has toMap
          lineMap[DbConstants.colJournalEntryId] = entry.id; // Add foreign key
          // lineMap[DbConstants.colId] = _uuid.v4(); // Assign line ID if needed
          return lineMap;
        }).toList();

    await _dbHelper.insertJournalEntry(entryMap, lineMaps);
  }

  @override
  Future<JournalEntry?> getJournalEntryById(String id) async {
    final entryMap = await _dbHelper.getJournalEntryMapById(id);
    if (entryMap != null) {
      return JournalEntry.fromMap(
        entryMap,
      ); // Assumes JournalEntry.fromMap handles lines
    }
    return null;
  }

  @override
  Future<List<JournalEntry>> getAllJournalEntries() async {
    final entryMaps = await _dbHelper.getAllJournalEntryMaps();
    // This is inefficient if there are many entries/lines.
    // Consider fetching lines separately or using JOINs in the helper.
    List<JournalEntry> entries = [];
    for (var map in entryMaps) {
      final entry = await getJournalEntryById(
        map[DbConstants.colId],
      ); // Re-fetch with lines
      if (entry != null) {
        entries.add(entry);
      }
    }
    return entries;
  }

  @override
  Future<void> saveLedger(Ledger ledger) async {
    await _dbHelper.insertLedger(ledger.toMap());
  }

  @override
  Future<Ledger?> getLedgerById(String id) async {
    final map = await _dbHelper.getLedgerMapById(id);
    return map != null ? Ledger.fromMap(map) : null;
  }

  @override
  Future<List<Ledger>> getAllLedgers() async {
    final maps = await _dbHelper.getAllLedgerMaps();
    return maps.map((map) => Ledger.fromMap(map)).toList();
  }

  @override
  Future<Map<String, Ledger>> getLedgerMap() async {
    final ledgers = await getAllLedgers();
    return {for (var ledger in ledgers) ledger.id: ledger};
  }

  @override
  Future<void> updateLedgerBalance(String ledgerId, double newBalance) async {
    await _dbHelper.updateLedgerBalance(ledgerId, newBalance);
  }
}

// Add toMap/fromMap in JournalEntry and JournalLine
// Example for JournalEntry:
/*
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'date': date.toIso8601String(), // Store date as string
    'description': description,
    // Lines are handled separately in the repository/DB helper
  };
}

factory JournalEntry.fromMap(Map<String, dynamic> map) {
  // Lines need to be fetched/parsed separately
  final linesList = map['lines'] as List<dynamic>? ?? []; // Assuming lines are passed in map
  return JournalEntry(
    id: map['id'] as String,
    date: DateTime.parse(map['date'] as String),
    description: map['description'] as String,
    lines: linesList.map((lineMap) => JournalLine.fromMap(lineMap as Map<String, dynamic>)).toList(),
  );
}
*/
// Example for JournalLine:
/*
 Map<String, dynamic> toMap() {
   return {
     // 'id': id, // If line has its own ID
     'ledgerId': ledgerId,
     'amount': amount,
     'entryType': entryType.name, // Store enum as string 'debit' or 'credit'
   };
 }

 factory JournalLine.fromMap(Map<String, dynamic> map) {
   return JournalLine(
     ledgerId: map['ledgerId'] as String,
     amount: map['amount'] as double,
     entryType: EntryType.values.firstWhere((e) => e.name == map['entryType']),
   );
 }
*/
