import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:truckchecklist/views/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truckchecklist/views/auth/register_screen.dart';
import 'package:truckchecklist/controllers/auth_controller.dart';
import 'package:truckchecklist/views/auth/forgot_password_screen.dart';
import 'package:truckchecklist/views/auth/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final AuthController _authController = AuthController();

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  String employeeCompanyId = '';
  String password = '';
  bool _isLoading = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('remember_me') ?? false;
      if (rememberMe) {
        employeeCompanyId = prefs.getString('saved_employee_id') ?? '';
        password = prefs.getString('saved_password') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_employee_id', employeeCompanyId);
      await prefs.setString('saved_password', password);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_employee_id');
      await prefs.remove('saved_password');
    }
  }

  void _loginEmployee(BuildContext context) async {
    if (_formKeyLogin.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final isAuthenticated =
            await _authController.loginEmployee(employeeCompanyId, password);
        if (isAuthenticated) {
          await _saveCredentials();
          Get.to(const MainScreen());
        } else {
          _showErrorDialog(context, 'Invalid Credentials');
        }
      } catch (e) {
        _showErrorDialog(context, 'An Error Occurred. Please Try Again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/GA-FLA-Logo.png'),
              ),
              const Text(
                'Employee Login',
                style: TextStyle(fontSize: 22, fontFamily: "NexaBold"),
              ),
              Form(
                key: _formKeyLogin,
                child: Column(
                  children: [
                    CustomTextFormField(
                      labelText: 'Employee ID',
                      validator: _validateEmployeeId,
                      hintText: 'Please enter your employee ID',
                      prefixIcon: const Icon(Icons.work),
                      initialValue: employeeCompanyId,
                      onChanged: (value) => employeeCompanyId = value,
                    ),
                    CustomTextFormField(
                      labelText: 'Password',
                      validator: _validatePassword,
                      hintText: 'Please enter your password',
                      isPassword: true,
                      prefixIcon: const Icon(Icons.password_rounded),
                      initialValue: password,
                      onChanged: (value) => password = value,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                        ),
                        const Text('Remember Me'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _loginEmployee(context),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontFamily: "NexaBold",
                                  ),
                                ),
                        ),
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

  String? _validateEmployeeId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Employee ID is required.';
    }
    final regExp = RegExp(r'^[A-Za-z]{2}\d{4}$');
    if (!regExp.hasMatch(value)) {
      return 'Employee ID must be in the format: [First Initial][Last Initial][Last 4 digits of SSN].';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    return null;
  }
}
