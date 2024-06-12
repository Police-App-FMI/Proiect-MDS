import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:police_app/api/constants.dart';
import 'package:police_app/main.dart';
import 'package:police_app/models/individ.dart';
import 'package:police_app/models/autovehicul.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// Widget pentru recunoaștere facială
class FaceRecognition extends StatefulWidget {
  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognition> {
  File? _imageFile; // Fișierul imaginii selectate
  String errorMessage = ''; // Mesaj de eroare
  Individ? individ; // Modelul persoanei recunoscute
  bool showMasini = false; // Afișează/ascunde lista de mașini
  int? selectedMasinaIndex; // Indexul mașinii selectate

  // Funcție pentru selectarea imaginii din galerie
  Future<void> _pickImageGallery() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
        individ = null;
        errorMessage = '';
      });
      _uploadImage(_imageFile!); // Încarcă imaginea selectată
    }
  }

  // Funcție pentru capturarea imaginii cu camera
  Future<void> _pickImageCamera() async {
    final result = await ImagePicker().pickImage(source: ImageSource.camera);
    if (result != null) {
      setState(() {
        _imageFile = File(result.path);
        individ = null;
        errorMessage = '';
      });
      _uploadImage(_imageFile!); // Încarcă imaginea capturată
    }
  }

  // Funcție pentru încărcarea imaginii pe server
  Future<void> _uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST', Uri.https(Constant.url, '/api/Face')
    );
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', 'jpg'), 
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      var jsonResponse = await response.stream.bytesToString();
      if (jsonResponse.isNotEmpty) {
        try {
          var data = json.decode(jsonResponse);
          setState(() {
            individ = Individ.fromJson(data); // Actualizează modelul persoanei recunoscute
            errorMessage = '';
          });
        } catch (e) {
          setState(() {
            errorMessage = 'Eroare la parsarea răspunsului de la server.';
            individ = null;
          });
        }
      }
    } else {
      setState(() {
        errorMessage = response.reasonPhrase == "Imaginea nu a ajuns la API"
            ? 'Eroare la server! Va rugam reveniti mai tarziu!'
            : 'Persoana nu este cunoscuta! Incercati din nou';
        individ = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Face Recognition'),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamed(context, 'home'); // Navighează la pagina principală
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImageGallery, // Buton pentru selectarea imaginii din galerie
                            icon: Icon(Icons.photo),
                            label: Text('Gallery'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickImageCamera, // Buton pentru capturarea imaginii cu camera
                            icon: Icon(Icons.camera_alt),
                            label: Text('Camera'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (_imageFile != null)
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              _imageFile!,
                              width: 300,
                              height: 300,
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      if (_imageFile != null && individ == null && errorMessage.isEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Se incarca datele despre persoana',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 20),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(), // Indicator de încărcare
                            ),
                          ],
                        ),
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage, // Afișează mesajul de eroare
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      if (individ != null)
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detalii individ:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text('CNP: ${individ!.cnp}'), // Afișează CNP-ul persoanei
                                Text('Nume: ${individ!.nume}'), // Afișează numele persoanei
                                Text('Permis Validare: ${individ!.permis_Validare}'), // Afișează starea permisului
                                Text('Data Nastere: ${individ!.data_Nastere.year}/${individ!.data_Nastere.month}/${individ!.data_Nastere.day}'), // Afișează data nașterii
                                Text('Adresa Domiciliu: ${individ!.adresa_Domiciliu}'), // Afișează adresa de domiciliu
                                GestureDetector(
                                  onTap: individ!.masinile != null && individ!.masinile!.isNotEmpty
                                      ? () {
                                          setState(() {
                                            showMasini = !showMasini;
                                            selectedMasinaIndex = null;
                                          });
                                        }
                                      : null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      AnimatedDefaultTextStyle(
                                        duration: Duration(milliseconds: 300),
                                        style: TextStyle(
                                          color: (individ!.masinile != null && individ!.masinile!.isNotEmpty)
                                              ? (showMasini ? Colors.blue : Colors.black)
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        child: Text('Masini:'), // Titlu pentru secțiunea de mașini
                                      ),
                                      if (individ!.masinile == null || individ!.masinile!.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            'Nu are nicio masina inregistrata.',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (showMasini && individ?.masinile != null)
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    height: showMasini ? 200.0 : 0.0,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: individ!.masinile!.length,
                                      itemBuilder: (context, index) {
                                        final masina = individ!.masinile![index];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedMasinaIndex = selectedMasinaIndex == index ? null : index;
                                            });
                                          },
                                          child: Card(
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
                                                    'Numar de Inmatriculare: ${masina.nrInmatriculare}',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  if (selectedMasinaIndex == index) ...[
                                                    SizedBox(height: 10),
                                                    Text('Data Achizitie: ${masina.dataAchizitie.year}/${masina.dataAchizitie.month}/${masina.dataAchizitie.day}'), // Afișează data achiziției
                                                    Text('Kilometraj: ${masina.kilometraj}'), // Afișează kilometrajul
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
