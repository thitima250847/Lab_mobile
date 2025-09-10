import 'package:my_first_app/pages/trip.dart';
import 'package:my_first_app/session/session.dart';
import 'package:my_first_app/pages/login.dart';
import 'package:my_first_app/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/config/internal_config.dart';
import 'package:my_first_app/model/response/trip_get_res.dart';
import 'dart:developer';

class ShowTripPage extends StatefulWidget {
  const ShowTripPage({super.key});

  @override
  State<ShowTripPage> createState() => _ShowTripPageState();
}

class _ShowTripPageState extends State<ShowTripPage> {
  String? _selectedZoneLabel;
  String url = '';

  void _onZoneSelected(String? label) {
    setState(() {
      _selectedZoneLabel = label;
    });
    getTrips(destinationZone: label);
  }

  bool _isSelectedZone(String? label) {
    if (_selectedZoneLabel == null && label == null) return true;
    return _selectedZoneLabel == label;
  }

  List<TripGetResponse> tripGetResponse = [];

  late Future<void> loadData;

  @override
  void initState() {
    super.initState();
    loadData = getTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทริป'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              } else if (value == 'logout') {
                Session.currentCustomer = null;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(value: 'profile', child: Text('โปรไฟล์')),
              PopupMenuItem<String>(value: 'logout', child: Text('ออกจากระบบ')),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Done
          return Padding(
            padding: const EdgeInsets.all(8), // padding รอบนอก
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ปลายทาง'),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _isSelectedZone(null)
                            ? FilledButton(
                                onPressed: () => _onZoneSelected(null),
                                child: const Text('ทั้งหมด'),
                              )
                            : OutlinedButton(
                                onPressed: () => _onZoneSelected(null),
                                child: const Text('ทั้งหมด'),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _isSelectedZone('ยุโรป')
                            ? FilledButton(
                                onPressed: () => _onZoneSelected('ยุโรป'),
                                child: const Text('ยุโรป'),
                              )
                            : OutlinedButton(
                                onPressed: () => _onZoneSelected('ยุโรป'),
                                child: const Text('ยุโรป'),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _isSelectedZone('เอเชียตะวันออกเฉียงใต้')
                            ? FilledButton(
                                onPressed: () =>
                                    _onZoneSelected('เอเชียตะวันออกเฉียงใต้'),
                                child: const Text('เอเชียตะวันออกเฉียงใต้'),
                              )
                            : OutlinedButton(
                                onPressed: () =>
                                    _onZoneSelected('เอเชียตะวันออกเฉียงใต้'),
                                child: const Text('เอเชียตะวันออกเฉียงใต้'),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _isSelectedZone('เอเชีย')
                            ? FilledButton(
                                onPressed: () => _onZoneSelected('เอเชีย'),
                                child: const Text('เอเชีย'),
                              )
                            : OutlinedButton(
                                onPressed: () => _onZoneSelected('เอเชีย'),
                                child: const Text('เอเชีย'),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _isSelectedZone('ประเทศไทย')
                            ? FilledButton(
                                onPressed: () => _onZoneSelected('ประเทศไทย'),
                                child: const Text('ประเทศไทย'),
                              )
                            : OutlinedButton(
                                onPressed: () => _onZoneSelected('ประเทศไทย'),
                                child: const Text('ประเทศไทย'),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: tripGetResponse.length,
                    itemBuilder: (context, index) {
                      final trip = tripGetResponse[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.country,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        trip.coverimage,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.broken_image,
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trip.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'ระยะเวลา ${trip.duration} วัน',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'ราคา ${trip.price} บาท',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    TripPage(idx: index),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'รายละเอียดเพิ่มเติม',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> getTrips({String? destinationZone}) async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];

    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    log(res.body);
    List<TripGetResponse> trips = tripGetResponseFromJson(res.body);
    if (destinationZone != null) {
      final dz = destinationZoneValues.map[destinationZone];
      if (dz != null) {
        // Filter by zone label (e.g., เอเชีย/ยุโรป/อเมริกา)
        trips = trips.where((trip) => trip.destinationZone == dz).toList();
      } else {
        // Fallback: treat as country filter (e.g., ประเทศไทย)
        trips = trips.where((trip) => trip.country == destinationZone).toList();
      }
    }
    setState(() {
      tripGetResponse = trips;
    });
    log(tripGetResponse.length.toString());
  }
}
