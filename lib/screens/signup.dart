import 'package:flutter/material.dart';
import 'package:xpense/services/firebase.dart';
import 'package:xpense/screens/login.dart';
import 'package:xpense/screens/widgets/authbutton.dart';
import 'package:xpense/screens/widgets/textbutton.dart';
import 'package:xpense/screens/widgets/textfieldwidget.dart';

class Signup extends StatelessWidget {
  Signup({super.key});
  final usernamecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 218, 18, 3),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.elliptical(20, 20))),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/auth.png'),
                            fit: BoxFit.cover)),
                  ),
                  const Text(
                    'Xpense',
                    style: TextStyle(
                        fontSize: 25, color: Colors.white, letterSpacing: 2),
                  ),
                  const Text(
                    'Track your expense and income easly!',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 550,
              decoration: const BoxDecoration(color: Colors.black),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Textfieldwidget(
                        controller: usernamecontroller,
                        hinttext: 'Username',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Textfieldwidget(
                          controller: emailcontroller, hinttext: 'Email'),
                      const SizedBox(
                        height: 20,
                      ),
                      Textfieldwidget(
                          controller: passwordcontroller,
                          hinttext: 'Password',
                          isPassword: true),
                      const SizedBox(
                        height: 20,
                      ),
                      Authbutton(
                        colors: const Color.fromARGB(255, 218, 18, 3),
                        ontap: () async {
                          String email = emailcontroller.text.trim();
                          String password = passwordcontroller.text.trim();

                          try {
                            showDialog(
                                context: context,
                                builder: (context) => const Center(
                                    child: CircularProgressIndicator()));

                            String? response = await FireBaseFunction()
                                .registeruser(email: email, password: password);

                            if (context.mounted) {
                              Navigator.pop(context); // Pop loading
                            }

                            if (response == null) {
                              // Success
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Registration Successful! Please Login.')));
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => Loginpage()));
                              }
                            } else {
                              // Error
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response)));
                              }
                            }
                          } catch (e) {
                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Registration failed: ${e.toString()}')));
                            }
                          }
                        },
                        title: 'REGISTER',
                        textcolor: Colors.white,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Textbuttonwidget(
                          firsttext: 'Already Register?',
                          ontap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Loginpage()));
                          },
                          buttontext: 'Login'),
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
}
