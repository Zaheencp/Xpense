// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:xpense/controllers/firebasecontroller.dart';

// class Listtilepage extends StatelessWidget { 
 
//    Listtilepage({super.key,});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<FirebaseController>(builder: (context, value, child) {
//         return  Center(
//           child: ElevatedButton(onPressed: (){
//             value.getcollectiondocumentid();
//             Navigator.pop(context);
//           }, child: Icon(Icons.delete)),
//         );
//       },
        
//       ),
//     );
//   }
// }