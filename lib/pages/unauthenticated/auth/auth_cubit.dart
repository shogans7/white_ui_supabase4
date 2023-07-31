import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_state.dart';
import 'package:white_ui_supabase4/session_navigation/session_cubit.dart';

class AuthCubit extends Cubit<AuthState> {
  final SessionCubit sessionCubit;
  final SharedPreferences preferences;

  AuthCubit({required this.sessionCubit, required this.preferences}) : super(AuthState(screenState: preferences.getBool('isFirstOpen')! ? ScreenState.intro : ScreenState.name));

  void updateName(String name) => emit(state.copyWith(name: name));
  void updateDob(String dob) => emit(state.copyWith(dob: dob));

  void showIntro() => emit(state.copyWith(screenState: ScreenState.intro));
  void showName() => emit(state.copyWith(screenState: ScreenState.name));
  void showDOB() => emit(state.copyWith(screenState: ScreenState.dob));
  void showPhone() => emit(state.copyWith(screenState: ScreenState.phone));
  void showPhoneConfirmation() => emit(state.copyWith(screenState: ScreenState.phoneConfirmation)); /*phoneAuthBloc: phoneAuthBloc)*/

  void launchSession() {
    preferences.setBool('isFirstOpen', false);
    sessionCubit.showSession();
  }
}
