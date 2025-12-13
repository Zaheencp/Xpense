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
                          //  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Listtilepage()));
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
                                        Provider.of<TransactionProvider>(
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
}
