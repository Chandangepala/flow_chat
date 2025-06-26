import 'package:flow_chat/data/remote/firebase_repository.dart';
import 'package:flow_chat/screens/home_screen.dart';
import 'package:flow_chat/screens/login/cubit/login_cubit.dart';
import 'package:flow_chat/screens/login/cubit/login_state.dart';
import 'package:flow_chat/screens/signup/cubit/signup_cubit.dart';
import 'package:flow_chat/screens/signup/signup_screen.dart';
import 'package:flow_chat/utils/SharedPref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final String IS_LOGGED_IN = "IS_LOGGED_IN";
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true; // State to toggle password visibility
  bool _isLoading = false; // State to show loading indicator

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      BlocProvider.of<LoginCubit>(context).authenticateUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      // Show error message if validation fails
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
    final textTheme =
        Theme.of(context).textTheme; // Get text theme for easy access

    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        // Ensures content is not obscured by notches/system bars
        child: Center(
          // Center the content vertically
          child: SingleChildScrollView(
            // Allows scrolling on smaller screens
            padding: const EdgeInsets.all(24.0), // Padding around the content
            child: Form(
              // Wrap content in a Form widget for validation
              key: _formKey,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically in the column
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch widgets horizontally
                children: <Widget>[
                  // --- Logo/App Name ---
                  Image.asset("assets/images/flow_chat_logo.png", width: 150, height: 150,),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back!',
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 24,
                      color: Colors.white
                    ), // Use theme text style
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to your account',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade100,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40), // More space before form fields
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
                      // Basic email format validation
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null; // Return null if valid
                    },
                    textInputAction:
                        TextInputAction.next, // Move focus to next field
                  ),
                  const SizedBox(height: 16), // Spacing
                  // --- Password Field ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, // Use state variable
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54,),
                      // Suffix icon to toggle password visibility
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
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null; // Return null if valid
                    },
                    textInputAction:
                        TextInputAction.done, // Indicate completion
                  ),
                  const SizedBox(height: 24), // More space before button
                  // --- Login Button ---
                  BlocConsumer<LoginCubit, LoginState>(
                    builder: (context, state) {
                      if (state is LoginLoadingState) {
                        return ElevatedButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                              Text('Logging In...'),
                            ],
                          ),
                        );
                      }
                      return ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _login, // Disable button when loading
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
                                : const Text('Log In',),
                      );
                    },
                    listener: (context, state) {
                      if (state is LoginFailedState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              state.errorMessage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      } else if (state is LoginSuccessState) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(userId: state.userId!)));
                        print('Login successful!');
                        print('Email: ${_emailController.text}');
                        print('Password: ${_passwordController.text}');
                      }
                    },
                  ),

                  const SizedBox(height: 16), // Spacing
                  // --- Forgot Password (Optional) ---
                  // TextButton(
                  //   onPressed: () {
                  //     // Handle forgot password action
                  //   },
                  //   child: const Text('Forgot Password?'),
                  // ),
                  // const SizedBox(height: 16),

                  // --- Switch to Sign Up ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade100,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to Sign Up Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RepositoryProvider(
                                    create: (context) => FirebaseRepository(),
                                    child: BlocProvider(
                                      create:
                                          (context) => SignupCubit(
                                            firebaseRepository:
                                                RepositoryProvider.of<
                                                  FirebaseRepository
                                                >(context),
                                          ),
                                      child: SignupScreen(),
                                    ),
                                  ),
                            ),
                          );
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.white),),
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
