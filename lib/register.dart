import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather_app/login.dart';

class Myregistration extends StatefulWidget {
  const Myregistration({super.key});

  @override
  State<Myregistration> createState() => _MyregistrationState();
}

class _MyregistrationState extends State<Myregistration> {
  bool visible = true;
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _cpass = TextEditingController();
  final _birthday = TextEditingController();
  Future registration() async {
    if (_password.text == _cpass.text) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _email.text.trim(), password: _password.text.trim())
          .then((value) {})
          .catchError((error) {
            print(error.toString());
          })
          .then((value) =>
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Registration Sucessfull!!"),
                duration: Duration(seconds: 2),
              )))
          .catchError((error) =>
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Fauld to Registration!!"),
                duration: Duration(seconds: 2),
              )));

      addUserDetails();
    }
  }

  Future addUserDetails() async {
    await FirebaseFirestore.instance.collection("Users").add({
      'email': _email.text.trim(),
      'fullname': _username.text.trim(),
      'birthday': _birthday.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Register With Us",
            style: GoogleFonts.paytoneOne(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Lottie.asset("assets/animations/weather.json"),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 400,
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _email,
                    decoration: InputDecoration(
                        label: Text("Enter Email"),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email)),
                  ),
                ),
                Container(
                  width: 400,
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _phone,
                    decoration: InputDecoration(
                        label: Text("enter phane number"),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone)),
                  ),
                ),
                Container(
                  width: 400,
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _username,
                    decoration: InputDecoration(
                        label: Text("enter name"),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone)),
                  ),
                ),
                Container(
                  width: 400,
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _birthday,
                    decoration: InputDecoration(
                        label: Text("enter birthdate"),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake)),
                  ),
                ),
                Container(
                  width: 400,
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _password,
                    obscureText: visible,
                    decoration: InputDecoration(
                        label: Text("Enter password"),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                visible = !visible;
                              });
                            },
                            icon: Icon(visible
                                ? Icons.visibility
                                : Icons.visibility_off))),
                  ),
                ),
                Container(
                  width: 400,
                  margin: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _cpass,
                    obscureText: visible,
                    decoration: InputDecoration(
                        label: Text("confirm password"),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                visible = !visible;
                              });
                            },
                            icon: Icon(visible
                                ? Icons.visibility
                                : Icons.visibility_off))),
                  ),
                ),
                ElevatedButton(
                  child: Text("Register Me"),
                  onPressed: () {
                    registration();
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("go back to login page "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Mylogin()));
                      },
                      child: Text(
                        "here",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
