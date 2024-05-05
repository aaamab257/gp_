import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/helpers/helpers.dart';
import 'package:graduation_project/ui/components/contact_with_admin.dart';
import 'package:graduation_project/ui/components/not_active_component.dart';
import 'package:graduation_project/ui/screens/dashboard/dashboard_screen.dart';

class LoginComponent extends StatefulWidget {
  const LoginComponent({super.key});

  @override
  State<LoginComponent> createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AutovalidateMode _validate = AutovalidateMode.disabled;
  final GlobalKey<FormState> _key = GlobalKey();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<void> _login(String email, String pass) async {
    await auth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((value) => {
              if (value.user != null)
                {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(value.user!.uid)
                      .get()
                      .then((DocumentSnapshot doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    bool isActive = data['isActive'];
                    if (isActive) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => DashboardScreen(
                                  name: data['name'], uid: value.user!.uid)),
                          (Route<dynamic> route) => false);
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                      showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        enableDrag: false,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.6,
                              child: const NotActiveComponent(),
                            ),
                          );
                        },
                      ).then((value) => setState(() {}));
                    }
                  })
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
              'Sign In',
              style: TextStyle(
                  color: COLOR_PRIMARY,
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
                  validator: validateEmail,
                  controller: _emailController,
                  style: const TextStyle(fontSize: 18.0),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: COLOR_PRIMARY,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    hintText: 'Email Address',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: COLOR_PRIMARY, width: 2.0)),
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
                  cursorColor: COLOR_PRIMARY,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    hintText: 'Password',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: COLOR_PRIMARY, width: 2.0)),
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
            padding: const EdgeInsets.only(top: 16, right: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    enableDrag: false,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          child: const ContactWithAdmin(),
                        ),
                      );
                    },
                  ).then((value) => setState(() {}));
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: COLOR_PRIMARY,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(
                      color: COLOR_PRIMARY,
                    ),
                  ),
                ),
                child:  isLoading ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children:  [
                    Text('Loading...', style: TextStyle(fontSize: 20,color: Colors.white,),), 
                  SizedBox(width: 10,), 
                   CircularProgressIndicator(color: Colors.white,), 
                  ],
                ) : const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  if (_emailController.text.isEmpty) {
                  } else if (_passwordController.text.isEmpty) {
                  } else {
                    _login(_emailController.text.trim(),
                        _passwordController.text.trim());
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
