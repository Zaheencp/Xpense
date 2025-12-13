import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpense/controllers/cardprovider.dart';
import 'package:xpense/controllers/firebasecontroller.dart';
import 'package:xpense/models/transactionmodel.dart';

class Containerlistview extends StatelessWidget {
  const Containerlistview({super.key});

  void fetchdata(BuildContext context) {
    Provider.of<FirebaseController>(context, listen: false).fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    fetchdata(context);
    return Consumer<FirebaseController>(builder: (context, provider, child) {
      final stream = provider.fetchdata();
      if (stream == null) {
        return const Center(
          child: Text('Please log in to view transactions'),
        );
      }
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }
            {
              List<DocumentSnapshot<Map<String, dynamic>>> transaction =
                  snapshot.data!.docs;
              log(transaction.toString());
              //  Map<String,List<Map<String,dynamic>>> groupedtransaction={};
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(

                    //  scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transaction.length,
                    itemBuilder: (context, index) {
                      final transac = transaction[index];
                      final id = transaction[index].id;

                      var transactionData = transac.data()!;
                      var transactions =
                          TransactionModel.fromMap(transactionData);

                      return InkWell(
                        onTap: () {
                          _showTransactionDetails(context, transactions, id);
                        },
                        child: Card(
                          color: Colors.blueGrey[800],
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            textColor: Colors.black,
                            // tileColor: Colors.grey[800],
                            title: Text(
                              transactions.category,
                              style: const TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      transactions.amount,
                                      style: const TextStyle(fontSize: 17),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () async {
                                        // 1. Update Local State (Balances) Immediately
                                        await Provider.of<TransactionProvider>(
                                          context,
                                          listen: false,
                                        ).deleteTransaction(transactions);

                                        // 2. Show Feedback Immediately
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Transaction deleted'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 1),
                                          ),
                                        );

                                        // 3. Update Firestore (Background)
                                        try {
                                          await provider
                                              .getcollectiondocumentid(id);

                                          // Force refresh list to stay in sync
                                          if (context.mounted) {
                                            Provider.of<FirebaseController>(
                                              context,
                                              listen: false,
                                            ).fetchdata();
                                          }
                                        } catch (e) {
                                          debugPrint(
                                              "Error deleting from Firestore: $e");
                                        }
                                      },
                                      icon: const Icon(
                                        FontAwesomeIcons.trash,
                                        color: Colors.red,
                                        size: 20,
                                      )),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              //  mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transactions.memo,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  transactions.date,
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (transactions.location != null &&
                                    transactions.location!.isNotEmpty)
                                  Text(
                                    transactions.location!,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              );
            }
          });
    });
  }

  void _showTransactionDetails(
      BuildContext context, TransactionModel transaction, String id) {
    // Determine if it's an expense based on category
    final expenseCategories = [
      'food',
      'transportation',
      'bills',
      'home',
      'car',
      'entertainment',
      'shopping',
      'clothing',
      'insurance',
      'cigarette',
      'telephone',
      'health',
      'sports',
      'baby',
      'pet',
      'education',
      'travel',
      'gift'
    ];
    final isExpense =
        expenseCategories.contains(transaction.category.toLowerCase());
    final amountColor = isExpense ? Colors.red : Colors.green;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: amountColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isExpense ? 'Expense' : 'Income',
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(context, 'Amount', '\$${transaction.amount}',
                  isBold: true, valueColor: amountColor),
              const Divider(height: 24),
              _buildDetailRow(context, 'Category', transaction.category),
              const Divider(height: 24),
              _buildDetailRow(context, 'Date', transaction.date),
              const Divider(height: 24),
              _buildDetailRow(context, 'Note', transaction.memo),
              if (transaction.location != null &&
                  transaction.location!.isNotEmpty) ...[
                const Divider(height: 24),
                _buildDetailRow(context, 'Location', transaction.location!),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
