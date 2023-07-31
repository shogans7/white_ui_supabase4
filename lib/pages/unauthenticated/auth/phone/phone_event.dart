// import 'package:flutter_contacts/properties/phone.dart';

abstract class PhoneEvent {}

class ResetFormStatus extends PhoneEvent {}

class PhoneChanged extends PhoneEvent {
  String phoneNumber;

  PhoneChanged({required this.phoneNumber});
}

class PhoneSubmitted extends PhoneEvent {}

class CodeChanged extends PhoneEvent {
  String code;

  CodeChanged({required this.code});
}

class CodeSubmitted extends PhoneEvent {}
