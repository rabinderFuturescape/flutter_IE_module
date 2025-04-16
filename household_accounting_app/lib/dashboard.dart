import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../providers/accounting_provider.dart';
import '../widgets/common/loading_indicator.dart'; // Create this widget
import '../widgets/common/error_display.dart'; // Create this widget
import 'journal_entry_add_screen.dart'; // Navigate to add screen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data when the screen loads
    // Use addPostFrameCallback to avoid calling provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access provider without listening during initState
      final accountingProvider = Provider.of<AccountingProvider>(
        context,
        listen: false,
      );
      // Check if data is already loaded or fetch if needed
      if (accountingProvider.ledgers.isEmpty) {
        accountingProvider.initialize(); // Fetches ledgers and entries
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer or context.watch to listen for changes
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Journal Entry',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const JournalEntryAddScreen(),
                ),
              );
            },
          ),
          // Add buttons for other actions (Reimbursement, etc.)
        ],
      ),
      body: Consumer<AccountingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.ledgers.isEmpty) {
            // Show loading only initially
            return const LoadingIndicator();
          }
          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: () => provider.initialize(), // Retry initialization
            );
          }

          // Display Ledger Balances
          final ledgerList =
              provider.ledgers.isNotEmpty
                  ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: provider.ledgers.length,
                    itemBuilder: (context, index) {
                      final ledger = provider.ledgers[index];
                      return ListTile(
                        title: Text(ledger.name),
                        trailing: Text(
                          NumberFormat.currency(
                            symbol: '\$',
                          ).format(ledger.balance), // Format currency
                          style: TextStyle(
                            color:
                                ledger.balance >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Group: ${ledger.groupId}'),
                      );
                    },
                  )
                  : const Center(child: Text('No ledgers found.'));

          // Display Recent Transactions
          final recentEntriesList =
              provider.recentEntries.isNotEmpty
                  ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: provider.recentEntries.length,
                    itemBuilder: (context, index) {
                      final entry = provider.recentEntries[index];
                      return ListTile(
                        title: Text(entry.description),
                        subtitle: Text(
                          DateFormat.yMd().add_jm().format(entry.date),
                        ), // Format date
                        // You could show total debit/credit here
                      );
                    },
                  )
                  : const Center(child: Text('No recent transactions.'));

          return RefreshIndicator(
            onRefresh: () => provider.initialize(), // Pull to refresh
            child: SingleChildScrollView(
              physics:
                  AlwaysScrollableScrollPhysics(), // Enable scrolling for RefreshIndicator
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ledger Balances',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  ledgerList,
                  const SizedBox(height: 24),
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  recentEntriesList,
                  // Add sections for pending reimbursements, subscriptions etc.
                  // Fetch data from other providers (ReimbursementProvider, SubscriptionProvider)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
