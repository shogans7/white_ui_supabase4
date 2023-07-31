abstract class DobEvent {}

class DobChanged extends DobEvent {
  final String dob;

  DobChanged({required this.dob});
}

class DobSubmitted extends DobEvent {}

class ResetFormStatus extends DobEvent {}

class PassDob extends DobEvent {}
