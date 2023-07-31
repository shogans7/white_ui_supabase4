import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';

class NameState {
  final String name;
  bool get isValidUsername => name.isNotEmpty;

  final FormSubmissionStatus formStatus;

  NameState({
    this.name = '',
    // this.email = '',
    // this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  NameState copyWith({
    String? name,
    FormSubmissionStatus? formStatus,
  }) {
    return NameState(
      name: name ?? this.name,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
