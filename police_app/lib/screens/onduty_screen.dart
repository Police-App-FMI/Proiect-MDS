import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:police_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class OnDutyScreen extends StatefulWidget {
  @override
  _OnDutyScreenState createState() => _OnDutyScreenState();
}

class _OnDutyScreenState extends State<OnDutyScreen> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<User_provider>(context, listen: false).fetchOnDutyUsers();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, 'home');
          },
        ),
      ),
      body: Center(
        child: Consumer<User_provider>(
          builder: (context, userProvider, child) {
            _updateMarkers(userProvider.onDutyUsers);
            return Column(
              children: [
                Container(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 2,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                ),
                SizedBox(height:20),
                Text(
                  userProvider.isOnDuty ? 'Status: On Duty' : 'Status: Off Duty',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await userProvider.toggleOnDutyStatus();
                    userProvider.fetchOnDutyUsers();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: userProvider.isOnDuty ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      userProvider.isOnDuty ? 'Go Off Duty' : 'Go On Duty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: userProvider.onDutyUsers.length,
                    itemBuilder: (context, index) {
                      var user = userProvider.onDutyUsers[index];
                      return GestureDetector(
                        onTap: () {
                          _centerMapOnUser(user);
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user['Profile_Pic']),
                            ),
                            title: Text(
                              user['Nume'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            tileColor: user['Location'] == null || user['Location'].isEmpty ? Colors.red[100] : Colors.green[100],
                            trailing: Icon(
                              Icons.location_on,
                              color: user['Location'] == null || user['Location'].isEmpty ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _updateMarkers(List<Map<String, dynamic>> users) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Set<Marker> newMarkers = {};
      for (var user in users) {
        if (user['Location'] != null && user['Location'].isNotEmpty) {
          List<String> coordinates = user['Location'].split(',');
          double latitude = double.parse(coordinates[0].split(':')[1].trim());
          double longitude = double.parse(coordinates[1].split(':')[1].trim());
          newMarkers.add(
            Marker(
              markerId: MarkerId(user['Nume']),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: user['Nume'],
                snippet: user['Location'],
              ),
            ),
          );
        }
      }
      setState(() {
        _markers = newMarkers;
      });
    });
  }

  void _centerMapOnUser(Map<String, dynamic> user) {
    if (user['Location'] != null && user['Location'].isNotEmpty) {
      List<String> coordinates = user['Location'].split(',');
      double latitude = double.parse(coordinates[0].split(':')[1].trim());
      double longitude = double.parse(coordinates[1].split(':')[1].trim());
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 15));
    }
  }
}
