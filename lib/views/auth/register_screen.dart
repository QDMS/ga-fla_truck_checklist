import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:truckchecklist/global.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/auth_controller.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:truckchecklist/views/auth/login_screen.dart';
import 'package:truckchecklist/views/auth/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isDarkMode = false;

  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKeyRegister = GlobalKey<FormState>();

  String email = '';
  String employeeId = '';
  String username = '';
  String employerCode = '';
  String password = '';
  bool isPasswordValid = false;
  bool isUpperCaseValid = false;
  bool isNumberValid = false;
  bool isSpecialCharValid = false;
  bool isLengthValid = false;
  bool isPasswordFieldFocused = false; // New state to track focus
  Uint8List? _image;

  selectProfileImage() async {
    Uint8List? im = await _authController.pickProfileImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  captureProfileImage() async {
    Uint8List? im = await _authController.pickProfileImage(ImageSource.camera);
    setState(() {
      _image = im;
    });
  }

  // Validate employee ID
  String? _validateEmployeeId(String? value) {
    if (value!.isEmpty) {
      return 'Employee ID is required.';
    }
    RegExp regExp = RegExp(r'^[A-Za-z]{2}\d{4}$');
    if (!regExp.hasMatch(value)) {
      return 'Employee ID must be:[First Initial]\n[Last Initial][Last 4 digits of SSN].';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation and update requirements
  void _validatePassword(String value) {
    setState(() {
      isPasswordFieldFocused = value.isNotEmpty; // Show box only if typing
      isLengthValid = value.length >= 8;
      isUpperCaseValid = RegExp(r'[A-Z]').hasMatch(value);
      isNumberValid = RegExp(r'[0-9]').hasMatch(value);
      isSpecialCharValid = RegExp(r'[!@#\$&*~]').hasMatch(value);
      isPasswordValid = isLengthValid &&
          isUpperCaseValid &&
          isNumberValid &&
          isSpecialCharValid;
    });
  }

  String? _validateEmployerCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Employer code is required.';
    }
    if (value != 'GaFlaPowerSweep229') {
      return 'Invalid employer code.';
    }
    return null;
  }

  void _register() async {
    if (_image != null) {
      if (_formKeyRegister.currentState!.validate()) {
        if (email.isEmpty ||
            password.isEmpty ||
            employeeId.isEmpty ||
            _image!.isEmpty ||
            username.isEmpty) {
          CustomSnackBar(
              'Registration Failed', "Please fill out all fields", Colors.red);
          return;
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(
              child: CircularProgressIndicator(
            color: primary,
          )),
        );

        String result = await _authController.registerEmployee(
            email, employeeId, username, password, _image);

        if (!mounted) return;
        Navigator.pop(context);

        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text(result)));
        CustomSnackBar('Registration InProgress', result, Colors.yellow);

        if (result == 'Registration successful!') {
          Get.to(
            const LoginScreen(),
          );
          CustomSnackBar('Registration Successful', 'Account Has Been Created',
              Colors.green);
        } else {
          CustomSnackBar("Registration Failed", result.toString(), Colors.red);
        }
      }
    } else {
      CustomSnackBar('Registration Failed', "No Image Selected", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/GA-FLA-Logo.png'),
              ),
              const Text(
                'Employee Registration',
                style: TextStyle(fontSize: 22, fontFamily: "NexaBold"),
              ),
              const SizedBox(
                height: 15,
              ),
              Stack(
                children: [
                  _image == null
                      ? CircleAvatar(
                          backgroundColor: primary,
                          radius: 80,
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 70,
                            child: Icon(
                              CupertinoIcons.person,
                              color: primary,
                              size: 55,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: primary,
                          radius: 80,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: MemoryImage(_image!),
                          ),
                        ),
                  Positioned(
                    right: 30,
                    top: 15,
                    child: GestureDetector(
                      onTap: () {
                        selectProfileImage();
                      },
                      child: const Icon(
                        CupertinoIcons.photo,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    top: 15,
                    child: GestureDetector(
                      onTap: () {
                        captureProfileImage();
                      },
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Form(
                key: _formKeyRegister,
                child: Column(
                  children: [
                    CustomTextFormField(
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Employee Email Address',
                      hintText: 'Please enter a Email Address',
                      prefixIcon: const Icon(Icons.email_rounded),
                      onChanged: (value) => email = value,
                    ),
                    CustomTextFormField(
                      labelText: 'Employee ID',
                      hintText: 'Please enter an employee ID',
                      validator: _validateEmployeeId,
                      prefixIcon: const Icon(Icons.work),
                      onChanged: (value) => employeeId = value,
                    ),
                    CustomTextFormField(
                      labelText: 'Employee Username',
                      hintText: 'Please enter a Username',
                      prefixIcon: const Icon(Icons.person),
                      onChanged: (value) => username = value,
                    ),
                    CustomTextFormField(
                      labelText: 'Employer Code',
                      hintText: 'Please enter the Employer Code',
                      isPassword: true,
                      prefixIcon: const Icon(Icons.code_rounded),
                      validator: _validateEmployerCode,
                      onChanged: (value) => employerCode = value,
                    ),
                    CustomTextFormField(
                      labelText: 'Password',
                      hintText: 'Please enter a password',
                      isPassword: true,
                      prefixIcon: const Icon(Icons.password_rounded),
                      onChanged: (value) {
                        password = value; // Update the password value
                        _validatePassword(value); // Validate the password
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password requirements UI box (conditionally shown)
                    Visibility(
                      visible: isPasswordFieldFocused,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildPasswordRequirement(
                              "At least 8 characters",
                              isLengthValid,
                            ),
                            _buildPasswordRequirement(
                              "At least one uppercase letter",
                              isUpperCaseValid,
                            ),
                            _buildPasswordRequirement(
                              "At least one number",
                              isNumberValid,
                            ),
                            _buildPasswordRequirement(
                              "At least one special character",
                              isSpecialCharValid,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: isPasswordValid ? _register : null,
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: isPasswordValid ? Colors.black : Colors.grey,
                            border: Border.all(color: primary),
                          ),
                          child: const Center(
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: "NexaBold",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    RichText(
                      text: TextSpan(
                        text: "Already Employed? ",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NexaRegular',
                          color: isDarkMode ? Colors.white : Colors.black,
                          height:
                              1.25, // Optional: Ensure consistent line height
                        ),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontFamily: "NexaBold",
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(
                                  const LoginScreen(),
                                );
                              },
                          ),
                        ],
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

  // Helper method to build password requirement indicators
  Widget _buildPasswordRequirement(String text, bool isFulfilled) {
    return Row(
      children: [
        Icon(
          isFulfilled ? Icons.check_circle : Icons.cancel,
          color: isFulfilled ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isFulfilled ? Colors.green : Colors.red,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
