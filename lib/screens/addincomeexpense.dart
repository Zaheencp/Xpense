import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xpense/controllers/cardprovider.dart';
import 'package:xpense/controllers/firebasecontroller.dart';
import 'package:xpense/models/categorymodel.dart';
import 'package:xpense/screens/widgets/authbutton.dart';
import 'package:xpense/screens/widgets/transactions.dart';
import 'package:xpense/screens/widgets/bottomnavbar.dart';
import 'package:xpense/screens/receipt_scanner_screen.dart';

class Addinex extends StatefulWidget {
  const Addinex({super.key});

  @override
  State<Addinex> createState() => _AddinexState();
}

class _AddinexState extends State<Addinex> {
  final categorycontroller = TextEditingController();

  final amountcontroller = TextEditingController();
  List<Expensecategory> income = Expensecategory.incomes;
  final datecontroller = TextEditingController();
  List<Expensecategory> Expence = Expensecategory.expenses;
  final memocontroller = TextEditingController();
  final locationController = TextEditingController();
  final paymentMethodController = TextEditingController();
  IconData? icon;
  String textincome = '';
  String textexpense = '';
  List<Expensecategory> name = [];
  Expensecategory? selectedCategory;

  bool isIncome = true;
  String dateformat = DateTime.now().toLocal().toString().split(' ')[0];

  @override
  Widget build(BuildContext context) {
    setState(() {
      datecontroller.text = dateformat;
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(93),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Add a Transaction',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                TabBar(
                  indicatorColor: Colors.red,
                  tabs: [
                    Tab(icon: Icon(FontAwesomeIcons.penToSquare)),
                    Tab(icon: Icon(FontAwesomeIcons.camera)),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Manual entry form (existing UI)
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight - 16),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            Transactions(
                                onclick: () {
                                  showcategorydialog();
                                },
                                icons: FontAwesomeIcons.plus,
                                hintText: 'category',
                                controller: categorycontroller),
                            const SizedBox(
                              height: 16,
                            ),
                            Transactions(
                                onclick: () {
                                  showPaymentMethodDialog();
                                },
                                icons: FontAwesomeIcons.wallet,
                                hintText: 'payment method',
                                controller: paymentMethodController),
                            const SizedBox(
                              height: 16,
                            ),
                            Transactions(
                                type: TextInputType.number,
                                onclick: () {},
                                icons: FontAwesomeIcons.dollarSign,
                                hintText: 'amount',
                                controller: amountcontroller),
                            const SizedBox(
                              height: 16,
                            ),
                            Transactions(
                                onclick: () {},
                                icons: FontAwesomeIcons.calendar,
                                hintText: '',
                                controller: datecontroller),
                            const SizedBox(
                              height: 16,
                            ),
                            Transactions(
                                onclick: () {},
                                icons: FontAwesomeIcons.pen,
                                hintText: 'memo',
                                controller: memocontroller),
                            const SizedBox(
                              height: 16,
                            ),
                            Transactions(
                                onclick: () {},
                                icons: FontAwesomeIcons.locationDot,
                                hintText: 'location (optional)',
                                controller: locationController),
                            const SizedBox(
                              height: 24,
                            ),
                            Authbutton(
                                colors: const Color.fromARGB(255, 218, 18, 3),
                                ontap: () {
                                  if (categorycontroller.text.isEmpty ||
                                      amountcontroller.text.isEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => const AlertDialog(
                                              backgroundColor: Colors.black,
                                              content: Text(
                                                'please enter the fields',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ));
                                    return;
                                  }
                                  FirebaseController().addData(
                                    categorycontroller.text,
                                    amountcontroller.text,
                                    datecontroller.text,
                                    memocontroller.text,
                                    location: locationController.text,
                                    paymentMethod: paymentMethodController.text,
                                    onBudgetAlert: (msg) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    },
                                  ).then((response) {
                                    if (response == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              backgroundColor: Colors.blue,
                                              content: Text(
                                                'transaction successfull',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )));
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Bottom()),
                                        (route) => false,
                                      );
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                content: Text(response),
                                              ));
                                    }
                                  });
                                  Provider.of<TransactionProvider>(context,
                                          listen: false)
                                      .fetchcategory(categorycontroller.text);
                                  Provider.of<TransactionProvider>(context,
                                          listen: false)
                                      .fetchamount(amountcontroller.text);
                                  Provider.of<TransactionProvider>(context,
                                          listen: false)
                                      .avlabalance();
                                  categorycontroller.clear();
                                  amountcontroller.clear();
                                  memocontroller.clear();
                                  locationController.clear();
                                  paymentMethodController.clear();
                                },
                                title: 'Save transaction',
                                textcolor: Colors.white),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Scan tab
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.camera,
                          color: Colors.white, size: 64),
                      const SizedBox(height: 20),
                      const Text(
                        'Scan bills to auto-fill and add expenses',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReceiptScannerScreen(),
                            ),
                          );
                          if (result is String) {
                            categorycontroller.text = result;
                          }
                        },
                        icon: const Icon(Icons.document_scanner),
                        label: const Text('Scan Receipt'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future showcategorydialog() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Center(
                  child: Text(
                'Expences',
                style: TextStyle(color: Colors.white),
              )),
              backgroundColor: Colors.black,
              content: SizedBox(
                height: 400,
                width: 400,
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                          itemCount: Expence.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemBuilder: (context, index) => InkWell(
                                onTap: () {
                                  onselectedexpenses(context, Expence[index]);
                                  Navigator.pop(context);
                                },
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Icon(
                                      Expence[index].icon,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      Expence[index].name.toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                              )),
                    ),
                    const Divider(),
                    const Text(
                      'Incomes',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Expanded(
                      child: GridView.builder(
                          itemCount: income.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemBuilder: (context, index) => InkWell(
                                onTap: () {
                                  onselecetedincomes(context, income[index]);
                                  Navigator.pop(context);
                                },
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Icon(
                                      income[index].icon,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      income[index].name.toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                              )),
                    )
                  ],
                ),
              ),
            ));
  }

  void onselectedexpenses(BuildContext context, Expensecategory expence) {
    setState(() {
      icon = expence.icon;
      textexpense = expence.name.toString();
      categorycontroller.text = textexpense;
    });
  }

  void onselecetedincomes(BuildContext context, Expensecategory income) {
    setState(() {
      icon = income.icon;
      textincome = income.name.toString();
      categorycontroller.text = textincome;
      print(categorycontroller.text);
    });
  }

  Future showPaymentMethodDialog() {
    final paymentMethods = [
      {'name': 'Card', 'icon': FontAwesomeIcons.creditCard},
      {'name': 'UPI', 'icon': FontAwesomeIcons.mobileScreen},
      {'name': 'Cash', 'icon': FontAwesomeIcons.moneyBill},
    ];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        content: SizedBox(
          height: 200,
          width: 300,
          child: GridView.builder(
            itemCount: paymentMethods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                setState(() {
                  paymentMethodController.text =
                      paymentMethods[index]['name'] as String;
                });
                Navigator.pop(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    paymentMethods[index]['icon'] as IconData,
                    color: Colors.green,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentMethods[index]['name'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
