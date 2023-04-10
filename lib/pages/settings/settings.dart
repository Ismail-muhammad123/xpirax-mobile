import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var profileInfo = {};
  String profileID = "";

  @override
  void initState() {
    FirebaseFirestore.instance.collection('profile').get().then(
          (value) => setState(
            () {
              profileID = value.docs.first.id;
              profileInfo = value.docs.first.data();
            },
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text("Profile"),
      //   elevation: 0,
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OfflineBusinessNameForm(
                name: profileInfo['businessName'],
                email: profileInfo['email'],
                phone: profileInfo['phone'],
                address: profileInfo['address'],
                id: profileID,
              ),
            ),
          );
        },
        child: Icon(Icons.edit),
      ),
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
                        "Profile".toUpperCase(),
                        style: const TextStyle(
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
              padding: EdgeInsets.all(8),
            ),
            const Text(
              "Business Name",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('profile').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "...",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  );
                }
                return Text(
                  snapshot.data!.docs.first.data()['businessName'] ?? "",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Divider(),
            ),
            const Text(
              "Business Address",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('profile').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "...",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  );
                }
                return Text(
                  snapshot.data!.docs.first.data()['address'] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Divider(),
            ),
            const Text(
              "Business Phone Number",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('profile').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "...",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  );
                }
                return Text(
                  snapshot.data!.docs.first.data()['phone'] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Divider(),
            ),
            const Text(
              "Business Email",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('profile').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "...",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  );
                }
                return Text(
                  snapshot.data!.docs.first.data()['email'] ?? "",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Divider(),
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineBusinessNameForm extends StatefulWidget {
  final String name, email, address, phone, id;
  const OfflineBusinessNameForm({
    required this.address,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    Key? key,
  }) : super(key: key);

  @override
  State<OfflineBusinessNameForm> createState() =>
      OfflineBusinessNameFormState();
}

class OfflineBusinessNameFormState extends State<OfflineBusinessNameForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _updating = false;

  @override
  void initState() {
    FirebaseFirestore.instance.collection('profile').get().then(
          (value) => setState(() {
            _nameController.text = value.docs.first.data()['businessName'];
            _emailController.text = value.docs.first.data()['email'];
            _phoneController.text = value.docs.first.data()['phone'];
            _addressController.text = value.docs.first.data()['address'];
          }),
        );
    super.initState();
  }

  _updateInfo() async {
    setState(() => _updating = true);
    await FirebaseFirestore.instance
        .collection('profile')
        .doc(widget.id)
        .update({
      "businessName": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "address": _addressController.text.trim(),
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Business Name"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        label: Text("Business Name"),
                        hintText: "Enter business Name",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        label: Text("Address"),
                        hintText: "Address",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        label: Text("Email"),
                        hintText: "Enter business Email (optional)",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        label: Text("Phone Number"),
                        hintText: "Phone Number",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: _updating ? null : _updateInfo,
                  color: Colors.teal,
                  child: _updating
                      ? const CircularProgressIndicator()
                      : const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
