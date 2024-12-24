import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Uint8List?> pickProfileImage(ImageSource source) async {
    try {
      final ImagePicker imagePicker = ImagePicker();

      // Select or capture image
      final XFile? file = await imagePicker.pickImage(source: source);

      if (file != null) {
        // Return the image bytes
        return await file.readAsBytes();
      } else {
        // Handle case where no image was selected
        print("No image selected or captured.");
        return null;
      }
    } catch (e) {
      // Handle exceptions
      print("An error occurred while picking the image: $e");
      return null;
    }
  }

  // Function to upload a profile image to Firebase storage
  _uploadImageToStorage(Uint8List? image) async {
    Reference ref =
        _storage.ref().child('profileImages').child(_auth.currentUser!.uid);
    UploadTask uploadTask = ref.putData(image!);

    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<String> registerEmployee(String email, String employeeId,
      String username, String password, Uint8List? image) async {
    String res = 'some error occurred while creating account';

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String downloadUrl = await _uploadImageToStorage(image);

      await _firestore
          .collection('employees')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'employeeCompanyId': employeeId,
        'profileImage': downloadUrl,
        'employeeId': userCredential.user!.uid,
        'username': username,
      });

      res = 'Registration successful!';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<bool> loginEmployee(String employeeCompanyId, String password) async {
    try {
      // Query to find the employee by company ID
      QuerySnapshot employeeSnapshot = await _firestore
          .collection('employees')
          .where('employeeCompanyId', isEqualTo: employeeCompanyId)
          .limit(1)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        // Employee found, get their email
        String email = employeeSnapshot.docs.first['email'];

        // Attempt to sign in with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        return true; // Login successful
      } else {
        // Employee not found
        return false;
      }
    } catch (e) {
      // Error handling (e.g., wrong password, network issues)
      print('Login error: $e');
      return false;
    }
  }
}
