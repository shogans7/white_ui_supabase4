import 'package:intl/intl.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';

class DobState {
  // final String name;
  DateFormat format = DateFormat("dd/MM/yyyy");

  final String dob;

  bool get isValidDob {
    if (dob.length >= 10) {
      try {
        // ignore: unused_local_variable
        DateTime? birthDate = format.parse(dob);
        return true;
      } catch (e) {
        rethrow;
      }
    }
    return false;
  }

  bool get isValidAge {
    return ((calculateAge(dob) >= 18) && (calculateAge(dob) <= 100));
  }

  final FormSubmissionStatus formStatus;

  DobState({
    this.dob = '',
    this.formStatus = const InitialFormStatus(),
  });

  DobState copyWith({
    String? dob,
    FormSubmissionStatus? formStatus,
  }) {
    return DobState(
      dob: dob ?? this.dob,
      formStatus: formStatus ?? this.formStatus,
    );
  }

  int calculateAge(String dob) {
    if (dob.isNotEmpty) {
      try {
        DateTime? birthDate = format.parse(dob);
        DateTime currentDate = DateTime.now();
        int age = currentDate.year - birthDate.year;
        if (birthDate.month > currentDate.month) {
          age--;
        } else if (currentDate.month == birthDate.month) {
          if (birthDate.day > currentDate.day) {
            age--;
          }
        }
        return age;
      } catch (e) {
        throw ("Error parsing DOB to age");
      }
    }
    return 0;
  }
}
