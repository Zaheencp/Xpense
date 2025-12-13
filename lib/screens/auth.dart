import 'package:flutter/material.dart';
import 'package:xpense/screens/home.dart';
import 'package:xpense/screens/login.dart';
import 'package:xpense/screens/signup.dart';
import 'package:xpense/screens/widgets/authbutton.dart';

class Authentication extends StatelessWidget {
  const Authentication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 9, 236, 206)),
          ),
          Positioned(
              top: 350,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 500,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    const Text(''),
                    const SizedBox(
                      height: 30,
                    ),
                    Authbutton(
                      colors: const Color.fromARGB(255, 9, 236, 209),
                      ontap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Signup()));
                      },
                      title: 'Sign Up',
                      textcolor: Colors.white,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Authbutton(
                      colors: const Color.fromARGB(255, 9, 236, 209),
                      ontap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Loginpage()));
                      },
                      title: 'Login',
                      textcolor: Colors.white,
                    )
                  ],
                ),
              )),
          const Positioned(
              top: 140,
              left: 110,
              child: Text(
                'Xpense',
                style: TextStyle(fontSize: 30),
              )),
          const Positioned(
              top: 180, left: 160, child: Text('Track Your Expense...')),
          Positioned(
              right: 20,
              top: 40,
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Myhome()));
                  },
                  child: const Text('Skip')))
        ],
      ),
    );
  }
}
