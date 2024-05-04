import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/ui/screens/auth/auth_screen.dart';

class SignupComponent extends StatefulWidget {
  const SignupComponent({super.key});

  @override
  State<SignupComponent> createState() => _SignupComponentState();
}

class _SignupComponentState extends State<SignupComponent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalId = TextEditingController();
  final AutovalidateMode _validate = AutovalidateMode.disabled;
  final GlobalKey<FormState> _key = GlobalKey();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore users = FirebaseFirestore.instance;
  bool isActive = false;

  Future<void> register(
      String email, String pass, String nationalId, String name) async {
    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: pass)
        .then((value) async {
      if (value.user!.uid.isNotEmpty) {
        print('user id ================== ${value.user!.uid}');
        await users.collection('users').doc(value.user!.uid).set({
          'name': name,
          'email': email,
          'nationalId': nationalId,
          'isActive': isActive
        }).then((value) => {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const AuthScreen()),
                  (Route<dynamic> route) => false)
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      autovalidateMode: _validate,
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 32.0, right: 16.0, left: 16.0),
            child: Text(
              'Register',
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
              child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  controller: _nameController,
                  style: const TextStyle(fontSize: 18.0),
                  keyboardType: TextInputType.text,
                  cursorColor: Color(COLOR_PRIMARY),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    hintText: 'Full name',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  )),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
              child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  controller: _nationalId,
                  maxLength: 14,
                  style: const TextStyle(fontSize: 18.0),
                  keyboardType: TextInputType.number,
                  cursorColor: Color(COLOR_PRIMARY),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    hintText: 'National Id',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  )),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
              child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                  controller: _emailController,
                  style: const TextStyle(fontSize: 18.0),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color(COLOR_PRIMARY),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    hintText: 'Email Address',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  )),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
              child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: _passwordController,
                  obscureText: true,
                  validator: validatePassword,
                  onFieldSubmitted: (password) {
                    //_login();
                  },
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 18.0),
                  cursorColor: Color(COLOR_PRIMARY),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    hintText: 'Password',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Color(COLOR_PRIMARY), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(COLOR_PRIMARY),
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (_emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please Enter Your email'),
                      ),
                    );
                  } else if (_passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please Enter Your password'),
                      ),
                    );
                  } else if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please Enter Your name'),
                      ),
                    );
                  } else if (_nationalId.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your National id required'),
                      ),
                    );
                  } else {
                    await register(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _nationalId.text.trim(),
                        _nameController.text.trim());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
