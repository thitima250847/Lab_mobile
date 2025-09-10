import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/config/internal_config.dart';
import 'package:my_first_app/pages/login.dart';
import 'package:my_first_app/session/session.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final fullnameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final customer = Session.currentCustomer;
      if (customer == null) {
        // If somehow no session, go back to login
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
        }
        return;
      }
      // Query first (GET latest customer)
      final id = customer.idx;
      final res = await http.get(Uri.parse('$API_ENDPOINT/customers/$id'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        fullnameCtrl.text = (data['fullname'] ?? '').toString();
        phoneCtrl.text = (data['phone'] ?? '').toString();
        emailCtrl.text = (data['email'] ?? '').toString();
        imageCtrl.text = (data['image'] ?? '').toString();
      } else {
        log('GET /customers/$id failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      log('load profile error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _update() async {
    final customer = Session.currentCustomer;
    if (customer == null) return;
    final id = customer.idx;
    final body = jsonEncode({
      "idx": id,
      "fullname": fullnameCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "image": imageCtrl.text.trim(),
    });
    final res = await http.put(
      Uri.parse('$API_ENDPOINT/customers/$id'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    if (res.statusCode == 200) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('สำเร็จ'),
          content: const Text('บันทึกข้อมูลเรียบร้อย'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ล้มเหลว'),
          content: const Text('บันทึกข้อมูลไม่สำเร็จ'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _delete() async {
    final customer = Session.currentCustomer;
    if (customer == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('ลบบัญชีผู้ใช้นี้ถาวรหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final id = customer.idx;
    final res = await http.delete(Uri.parse('$API_ENDPOINT/customers/$id'));
    if (res.statusCode == 200 || res.statusCode == 204) {
      if (!mounted) return;
      Session.currentCustomer = null;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบไม่สำเร็จ (${res.statusCode})')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _delete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('ยกเลิกสมาชิก'),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (imageCtrl.text.isNotEmpty)
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(imageCtrl.text),
                      onBackgroundImageError: (_, __) {},
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: fullnameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อ-สกุล',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'เบอร์โทร (แก้ไขไม่ได้)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'อีเมล',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'รูปโปรไฟล์ (URL)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: FilledButton(
                      onPressed: _update,
                      child: const Text('บันทึกข้อมูล'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
