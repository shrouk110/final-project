import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })
      : _auth = auth,
        _firestore = firestore;

  Future<String> register(String fullName,
      String email,
      String password,
      String role,) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final collection = role == 'doctor' ? 'doctors' : 'patients';

    await _firestore.collection(collection).doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('role', role);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('temp_password', password);

    return role;
  }

  Future<String> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    String role = 'patient';

    final patientDoc = await _firestore.collection('patients').doc(uid).get();
    if (patientDoc.exists) {
      role = 'patient';
    } else {
      final doctorDoc = await _firestore.collection('doctors').doc(uid).get();
      if (doctorDoc.exists) {
        role = 'doctor';
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('role', role);
    await prefs.setBool('isLoggedIn', true);

    return role;
  }

  Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    final firebaseUser = _auth.currentUser;

    if (isLoggedIn && firebaseUser != null) {
      return prefs.getString('role');
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('role');
    await prefs.setBool('isLoggedIn', false);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }


  static const _emailJsUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  static const _emailJsService = 'vision_care_service';
  static const _emailJsTemplate = 'template_onnlsck';
  static const _emailJsPublicKey = 'M-TobPjL7PAJnZWal';
  static const _emailJsPrivateKey = 'mBzVcnxTyCeS3YcKv8-i_';

  Future<void> sendOtp(String email) async {
    final otp = (1000 + Random().nextInt(9000)).toString();

    await _firestore.collection('otp_codes').doc(email).set({
      'otp': otp,
      'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 10))),
      'verified': false,
    });

    final response = await http.post(
      Uri.parse(_emailJsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': _emailJsService,
        'template_id': _emailJsTemplate,
        'user_id': _emailJsPublicKey,
        'accessToken': _emailJsPrivateKey,
        'template_params': {
          'to_email': email,
          'otp': otp,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('EmailJS Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    final doc = await _firestore.collection('otp_codes').doc(email).get();

    if (!doc.exists) {
      throw Exception('No OTP found. Please request a new one.');
    }

    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();

    if (DateTime.now().isAfter(expiresAt)) {
      throw Exception('OTP has expired. Please request a new one.');
    }

    if (data['otp'] != otp) {
      throw Exception('Incorrect code. Please try again.');
    }

    await _firestore
        .collection('otp_codes')
        .doc(email)
        .update({'verified': true});
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email:    email,
        password: newPassword,
      );
    } catch (_) {}

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Could not authenticate user.');
    }
    await user.updatePassword(newPassword);
  }}