import 'package:flutter/cupertino.dart';

@immutable
abstract class SignupState{}

class SignupInitialState extends SignupState{}
class SignupLoadingState extends SignupState{}
class SignupSuccessState extends SignupState{}
class SignupFailedState extends SignupState{
  String errorMessage;
  SignupFailedState({required this.errorMessage});
}