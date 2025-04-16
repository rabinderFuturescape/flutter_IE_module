import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:household_accounting_app/voucher_entry_form.dart';
import 'package:household_accounting_app/src/data/repositories/bill_repository_impl.dart';
import 'package:household_accounting_app/src/data/repositories/vendor_repository_impl.dart';
import 'package:household_accounting_app/src/domain/usecases/bill_service.dart';
import 'package:household_accounting_app/src/domain/usecases/vendor_service.dart';

import 'src/data/datasources/local/sqlite_database_helper.dart';
import 'src/data/repositories/accounting_repository_impl.dart';
import 'src/presentation/providers/vendor_provider.dart';
import 'src/presentation/providers/bill_provider.dart';
import 'src/domain/repositories/i_accounting_repository.dart';
import 'src/presentation/screens/vendor_screen.dart';
import 'src/domain/usecases/accounting_service.dart';
import 'src/presentation/screens/dashboard_screen.dart';
// import 'src/data/repositories/reimbursement_repository_impl.dart'; // Create these
// import 'src/data/repositories/subscription_repository_impl.dart'; // Create these
import 'src/domain/usecases/reimbursement_service.dart'; // Create these
import 'src/domain/usecases/subscription_service.dart'; // Create these
import 'src/presentation/providers/accounting_provider.dart';
import 'src/presentation/providers/reimbursement_provider.dart'; // Create these
import 'src/presentation/providers/subscription_provider.dart'; // Create these
import 'src/presentation/screens/dashboard_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // --- Dependency Injection Setup ---
  // 1. Data Source
  final dbHelper = SqliteDatabaseHelper();
  // Initialize DB (optional here, can be lazy loaded in helper)
  // await dbHelper.database;

  // 2. Repositories (Concrete Implementations)
  final IAccountingRepository accountingRepository = AccountingRepositoryImpl(
    dbHelper,
  );
  // TODO: Create and instantiate other repository implementations
  // final IReimbursementRepository reimbursementRepository = ReimbursementRepositoryImpl(dbHelper);
  // final ISubscriptionRepository subscriptionRepository = SubscriptionRepositoryImpl(dbHelper);

  // 3. Services (Use Cases)
  final accountingService = AccountingService(accountingRepository);
  // TODO: Create and instantiate other services
  // final reimbursementService = ReimbursementService(reimbursementRepository);
  // final subscriptionService = SubscriptionService(subscriptionRepository);

  // -- Vendor and Bill Injection --
  final vendorRepository = VendorRepositoryImpl();
  final vendorService = VendorService(vendorRepository);

  final billRepository = BillRepositoryImpl();
  final billService = BillService(billRepository);

  

  // --- Run App with Providers ---
  runApp(
    MultiProvider(
      providers: [
        // Provide the services/use cases if needed directly (less common)
        // Provider<AccountingService>.value(value: accountingService),
        

        // Provide ChangeNotifiers (ViewModels) that use the services
        ChangeNotifierProvider<AccountingProvider>(
          create:
              (_) =>
                  AccountingProvider(accountingService)
                    ..initialize(), // Initialize data
        ),
        // TODO: Add other providers
        // ChangeNotifierProvider<ReimbursementProvider>(
        //   create: (_) => ReimbursementProvider(reimbursementService)..fetchReimbursements(),
        // ),
        // ChangeNotifierProvider<SubscriptionProvider>(
        //   create: (_) => SubscriptionProvider(subscriptionService)..fetchDeliveries(),
        // ),
         ChangeNotifierProvider<VendorProvider>(
          create: (_) => VendorProvider(vendorService)..loadVendors(),
        ),
        ChangeNotifierProvider<BillProvider>(
          create: (_) => BillProvider(billService)..loadBills(),
        ),

      ], 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Household Accounting',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardScreen(),
      routes: {
        '/voucher_entry': (context) => VoucherEntryForm(),
        '/vendors': (context) => VendorScreen(),

      },
    );
  }
}

















