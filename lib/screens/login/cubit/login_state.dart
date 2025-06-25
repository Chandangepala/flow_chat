import 'package:flow_chat/screens/login/login_screen.dart';

abstract class LoginState{}

class LoginInitialState extends LoginState{}
class LoginLoadingState extends LoginState{}
class LoginSuccessState extends LoginState{
  String? userId;
  LoginSuccessState({required this.userId});
}
class LoginFailedState extends LoginState{
  String errorMessage;
  LoginFailedState({required this.errorMessage});
}