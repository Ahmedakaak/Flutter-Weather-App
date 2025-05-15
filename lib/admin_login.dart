import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/admin_function.dart';
import 'package:weather_app/register.dart';

class adminlogin extends StatefulWidget {
  const adminlogin({super.key});

  @override
  State<adminlogin> createState() => _adminloginState();
}

class _adminloginState extends State<adminlogin> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool visible = true;

  Future signin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(), password: _password.text.trim());
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AdminPage()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An unexpectoed error occrred. Please try again"),
        backgroundColor: Colors.red,
      ));
    }
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
                ElevatedButton(
                  child: Text("Login"),
                  onPressed: () {
                    signin();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AdminPage()));
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't hava account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Myregistration()));
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