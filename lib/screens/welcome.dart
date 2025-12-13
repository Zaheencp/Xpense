import 'package:flutter/material.dart';
import 'package:xpense/screens/login.dart';
import 'package:xpense/screens/signup.dart';
import 'package:xpense/screens/widgets/authbutton.dart';
import 'package:xpense/screens/widgets/textbutton.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(color: Colors.black),
          ),
          const Positioned(
              top: 140,
              left: 110,
              child: Text(
                'Xpense',
                style: TextStyle(
                    fontSize: 30, color: Colors.white, letterSpacing: 3),
              )),
          const Positioned(
              top: 180,
              left: 160,
              child: Text(
                'Track Your Expense...',
                style: TextStyle(color: Colors.white),
              )),
          Positioned(
              top: 270,
              left: 70,
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/welcome.png'),
                        fit: BoxFit.cover)),
              )),
          Positioned(
              bottom: 70,
              left: 50,
              child: Authbutton(
                  colors: const Color.fromARGB(255, 218, 18, 3),
                  ontap: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Loginpage()));
                  },
                  title: 'Get Started',
                  textcolor: Colors.white)),
          Positioned(
              bottom: 9,
              left: 90,
              child: Textbuttonwidget(
                  firsttext: 'Dont have an account?',
                  ontap: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Signup()));
                  },
                  buttontext: 'Sign Up'))
        ],
      ),
    );
  }
}
