import 'package:firebase_core/firebase_core.dart';
import 'package:flow_chat/data/remote/firebase_repository.dart';
import 'package:flow_chat/screens/chat_screen.dart';
import 'package:flow_chat/screens/contacts_screen.dart';
import 'package:flow_chat/screens/home_screen.dart';
import 'package:flow_chat/screens/login/cubit/login_cubit.dart';
import 'package:flow_chat/screens/login/login_screen.dart';
import 'package:flow_chat/screens/signup/cubit/signup_cubit.dart';
import 'package:flow_chat/screens/signup/signup_screen.dart';
import 'package:flow_chat/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(RepositoryProvider(create: (context) => FirebaseRepository(),
    child: MultiBlocProvider(providers: [
        BlocProvider(create: (context) => LoginCubit(firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context))),
        BlocProvider(create: (context) => SignupCubit(firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context)))
      ], child: const MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      home: SplashScreen(),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        //'/home': (context) => HomeScreen(),
        '/contacts': (context) => ContactsScreen()
      },
    );
  }
}

