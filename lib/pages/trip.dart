import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/config/internal_config.dart';
import 'package:my_first_app/model/response/trip_get_res.dart';

class TripPage extends StatefulWidget {
  final int idx;
  const TripPage({super.key, required this.idx});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  TripGetResponse? trip;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
      if (res.statusCode == 200) {
        final trips = tripGetResponseFromJson(res.body);
        if (widget.idx >= 0 && widget.idx < trips.length) {
          trip = trips[widget.idx];
        }
      } else {
        log('GET /trips failed ${res.statusCode}');
      }
    } catch (e) {
      log('trip load error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดทริป')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : trip == null
              ? const Center(child: Text('ไม่พบข้อมูลทริป'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip!.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          trip!.coverimage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(height: 200, child: Center(child: Icon(Icons.broken_image))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('ประเทศ: ${trip!.country}'),
                      Text('ราคา: ${trip!.price} บาท'),
                      const SizedBox(height: 12),
                      Text(trip!.detail),
                      const SizedBox(height: 24),
                      Center(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ปิด'),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}