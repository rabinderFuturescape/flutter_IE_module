import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:household_accounting_app/src/domain/entities/vendor.dart';
import 'package:household_accounting_app/src/domain/entities/bill.dart';
import 'package:household_accounting_app/src/presentation/providers/vendor_provider.dart';
import 'package:household_accounting_app/src/presentation/providers/bill_provider.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({Key? key}) : super(key: key);

  @override
  _VendorScreenState createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).loadVendors();
      Provider.of<BillProvider>(context, listen: false).loadBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utility Bills Vendors'),
      ),
      body: Consumer2<VendorProvider, BillProvider>(
        builder: (context, vendorProvider, billProvider, child) {
          if (vendorProvider.vendors.isEmpty) {
            return const Center(child: Text('No vendors available.'));
          }
          return ListView.builder(
            itemCount: vendorProvider.vendors.length,
            itemBuilder: (context, index) {
              final Vendor vendor = vendorProvider.vendors[index];
              final List<Bill> vendorBills = billProvider.bills
                  .where((bill) => bill.vendorId == vendor.id)
                  .toList();

              return ExpansionTile(
                title: Text(vendor.name),
                children: [
                  if (vendorBills.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No bills available for this vendor.'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vendorBills.length,
                      itemBuilder: (context, billIndex) {
                        final Bill bill = vendorBills[billIndex];
                        return ListTile(
                          title: Text('Amount: ${bill.amount}'),
                          subtitle:
                              Text('Due Date: ${bill.dueDate.toLocal()}'),
                        );
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        billProvider.fetchBillsFromBBPS(vendor, 'customerId');
                      },
                      child: const Text('Fetch Bills from BBPS'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}