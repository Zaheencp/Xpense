// import 'package:animated_button_bar/animated_button_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:xpense/models/categorymodel.dart';
// import 'package:xpense/models/firebasecloud.dart';
// import 'package:xpense/widgets/authbutton.dart';
// import 'package:xpense/widgets/transactions.dart';

// class Animatedbuttonbar extends StatefulWidget {
//   Animatedbuttonbar({
//     super.key,
//     required this.isincome,
//   });
//   bool isincome = true;

//   @override
//   State<Animatedbuttonbar> createState() => _AnimatedbuttonbarState();
// }

// class _AnimatedbuttonbarState extends State<Animatedbuttonbar> {
//   List<Expensecategory> income = Expensecategory.incomes;

//   List<Expensecategory> Expence = Expensecategory.expenses;

//   final incontroller = AnimatedButtonController();
//   final categorycontroller = TextEditingController();
//   final amountcontroller = TextEditingController();
//   final memocontroller = TextEditingController();
//   final datecontroller = TextEditingController();
//   final ecategorycontroller = TextEditingController();
//   final eamountcontroller = TextEditingController();
//   final ememocontroller = TextEditingController();
//   final edatecontroller = TextEditingController();
//   IconData? icon;
//   String textincome = '';
//   String textexpense = '';
//   String dateformat = DateTime.now().toLocal().toString().split(' ')[0];

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     showcategorydialog() {
//       return showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//                 title: Center(
//                     child: Text(
//                   'Expences',
//                   style: TextStyle(color: Colors.white),
//                 )),
//                 backgroundColor: Colors.black,
//                 content: Container(
//                   height: 400,
//                   width: 400,
//                   child: GridView.builder(
//                       itemCount: Expence.length,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3),
//                       itemBuilder: (context, index) => InkWell(
//                             onTap: () {
//                               onselectedexpenses(
//                                 context,
//                                 Expence[index],
//                               );
//                               Navigator.of(context).pop();
//                             },
//                             child: Container(
//                               child: Column(
//                                 children: [
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Icon(
//                                     Expence[index].icon,
//                                     color: Colors.red,
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Text(
//                                     Expence[index].name,
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 10),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )),
//                 ),
//               ));
//     }

//     showincomecategory() {
//       return showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//                 title: Center(
//                     child: Text(
//                   'incomes',
//                   style: TextStyle(color: Colors.white),
//                 )),
//                 backgroundColor: Colors.black,
//                 content: Container(
//                   height: 400,
//                   width: 400,
//                   child: GridView.builder(
//                       itemCount: income.length,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3),
//                       itemBuilder: (context, index) => InkWell(
//                             onTap: () {
//                               onselecetedincomes(
//                                 context,
//                                 income[index],
//                               );

//                               Navigator.of(context).pop();
//                             },
//                             child: Container(
//                               child: Column(
//                                 children: [
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Icon(
//                                     income[index].icon,
//                                     color: Colors.blue,
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Text(
//                                     income[index].name,
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 10),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )),
//                 ),
//               ));
//     }

//     showcategoryincomedialog() {
//       setState(() {
//         datecontroller.text = dateformat;
//       });
//       return showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//               title: Center(
//                   child: Text(
//                 'Incomes',
//                 style: TextStyle(color: Colors.white),
//               )),
//               backgroundColor: Colors.black,
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Transactions(
//                       controller: categorycontroller,
//                       onclick: () {
//                         // showcategorydialog();
//                         showincomecategory();
//                       },
//                       icons: FontAwesomeIcons.plus,
//                       hintText: 'select category',
//                     ),
//                     SizedBox(
//                       height: size.height * 0.02,
//                     ),
//                     Transactions(
//                         controller: amountcontroller,
//                         type: TextInputType.number,
//                         onclick: () {},
//                         icons: FontAwesomeIcons.dollarSign,
//                         hintText: 'Enter amount'),
//                     SizedBox(
//                       height: size.height * 0.02,
//                     ),
//                     Transactions(
//                         onclick: () {},
//                         icons: FontAwesomeIcons.calendar,
//                         hintText: '',
//                         controller: datecontroller),
//                     SizedBox(
//                       height: size.height * 0.02,
//                     ),
//                     Transactions(
//                         controller: memocontroller,
//                         onclick: () {},
//                         icons: FontAwesomeIcons.pencil,
//                         hintText: 'Memo'),
//                     SizedBox(
//                       height: size.height * 0.02,
//                     ),
//                     Authbutton(
//                         colors: Color.fromARGB(255, 218, 18, 3),
//                         ontap: () {
//                           if (categorycontroller.text.isEmpty ||
//                               amountcontroller.text.isEmpty) {
//                             showDialog(
//                                 context: context,
//                                 builder: (context) => AlertDialog(
//                                       backgroundColor: Colors.black,
//                                       content: Text(
//                                         'please enter the fields',
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ));
//                           } else {
//                             Firebasecloud()
//                                 .addincometransactiontodb(
//                               categorycontroller.text,
//                               amountcontroller.text,
//                               datecontroller.text,
//                               memocontroller.text,
//                             )
//                                 .then((response) {
//                               if (response == null) {
//                                 ScaffoldMessenger.of(context)
//                                     .showSnackBar(SnackBar(
//                                         backgroundColor: Colors.blue,
//                                         content: Text(
//                                           'transaction successfull',
//                                           style: TextStyle(color: Colors.white),
//                                         )));
//                                 // showDialog(context: context, builder: (context)=>AlertDialog(content: Text('hh'),));
//                                 Navigator.pop(context);
//                               } else {
//                                 showDialog(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                           content: Text(response),
//                                         ));
//                               }
//                             });
//                           }
//                           // showDialog(context: context, builder: (context)=> AlertDialog(
//                           //   title: Text('transaction added succesfully'),
//                           // ));

//                           categorycontroller.clear();
//                           amountcontroller.clear();
//                           memocontroller.clear();
//                         },
//                         title: 'Save transaction',
//                         textcolor: Colors.white),
//                   ],
//                 ),
//               )));
//     }

//     showcategoryexpence() {
//       setState(() {
//         edatecontroller.text = dateformat;
//       });
//       return showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//               title: Center(
//                   child: Text(
//                 'Expense',
//                 style: TextStyle(color: Colors.white),
//               )),
//               backgroundColor: Colors.black,
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Transactions(
//                         controller: ecategorycontroller,
//                         onclick: () {
//                           showcategorydialog();
//                         },
//                         icons: FontAwesomeIcons.plus,
//                         hintText: 'select category'),
//                     SizedBox(
//                       height: size.height * 0.02,
//                     ),
//                     Transactions(
//                         controller: eamountcontroller,
//                         type: TextInputType.number,
//                         onclick: () {},
//                         icons: FontAwesomeIcons.dollarSign,
//                         hintText: 'Enter amount'),
//                     SizedBox(
//                       height: size.height * 0.02,
//                     ),
//                     Transactions(
//                         onclick: () {},
//                         icons: FontAwesomeIcons.calendar,
//                         hintText: '',
//                         controller: edatecontroller),
//                     SizedBox(
//                       height: size.height * 0.02,
//                     ),
//                     Transactions(
//                         controller: ememocontroller,
//                         onclick: () {},
//                         icons: FontAwesomeIcons.pencil,
//                         hintText: 'Memo'),
//                     SizedBox(
//                       height: size.height * 0.02,
//                     ),
//                     Authbutton(
//                         colors: Color.fromARGB(255, 218, 18, 3),
//                         ontap: () {
//                           if (ecategorycontroller.text.isEmpty ||
//                               eamountcontroller.text.isEmpty) {
//                             showDialog(
//                                 context: context,
//                                 builder: (context) => AlertDialog(
//                                       content: Text('please enter the fields'), 
//                                     ));
//                           } else {
//                             Firebasecloud()
//                                 .addexpensetodb(
//                                     ecategorycontroller.text,
//                                     eamountcontroller.text,
//                                     edatecontroller.text,
//                                     ememocontroller.text)
//                                 .then((response) {
//                               if (response == null) {
//                                 ScaffoldMessenger.of(context)
//                                     .showSnackBar(SnackBar(
//                                         backgroundColor: Colors.blue,
//                                         content: Text(
//                                           'transaction successfull',
//                                           style: TextStyle(color: Colors.white),
//                                         )));
//                                 // showDialog(context: context, builder: (context)=>AlertDialog(content: Text('hh'),));
//                                 Navigator.pop(context);
//                               } else {
//                                 showDialog(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                           content: Text(response),
//                                         ));
//                               }
//                             });
//                           }
                        
//                           ecategorycontroller.clear();
//                           eamountcontroller.clear();
//                           ememocontroller.clear();
//                         },
//                         title: 'Save transaction',
//                         textcolor: Colors.white),
//                   ],
//                 ),
//               )));
//     }

//     return Column(
//       children: [
//         AnimatedButtonBar(
//           controller: incontroller,
//           radius: 32.0,
//           padding: const EdgeInsets.all(16.0),
//           backgroundColor: Colors.grey,
//           foregroundColor: Colors.black,
//           elevation: 24,
//           borderColor: Colors.grey,
//           borderWidth: 2,
//           innerVerticalPadding: 16,
//           children: [
//             ButtonBarEntry(
//                 onTap: () {
//                   showcategoryincomedialog();
//                 },
//                 child: Text(
//                   'Income',
//                   style: TextStyle(color: Colors.white),
//                 )),
//             ButtonBarEntry(
//                 onTap: () {
//                   showcategoryexpence();
//                 },
//                 child: Text(
//                   'Expense',
//                   style: TextStyle(color: Colors.white),
//                 )),
//           ],
//         ),
//       ],
//     );
//   }

//   void onselectedexpenses(BuildContext context, Expensecategory expence) {
//     setState(() {
//       icon = expence.icon;
//       textexpense = expence.name;
//       ecategorycontroller.text = textexpense;
//     });
//   }

//   void onselecetedincomes(BuildContext context, Expensecategory income) {
//     setState(() {
//       icon = income.icon;
//       textincome = income.name;
//       categorycontroller.text = textincome;
//       print(categorycontroller.text);
//     });
//   }

//   @override
//   void dispose() {
//     categorycontroller.dispose();
//     // ecategorycontroller.dispose();
//     super.dispose();
//   }
// }
