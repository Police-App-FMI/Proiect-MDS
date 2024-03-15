import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';

class Login extends StatelessWidget{
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[800]!,
              Colors.blue[400]!
            ]
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Login", style: TextStyle(color: Colors.white, fontSize: 40)),
                    SizedBox(height: 10),
                    const Text("Welcome Back", style: TextStyle(color: Colors.white, fontSize: 18))

                ],
              )
            ),
            SizedBox(height: 20,),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 60,),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(
                            color: Color.fromRGBO(29, 82, 216, 0.98),
                            blurRadius: 20,
                            offset: Offset(0, 10)
                          )]
                        ),
                      ),
                      Form(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                              ),
                              child: TextFormField(
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                autocorrect: false,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!EmailValidator.validate(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                              ),
                              child: TextFormField(
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  } else if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),
                      Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 40),
                      InkWell(
                        onTap:() => {
                          Navigator.pushReplacementNamed(context, 'home')
                        },
                        child: Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.blue[900]
                        ),
                        child: Center(
                          child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                        )
                      ),
                      )
                    ],
                  )
                )
              )
            )
          ],
        )
      )
    );
  }
}