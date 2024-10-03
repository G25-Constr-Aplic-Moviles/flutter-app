import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Image.asset('assets/images/logo.png',
        width: 150,
          height: 150,),
        Container(
          padding: const EdgeInsets.all(15.0),
          height: 400,
          width: 284,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Login to your account', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,),),
              const SizedBox(height: 40),

              const Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[Text('Email Address',),],),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'example@email.com',),
              ), const SizedBox(height: 10),

              const Row (crossAxisAlignment: CrossAxisAlignment.start ,
                  children: [Text('First Name',),]),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'John',),
              ), const SizedBox(height: 10),

              const SizedBox(height: 20),
              SizedBox(
                width: 284,
                child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(183, 40, 31, 1),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),),
                child: const Text('Login',
                    style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              RichText(text: TextSpan(
                text: 'New to GastroAndes? ',
                style: const TextStyle(color: Colors.black, fontFamily: 'Gidugu'),
                children: [
                  TextSpan(
                    text: 'Sign up',
                    style: const TextStyle(color: Colors.blue, fontFamily: 'Gidugu'),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Acción al presionar "Sign up"
                      },
                  ),
                ],
              ),),
            ],
          ),
        ),
        ],
      ),
    )
    );
  }
}
