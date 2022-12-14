import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/background.dart';
import 'package:flutterfirebase/screens/home_screen.dart';

import '../components/awesome_dialog.dart';
import 'login_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? timer;
  bool isEmailVerified = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Background(),
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                   Text(
                    "A verification email has been sent to your email.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 43, 91),
                      fontSize: size.width * .07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (!isEmailVerified) {
                        sendVerificationEmail();
                        timer =
                            Timer.periodic(const Duration(seconds: 3), (timer) {
                          checkEmailVerified();
                        });
                      }
                    },
                    icon: const Icon(Icons.email),
                    label: const Text("Resend Email"),
                  ),
                  TextButton(
                    onPressed: () {
                      timer!.cancel();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        checkEmailVerified();
      });
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false);
    }
  }

  checkEmailVerified() async{

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FirebaseAuth.instance.currentUser!.reload().then((value) {
          setState(() {
            isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
          });
          if (isEmailVerified) {
            timer!.cancel();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                    (route) => false);
          }
        }).catchError((e) {
          Navigator.pop(context);
          showAwesomeDialog(context, e.toString());
        });
      }
    } on SocketException{
      Navigator.pop(context);
      showAwesomeDialog(context, "No Internet Connection");
    }



  }

  Future sendVerificationEmail() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        await FirebaseAuth.instance.currentUser!
            .sendEmailVerification()
            .catchError((e) {
          Navigator.pop(context);
          showAwesomeDialog(context, e.toString());
        });
      }
    } on SocketException{
      Navigator.pop(context);
      showAwesomeDialog(context, "No Internet Connection");
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }
}
