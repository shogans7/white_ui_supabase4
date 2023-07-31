import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';

class PhoneState {
  final FormSubmissionStatus formStatus;
  final String? phoneNumber;
  final String? code;

  PhoneState({
    this.phoneNumber,
    this.code,
    this.formStatus = const InitialFormStatus(),
  });

  PhoneState copyWith({
    String? phoneNumber,
    String? code,
    FormSubmissionStatus? formStatus,
  }) {
    return PhoneState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      code: code ?? this.code,
      formStatus: formStatus ?? this.formStatus,
    );
  }

  bool get isValidPhoneNumber => true;
  bool get isValidCode => (code != null && code!.length == 6);
}
