import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xpirax/data/business.dart';
import 'package:xpirax/data/user.dart';
import 'package:xpirax/providers/web_database_providers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await launchUrl(Uri.parse("https://xpirax.com")).then((value) {
                if (value == false) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        "Error".toUpperCase(),
                        style: const TextStyle(color: Colors.red),
                      ),
                      content: const Text(
                          "Unable to complete this action, visit our website at www.xpirax.com for more information"),
                      actions: [
                        MaterialButton(
                          onPressed: () => Navigator.of(context).pop(),
                          color: Colors.teal,
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              });
            },
            icon: const Icon(Icons.edit),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                elevation: 8.0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      color: Colors.tealAccent,
                      child: Text(
                        "Account Information".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder<Business?>(
                        future: context
                            .watch<Authentication>()
                            .getBusinessDetails(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.name!.isEmpty) {
                            return Text("No Name");
                          }
                          return Column(
                            children: [
                              Image.network(
                                snapshot.data!.logo!,
                                height: 150,
                                width: 150,
                              ),
                              Text(
                                snapshot.data!.name!.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                snapshot.data!.address!,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 8.0,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      color: Colors.tealAccent,
                      child: Text(
                        "User Information".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder<User?>(
                        future:
                            context.watch<Authentication>().getUserDetails(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.fullName.isEmpty) {
                            return Text("No Name");
                          }
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot.data!.fullName.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot.data!.email,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot.data!.mobileNumber,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Role: ${snapshot.data!.isOwner ? 'Owner' : 'staff'}",
                                ),
                              ),
                            ],
                          );
                        },
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
