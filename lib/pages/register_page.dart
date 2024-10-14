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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                height: 450,
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'John',
                      ),
                      onChanged: (value) {
                        registerViewModel.firstName = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Last Name'),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Doe',
                      ),
                      onChanged: (value) {
                        registerViewModel.lastName = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Email Address'),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'example@email.com',
                      ),
                      onChanged: (value) {
                        registerViewModel.email = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Password'),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'pass123!',
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        registerViewModel.password = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 284,
                      child: ElevatedButton(
                        onPressed: () async {
                          await registerViewModel.register(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(183, 40, 31, 1),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    if (registerViewModel.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            registerViewModel.errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
