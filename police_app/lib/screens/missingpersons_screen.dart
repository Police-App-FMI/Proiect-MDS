import 'package:flutter/material.dart';
import 'package:police_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MissingPersonsScreen extends StatefulWidget {
  @override
  _MissingPersonsScreenState createState() => _MissingPersonsScreenState();
}

class _MissingPersonsScreenState extends State<MissingPersonsScreen> with WidgetsBindingObserver {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _lastSeenLocationController = TextEditingController();
  final TextEditingController _updateLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<User_provider>(context, listen: false).fetchMissingPersons();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _profilePicController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _lastSeenLocationController.dispose();
    _updateLocationController.dispose();
    super.dispose();
  }

  void _addMissingPerson() async {
    if (_nameController.text.isNotEmpty &&
        _profilePicController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _lastSeenLocationController.text.isNotEmpty) {
      await Provider.of<User_provider>(context, listen: false).addMissingPerson(
        _nameController.text,
        _profilePicController.text,
        _descriptionController.text,
        _phoneController.text,
        _lastSeenLocationController.text,
      );
      _nameController.clear();
      _profilePicController.clear();
      _descriptionController.clear();
      _phoneController.clear();
      _lastSeenLocationController.clear();
    }
  }

  void _updatePersonLocation(String id) async {
    if (_updateLocationController.text.isNotEmpty) {
      await Provider.of<User_provider>(context, listen: false)
          .updateMissingPersonLocation(id, _updateLocationController.text);
      _updateLocationController.clear();
    }
  }

  void _deletePerson(String id) async {
    await Provider.of<User_provider>(context, listen: false).deleteMissingPerson(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Missing Persons'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, 'home');
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _profilePicController,
                    decoration: InputDecoration(
                      labelText: 'Profile Pic URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _lastSeenLocationController,
                    decoration: InputDecoration(
                      labelText: 'Last Seen Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addMissingPerson,
                    child: Text('Add Missing Person'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<User_provider>(
                builder: (context, userProvider, child) {
                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: userProvider.missingPersons.length,
                    itemBuilder: (context, index) {
                      var person = userProvider.missingPersons[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(person['Portret']),
                          ),
                          title: Text(
                            person['Nume'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            person['Descriere'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(person['Nume']),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(person['Portret']),
                                        SizedBox(height: 10),
                                        Text(
                                          'Description:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(person['Descriere']),
                                        SizedBox(height: 10),
                                        Text(
                                          'Phone:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(person['Telefon']),
                                        SizedBox(height: 10),
                                        Text(
                                          'Last Seen Location:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Last Seen Date:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(person['UltimaData']),
                                        SizedBox(height: 10),
                                        TextField(
                                          controller: _updateLocationController,
                                          decoration: InputDecoration(
                                            labelText: 'Update Location',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _updatePersonLocation(person['Id']);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Update Location'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _deletePerson(person['Id']);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Delete'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
