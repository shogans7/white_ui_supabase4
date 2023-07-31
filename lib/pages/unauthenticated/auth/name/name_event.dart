abstract class NameEvent {}

class NameChanged extends NameEvent {
  final String name;

  NameChanged({required this.name});
}

class NameSubmitted extends NameEvent {}

class ResetFormStatus extends NameEvent {}
