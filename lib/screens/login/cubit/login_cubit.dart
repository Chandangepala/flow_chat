import 'package:flow_chat/data/remote/firebase_repository.dart';
import 'package:flow_chat/screens/login/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState>{
  FirebaseRepository firebaseRepository;
  LoginCubit({required this.firebaseRepository}): super(LoginInitialState());

  Future<void> authenticateUser({required String email, required String password}) async{
    emit(LoginLoadingState());
    try{
      var userId = await firebaseRepository.loginUser(email: email, password: password);
      emit(LoginSuccessState(userId: userId));
    }catch(e){
      emit(LoginFailedState(errorMessage: e.toString()));
    }
  }
}