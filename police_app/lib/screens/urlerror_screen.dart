import 'package:flutter/material.dart';
import 'package:police_app/api/constants.dart';
import 'package:police_app/main.dart';
import 'package:police_app/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class UrlError extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(29, 82, 216, 0.98),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("The server went down", 
                    style: TextStyle(
                      color: Colors.white
                    )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final snackBar = SnackBar(
                    content: Text('Loading...', style: TextStyle(color: Color.fromRGBO(29, 82, 216, 0.98)),),
                    backgroundColor: Colors.white,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  final response = await chatProvider.checkServerAvailability();

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  if (response == true) {
                    navigatorKey.currentState?.pushReplacementNamed('home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Connection failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    _urlController.text = "";
                  }
                },
                child: Text('Try to reconnect'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
