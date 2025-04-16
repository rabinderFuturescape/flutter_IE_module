import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/utils/db_constants.dart'; // Define table/column names

class SqliteDatabaseHelper {
  static final SqliteDatabaseHelper _instance =
      SqliteDatabaseHelper._internal();
  factory SqliteDatabaseHelper() => _instance;
  SqliteDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DbConstants.dbName);

    return await openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // Handle schema migrations if needed
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.ledgersTable} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colBalance} REAL NOT NULL,
        ${DbConstants.colGroupId} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.journalEntriesTable} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colDate} TEXT NOT NULL, -- Store as ISO8601 String
        ${DbConstants.colDescription} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.journalLinesTable} (
        ${DbConstants.colId} TEXT PRIMARY KEY, -- Or use INTEGER AUTOINCREMENT
        ${DbConstants.colJournalEntryId} TEXT NOT NULL,
        ${DbConstants.colLedgerId} TEXT NOT NULL,
        ${DbConstants.colAmount} REAL NOT NULL,
        ${DbConstants.colEntryType} TEXT NOT NULL, -- 'debit' or 'credit'
        FOREIGN KEY (${DbConstants.colJournalEntryId}) REFERENCES ${DbConstants.journalEntriesTable}(${DbConstants.colId}) ON DELETE CASCADE,
        FOREIGN KEY (${DbConstants.colLedgerId}) REFERENCES ${DbConstants.ledgersTable}(${DbConstants.colId})
      )
    ''');

    // --- Add CREATE TABLE statements for other entities ---
    // Reimbursements, BillDetails, Advances, SubscriptionDeliveries
    // Example for Reimbursements and BillDetails:
    await db.execute('''
      CREATE TABLE ${DbConstants.reimbursementsTable} (
         ${DbConstants.colId} TEXT PRIMARY KEY,
         ${DbConstants.colStaffId} TEXT NOT NULL,
         ${DbConstants.colDate} TEXT NOT NULL
         -- Add other fields if needed
      )
    ''');
    await db.execute('''
       CREATE TABLE ${DbConstants.billDetailsTable} (
         ${DbConstants.colId} TEXT PRIMARY KEY,
         ${DbConstants.colReimbursementId} TEXT NOT NULL, -- Foreign Key
         ${DbConstants.colBillDate} TEXT NOT NULL,
         ${DbConstants.colVendor} TEXT NOT NULL,
         ${DbConstants.colAmount} REAL NOT NULL,
         ${DbConstants.colDescription} TEXT NOT NULL,
         FOREIGN KEY (${DbConstants.colReimbursementId}) REFERENCES ${DbConstants.reimbursementsTable}(${DbConstants.colId}) ON DELETE CASCADE
       )
     ''');
    // ... Add tables for Advances and SubscriptionDeliveries
  }

  // --- Add CRUD Methods ---
  // Example: Insert Ledger
  Future<int> insertLedger(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      DbConstants.ledgersTable,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    ); // Replace if exists
  }

  // Example: Get Ledger by ID
  Future<Map<String, dynamic>?> getLedgerMapById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DbConstants.ledgersTable,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Example: Get All Ledgers
  Future<List<Map<String, dynamic>>> getAllLedgerMaps() async {
    final db = await database;
    return await db.query(DbConstants.ledgersTable);
  }

  // Example: Update Ledger Balance
  Future<int> updateLedgerBalance(String id, double balance) async {
    final db = await database;
    return await db.update(
      DbConstants.ledgersTable,
      {DbConstants.colBalance: balance},
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  // Example: Insert Journal Entry (handling lines within a transaction)
  Future<void> insertJournalEntry(
    Map<String, dynamic> entryMap,
    List<Map<String, dynamic>> lineMaps,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // Insert the main entry
      await txn.insert(
        DbConstants.journalEntriesTable,
        entryMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Insert all lines
      for (var lineMap in lineMaps) {
        await txn.insert(
          DbConstants.journalLinesTable,
          lineMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Example: Get Journal Entry with Lines
  Future<Map<String, dynamic>?> getJournalEntryMapById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> entryMaps = await db.query(
      DbConstants.journalEntriesTable,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    if (entryMaps.isEmpty) return null;

    final entryMap = entryMaps.first;

    // Fetch associated lines
    final List<Map<String, dynamic>> lineMaps = await db.query(
      DbConstants.journalLinesTable,
      where: '${DbConstants.colJournalEntryId} = ?',
      whereArgs: [id],
    );
    // Add lines to the entry map (or handle in the repository)
    entryMap['lines'] = lineMaps;
    return entryMap;
  }

  // Example: Get All Journal Entries (might need pagination for large datasets)
  Future<List<Map<String, dynamic>>> getAllJournalEntryMaps() async {
    final db = await database;
    // This simple version fetches all entries. For performance, fetch lines separately or join.
    final entries = await db.query(DbConstants.journalEntriesTable);
    // You might want to fetch lines for each entry here or in the repository
    return entries;
  }

  // *** Implement similar CRUD methods for Reimbursements, BillDetails, Advances, Subscriptions ***
  // Remember to handle relationships (e.g., saving BillDetails with ReimbursementId)
  // and data type conversions (DateTime <-> String/int, Enum <-> String).
}

// Define constants in lib/src/core/utils/db_constants.dart
class DbConstants {
  static const dbName = 'household_accounting.db';
  static const dbVersion = 1;

  // Table Names
  static const ledgersTable = 'ledgers';
  static const journalEntriesTable = 'journal_entries';
  static const journalLinesTable = 'journal_lines';
  static const reimbursementsTable = 'reimbursements';
  static const billDetailsTable = 'bill_details';
  // ... other table names

  // Common Columns
  static const colId = 'id';
  static const colDate = 'date';
  static const colAmount = 'amount';
  static const colDescription = 'description';

  // Ledger Columns
  static const colName = 'name';
  static const colBalance = 'balance';
  static const colGroupId = 'groupId';

  // Journal Line Columns
  static const colJournalEntryId = 'journalEntryId';
  static const colLedgerId = 'ledgerId';
  static const colEntryType = 'entryType'; // Store as 'debit' or 'credit'

  // Reimbursement Columns
  static const colStaffId = 'staffId';

  // Bill Detail Columns
  static const colReimbursementId = 'reimbursementId';
  static const colBillDate = 'billDate';
  static const colVendor = 'vendor';

  // ... other column names
}
