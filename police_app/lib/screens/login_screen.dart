import 'package:flutter/material.dart'; // Importă pachetul Flutter pentru componente UI.
import 'package:flutter/services.dart'; // Importă pachetul Flutter pentru servicii de sistem.
import 'package:email_validator/email_validator.dart'; // Importă pachetul pentru validarea emailurilor.
import 'package:police_app/providers/user_provider.dart'; // Importă pachetul personalizat pentru gestionarea utilizatorilor.
import 'package:provider/provider.dart'; // Importă pachetul pentru gestionarea stării aplicației.

class Login extends StatelessWidget {
  Widget build(BuildContext context) {
    final userProvider = Provider.of<User_provider>(context); // Obține instanța de User_provider din context.
    TextEditingController emailController = TextEditingController(); // Controller pentru câmpul de text al emailului.
    TextEditingController passwordController = TextEditingController(); // Controller pentru câmpul de text al parolei.
    return Scaffold(
        body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.blue[900]!,
              Colors.blue[800]!,
              Colors.blue[400]!
            ])), // Setează un gradient de fundal albastru pentru container.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 80,
                ),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text("Login",
                            style:
                                TextStyle(color: Colors.white, fontSize: 40)), // Textul principal de login.
                        SizedBox(height: 10),
                        const Text("Welcome Back",
                            style: TextStyle(color: Colors.white, fontSize: 18)) // Textul secundar de întâmpinare.
                      ],
                    )),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60),
                                topRight: Radius.circular(60))), // Setează colțurile rotunjite pentru container.
                        child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 60,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color.fromRGBO(
                                                29, 82, 216, 0.98),
                                            blurRadius: 20,
                                            offset: Offset(0, 10)) // Setează umbra pentru container.
                                      ]),
                                ),
                                Form(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]!))), // Linie de jos pentru separarea câmpurilor.
                                        child: TextFormField(
                                          controller: emailController,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          autocorrect: false,
                                          keyboardType: TextInputType.emailAddress, // Tipul de tastatură pentru email.
                                          decoration: InputDecoration(
                                              hintText: "Email",
                                              hintStyle: TextStyle(color: Colors.grey),
                                              border: InputBorder.none), // Setează stilul pentru hint-ul câmpului.
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
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]!))), // Linie de jos pentru separarea câmpurilor.
                                        child: TextFormField(
                                          controller: passwordController,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          autocorrect: false,
                                          decoration: InputDecoration(
                                            hintText: "Password",
                                            hintStyle: TextStyle(color: Colors.grey),
                                            border: InputBorder.none, // Setează stilul pentru hint-ul câmpului.
                                          ),
                                          obscureText: true, // Ascunde textul introdus în câmpul de parolă.
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
                                      SizedBox(height: 40),
                                      InkWell(
                                        onTap: () => {
                                          userProvider.verifyLogin(
                                              context,
                                              emailController.text,
                                              passwordController.text) // Apelează funcția de verificare a autentificării.
                                        },
                                        child: Container(
                                            height: 50,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 50),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Colors.blue[900]), // Butonul de login cu colțuri rotunjite și fundal albastru.
                                            child: Center(
                                                child: Text("Login",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold)))) // Textul butonului de login.
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ))))
              ],
            )));
  }
}
