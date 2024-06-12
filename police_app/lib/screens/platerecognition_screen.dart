import 'dart:convert';
import 'package:flutter/material.dart'; // Importă pachetul Flutter pentru componente UI.
import 'package:image_picker/image_picker.dart'; // Importă pachetul pentru selectarea imaginilor.
import 'package:police_app/api/constants.dart'; // Importă constantele pentru API.
import 'package:police_app/main.dart'; // Importă fișierul principal al aplicației.
import 'package:police_app/models/autovehicul.dart'; // Importă modelul pentru Autovehicul.
import 'package:police_app/models/individ.dart'; // Importă modelul pentru Individ.
import 'package:file_picker/file_picker.dart'; // Importă pachetul pentru selectarea fișierelor.
import 'package:http_parser/http_parser.dart'; // Importă pachetul pentru parsarea tipurilor de fișiere HTTP.
import 'package:http/http.dart' as http; // Importă pachetul pentru efectuarea cererilor HTTP.
import 'dart:io'; // Importă biblioteca pentru manipularea fișierelor.

class PlateRecognition extends StatefulWidget {
  @override
  _PlateRecognitionScreenState createState() => _PlateRecognitionScreenState();
}

class _PlateRecognitionScreenState extends State<PlateRecognition> {
  File? _imageFile;
  String errorMessage = '';
  Autovehicul? masina;
  bool showProprietarDetails = false;

  // Funcție pentru selectarea unei imagini din galerie
  Future<void> _pickImageGallery() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
        masina = null;
        errorMessage = '';
      });
      _uploadImage(_imageFile!);
    }
  }

  // Funcție pentru selectarea unei imagini cu camera
  Future<void> _pickImageCamera() async {
    final result = await ImagePicker().pickImage(source: ImageSource.camera);
    if (result != null) {
      setState(() {
        _imageFile = File(result.path);
        masina = null;
        errorMessage = '';
      });
      _uploadImage(_imageFile!);
    }
  }

  // Funcție pentru încărcarea imaginii selectate
  Future<void> _uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST', Uri.https(Constant.url, '/api/Car')
    );
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', 'jpg'), // Specificăm tipul de conținut
    ));

    var response = await request.send();
    if(response.statusCode == 200) {
      var jsonResponse = await response.stream.bytesToString();
      if(jsonResponse.isNotEmpty) {
        try {
          var data = json.decode(jsonResponse);
          setState(() {
            masina = Autovehicul.fromJson(data);
            print(jsonResponse);
            errorMessage = '';
          });
        } catch(e) {
          setState(() {
            errorMessage = 'Eroare la parsarea răspunsului de la server.';
            masina = null;
          });
        } 
      }
      
    } 
    else {
      setState(() {
        errorMessage = response.reasonPhrase == "Imaginea nu a ajuns la API"
            ? 'Eroare la server! Va rugam reveniti mai tarziu!'
            : 'Masina nu este inregistrata! Incercati din nou';
        masina = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, 'home'); // Navighează către pagina principală.
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Car Plate Recognition',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImageGallery,
                    icon: Icon(Icons.photo),
                    label: Text('Gallery'), // Buton pentru selectarea imaginii din galerie.
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImageCamera,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera'), // Buton pentru selectarea imaginii cu camera.
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_imageFile != null)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Image.file(
                          _imageFile!,
                          width: 300,
                          height: 300,
                        ), // Afișează imaginea selectată.
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20),
              if (_imageFile != null && masina == null && errorMessage.isEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Se incarca datele despre masina',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(), // Indicator de încărcare.
                    ),
                  ],
                ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Mesaj de eroare.
                ),
              if (masina != null)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalii masina:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Numar de Inmatriculare: ${masina!.nrInmatriculare}'),
                        Text('Data Achizitie: ${masina!.dataAchizitie.year}/${masina!.dataAchizitie.month}/${masina!.dataAchizitie.day}'),
                        Text('Kilometraj: ${masina!.kilometraj}'),
                        if (masina!.proprietar != null) // Verificăm dacă proprietarul nu este null.
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showProprietarDetails = !showProprietarDetails;
                              });
                            },
                            child: AnimatedDefaultTextStyle(
                              duration: Duration(seconds: 1),
                              style: TextStyle(
                                color: showProprietarDetails ? Colors.blue : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              child: Text(
                                'Proprietar: ${masina!.proprietar!.nume}',
                              ),
                            ),
                          ),
                        if (showProprietarDetails && masina!.proprietar != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [  
                              Text('CNP: ${masina!.proprietar!.cnp}'),
                              Text('Data Nastere: ${masina!.proprietar!.data_Nastere.year}/${masina!.proprietar!.data_Nastere.month}/${masina!.proprietar!.data_Nastere.day}'),
                              Text('Adresa Domiciliu: ${masina!.proprietar!.adresa_Domiciliu}'),
                              Text('Stare permis: ${masina!.proprietar!.permis_Validare}') // Detalii despre proprietar.
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
