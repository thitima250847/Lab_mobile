import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_first_app/config/internal_config.dart'; // << ใช้ API_ENDPOINT
import 'package:my_first_app/pages/showtrip.dart'; // << นำทางหลัง login
import 'package:my_first_app/session/session.dart'; // << เก็บ session

import '../model/request/customer_login_post_req.dart';
import '../model/response/customer_login_post_res.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ใช้ค่าเดียวกับทั้งโปรเจกต์
  String get baseUrl => API_ENDPOINT;

  bool isLoading = false;

  Future<void> register() async {
    final fullname = fullnameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullname.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    if (password != confirmPassword) {
      showMessage('รหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1) ตรวจเช็กว่ามีผู้ใช้อยู่แล้วหรือไม่
      final checkResponse = await http.get(Uri.parse('$baseUrl/customers'));
      if (checkResponse.statusCode == 200) {
        final List customers = json.decode(checkResponse.body);
        final exists = customers.any(
          (c) =>
              (c['phone']?.toString() ?? '') == phone ||
              (c['email']?.toString().toLowerCase() ?? '') ==
                  email.toLowerCase(),
        );
        if (exists) {
          showMessage('มีผู้ใช้นี้อยู่แล้ว');
          return;
        }
      } else {
        showMessage('เช็กผู้ใช้ไม่สำเร็จ (${checkResponse.statusCode})');
        return;
      }

      // 2) สมัครสมาชิก
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullname': fullname,
          'phone': phone,
          'email': email,
          'image':
              'http://202.28.34.197:8888/contents/4a00cead-afb3-45db-a37a-c8bebe08fe0d.png',
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showMessage('สมัครสมาชิกสำเร็จ');
        // 3) ล็อกอินต่อทันที
        await _loginAndGo(phone, password);
      } else {
        showMessage('สมัครสมาชิกไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      // ถ้ารันบนเว็บแล้ว CORS ไม่เปิด จะมาที่นี่
      showMessage('เกิดข้อผิดพลาดเครือข่าย: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loginAndGo(String phone, String password) async {
    try {
      final req = CustomerLoginPostRequest(phone: phone, password: password);
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/customers/login'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: customerLoginPostRequestToJson(req),
      );

      if (loginResponse.statusCode == 200) {
        final res = customerLoginPostResponseFromJson(loginResponse.body);

        // เก็บ session
        Session.currentCustomer = res.customer;

        // ไปหน้าแสดงทริป
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ShowTripPage()),
          (route) => false,
        );
      } else {
        showMessage('Login ไม่สำเร็จ (${loginResponse.statusCode})');
      }
    } catch (e) {
      showMessage('Login ผิดพลาด: $e');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    fullnameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียนสมาชิกใหม่')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ชื่อ-นามสกุล'),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: fullnameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Text('หมายเลขโทรศัพท์'),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Text('อีเมล'),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Text('รหัสผ่าน'),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Text('ยืนยันรหัสผ่าน'),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Center(
                child: FilledButton(
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('สมัครสมาชิก'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 50),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context); // กลับไปหน้าเดิม (เช่น Login)
                        },
                        child: const Text('หากมีข้อมูลอยู่แล้ว?'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 20),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // ไปหน้า Login (ถ้าหน้าเดิมคือ Login)
                        },
                        child: const Text('เข้าสู่ระบบ'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
