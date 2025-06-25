import 'package:flow_chat/data/remote/firebase_repository.dart';
import 'package:flow_chat/models/user_model.dart';
import 'package:flow_chat/screens/signup/cubit/signup_state.dart';
import 'package:bloc/bloc.dart';

class SignupCubit extends Cubit<SignupState>{
  FirebaseRepository firebaseRepository;
  SignupCubit({required this.firebaseRepository}) : super(SignupInitialState());

  Future<void> signupUser(UserModel user, String password) async{
    emit(SignupLoadingState());
    try{
      await firebaseRepository.createUser(user: user, password: password);
      emit(SignupSuccessState());
    }catch(e){
      emit(SignupFailedState(errorMessage: e.toString()));
    }
  }

}