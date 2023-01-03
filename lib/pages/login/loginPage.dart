// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:xpirax/home.dart';
// import 'package:xpirax/providers/web_database_providers.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _loading = false;
//   String _error = "";

//   Future _login() async {
//     setState(() {
//       _loading = true;
//     });
//     await context
//         .read<Authentication>()
//         .login(_usernameController.text.trim(), _passwordController.text.trim())
//         .then(
//           (value) => value != null
//               ? Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                     builder: (context) => const HomePage(),
//                   ),
//                 )
//               : setState(
//                   () {
//                     _loading = false;
//                     _error = "Invalid Username of password";
//                   },
//                 ),
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.teal,
//       body: Center(
//         child: SizedBox(
//           height: 300,
//           child: Card(
//             elevation: 8.0,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Login".toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.teal,
//                       fontSize: 30,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   Text(
//                     _error,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                   const Divider(),
//                   const Spacer(),
//                   TextFormField(
//                     enabled: !_loading,
//                     controller: _usernameController,
//                     decoration: const InputDecoration(
//                       label: Text("username"),
//                       hintText: "Your email is your username",
//                       prefixIcon: Icon(Icons.person),
//                     ),
//                   ),
//                   TextFormField(
//                     enabled: !_loading,
//                     controller: _passwordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       label: Text("password"),
//                       prefixIcon: Icon(Icons.lock),
//                     ),
//                   ),
//                   const Spacer(),
//                   _loading
//                       ? const CircularProgressIndicator(
//                           color: Colors.teal,
//                         )
//                       : MaterialButton(
//                           onPressed: _login,
//                           color: Colors.teal,
//                           child: const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text(
//                               "Login",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
