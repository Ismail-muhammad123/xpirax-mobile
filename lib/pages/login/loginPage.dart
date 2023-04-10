import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  String _error = "";

  _login() async {
    setState(() {
      _loading = true;
    });
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (err, _) {
      setState(() {
        _loading = false;
      });
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          icon: Icon(Icons.error),
          content: Text("Invalid Username of Password"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: SizedBox(
          height: 300,
          child: Card(
            elevation: 8.0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login".toUpperCase(),
                    style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const Divider(),
                  const Spacer(),
                  TextFormField(
                    enabled: !_loading,
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      label: Text("username"),
                      hintText: "Your email is your username",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  TextFormField(
                    enabled: !_loading,
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text("password"),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const Spacer(),
                  _loading
                      ? const CircularProgressIndicator(
                          color: Colors.teal,
                        )
                      : MaterialButton(
                          onPressed: _login,
                          color: Colors.teal,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
