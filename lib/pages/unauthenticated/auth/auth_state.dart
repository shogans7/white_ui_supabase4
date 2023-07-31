enum ScreenState { intro, name, dob, phone, phoneConfirmation }

class AuthState {
  ScreenState screenState;
  String? name;
  String? dob;

  AuthState({
    required this.screenState,
    this.name,
    this.dob,
  });

  AuthState copyWith({
    ScreenState? screenState,
    String? name,
    String? dob,
  }) {
    return AuthState(
      screenState: screenState ?? this.screenState,
      name: name ?? this.name,
      dob: dob ?? this.dob,
    );
  }
}
