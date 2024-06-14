import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:police_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CallReinforcementsScreen extends StatefulWidget {
  @override
  _CallReinforcementsScreenState createState() => _CallReinforcementsScreenState();
}

class _CallReinforcementsScreenState extends State<CallReinforcementsScreen> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  final TextEditingController _messageController = TextEditingController();
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<User_provider>(context, listen: false).fetchReinforcements();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    super.dispose();
  }

  void _sendReinforcement() async {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _isAnimating = true;
      });

      // Get userName and location from User_provider
      String location = Provider.of<User_provider>(context, listen: false).location ?? 'Unknown';

      // Call reinforcements
      await Provider.of<User_provider>(context, listen: false)
          .callReinforcements(_messageController.text, location);

      _messageController.clear(); // Clear the input field

      // Stop animation after sending the reinforcement
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Reinforcements'),
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Alert Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: _isAnimating ? Colors.red : Colors.blue,
                        ),
                        onPressed: _sendReinforcement,
                        child: Text(
                          '!!SOS!!',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<User_provider>(
                builder: (context, userProvider, child) {
                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: userProvider.reinforcements.length,
                    itemBuilder: (context, index) {
                      var reinforcement = userProvider.reinforcements[index];
                      bool isUserReinforcement = reinforcement['Nume'] == userProvider.userName;
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: ExpansionTile(
                          title: Text(
                            reinforcement['Nume'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            reinforcement['Mesaj'],
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: isUserReinforcement
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await userProvider.endReinforcement(reinforcement['Id']);
                                  },
                                )
                              : null,
                          children: [
                            Container(
                              height: 200,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _getLatLngFromLocation(reinforcement['Location']),
                                  zoom: 15,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId(reinforcement['Id']),
                                    position: _getLatLngFromLocation(reinforcement['Location']),
                                    infoWindow: InfoWindow(
                                      title: reinforcement['Nume'],
                                      snippet: reinforcement['Mesaj'],
                                    ),
                                  ),
                                },
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                },
                              ),
                            ),
                          ],
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

  LatLng _getLatLngFromLocation(String location) {
    List<String> coordinates = location.split(',');
    double latitude = double.parse(coordinates[0].split(':')[1].trim());
    double longitude = double.parse(coordinates[1].split(':')[1].trim());
    return LatLng(latitude, longitude);
  }
}
