import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/models/user_model.dart';
import 'package:flow_chat/screens/signup/cubit/signup_cubit.dart';
import 'package:flow_chat/screens/signup/cubit/signup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import the login screen

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<String> genderList = ["Male", "Female", "Other"];
  String _selectedGender = "Male";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // State to show loading indicator

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      UserModel user = UserModel(
        name: _nameController.text,
        email: _emailController.text,
        mobileNo: _mobileController.text,
        gender: _selectedGender,
        createdAt: DateTime.timestamp().toString(),
        isOnline: true,
        status: 1,
        profilePic: "",
        profileStatus: 1,
      );
      BlocProvider.of<SignupCubit>(
        context,
      ).signupUser(user, _passwordController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Get text theme

    return Scaffold(
      backgroundColor: Colors.black54,
      // Add an AppBar to easily navigate back
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 2, // No shadow
        foregroundColor: Colors.white, // Back arrow color
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- Header Text ---
                  Text(
                    'Get Started',
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 24,
                      color: Colors.white
                    ), // Use theme text style
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to continue',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade100,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // --- Name Field ---
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline, color: Colors.white54,),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // --- Email Field ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.white54,),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // --- Password Field ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54,),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white54,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // --- Confirm Password Field ---
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Confirm your password',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54,),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white54,
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 16),

                  // --- Mobile Field ---
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter Mobile Number',
                      prefixIcon: Icon(Icons.phone_android, color: Colors.white54,),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length < 8) {
                        return 'Please enter a valid mobile number';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  Container(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: Text("Select Gender", style: TextStyle(color: Colors.white),),
                      dropdownColor: Colors.black54,
                      items:
                          genderList.map<DropdownMenuItem<String>>((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Container(
                                color: Colors.black54,
                                width: 200,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
                                  child: Text(gender, style: TextStyle(fontSize: 18, color: Colors.white),),
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      style: const TextStyle(color: Colors.black54, fontSize: 16),
                      underline: Container(
                        height: 2,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                  BlocConsumer<SignupCubit, SignupState>(
                    builder: (context, state) {
                      if (state is SignupLoadingState) {
                        return ElevatedButton(
                          onPressed: () => {},
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                              Text('Creating Account...'),
                            ],
                          ),
                        );
                      }
                      return ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('Sign Up'),
                      );
                    },
                    listener: (context, state) {
                      if (state is SignupFailedState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Error: ${state.errorMessage}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            backgroundColor: Colors.black45,
                          ),
                        );
                      } else if (state is SignupSuccessState) {
                        Navigator.pop(context);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // --- Switch to Log In ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate back to Login Screen
                          Navigator.pop(
                            context,
                          ); // Simply pop the current screen
                        },
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
