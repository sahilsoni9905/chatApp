import 'package:flutter/material.dart';
import 'package:whatsapp_clone/common/widgets/custom_button.dart';
import 'package:whatsapp_clone/features/auth/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Welcome to Whatsapp',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: size.height / 9,
            ),
            Image.asset(
              'assets/saah.png',
              height: 300,
              width: 300,
              fit: BoxFit.contain, // Adjust this as per your requirement
            ),
            SizedBox(
              height: size.height / 5,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text(
                'Read our Privacy Policy . Tap "Agree and continue" to accept all the terms and condition',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: CustomButton(
                  text: 'Agree and Continue',
                  onpressed: () => navigateToLoginScreen(context)),
            ),
          ],
        ),
      )),
    );
  }
}
