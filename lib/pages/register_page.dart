import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test3/viewmodels/RegisterViewModel.dart';


class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final registerViewModel = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 82, 71, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              height: 420,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('First Name'),
                  TextField(
                    onChanged: (value) {
                      registerViewModel.firstName = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'John',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Last Name'),
                  TextField(
                    onChanged: (value) {
                      registerViewModel.lastName = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Doe',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Email Address'),
                  TextField(
                    onChanged: (value) {
                      registerViewModel.email = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'example@email.com',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Password'),
                  TextField(
                    onChanged: (value) {
                      registerViewModel.password = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'pass123!',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 284,
                    child: ElevatedButton(
                      onPressed: () {
                        registerViewModel.register(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(183, 40, 31, 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: registerViewModel.isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Create Account',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  if (registerViewModel.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        registerViewModel.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
