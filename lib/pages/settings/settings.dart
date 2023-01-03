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
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text("Profile"),
      //   elevation: 0,
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300.0,
              width: double.maxFinite,
              color: Colors.tealAccent,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50.0,
                          color: Colors.teal,
                        ),
                      ),
                      Text(
                        "My Profile".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(12.0),
                height: 120,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      offset: Offset(6, 6),
                      blurRadius: 8.0,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: Colors.teal,
                      size: 50,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Business Name",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FutureBuilder<String>(
                              future: context
                                  .watch<Authentication>()
                                  .getOfflineBusinessName(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    "...",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  );
                                }
                                return Text(
                                  snapshot.data ?? "",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const OfflineBusinessNameForm(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 30,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OfflineBusinessNameForm extends StatefulWidget {
  const OfflineBusinessNameForm({
    Key? key,
  }) : super(key: key);

  @override
  State<OfflineBusinessNameForm> createState() =>
      OfflineBusinessNameFormState();
}

class OfflineBusinessNameFormState extends State<OfflineBusinessNameForm> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    context.read<Authentication>().getOfflineBusinessName().then(
          (value) => setState(() => _nameController.text = value),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Business Name"),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 200.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: const Offset(4, 4),
                blurRadius: 8.0,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintMaxLines: 5,
                      hintText: "Enter business Name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      context
                          .read<Authentication>()
                          .setOfflineBusinessName(_nameController.text)
                          .then((value) => Navigator.of(context).pop());
                    }
                  },
                  color: Colors.teal,
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
