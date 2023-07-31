import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/auth_repository.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_event.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_state.dart';

class PhoneBloc extends Bloc<PhoneEvent, PhoneState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;
  final String name;
  final String dob;

  PhoneBloc({required this.authRepo, required this.authCubit, required this.name, required this.dob}) : super(PhoneState(/*name: name, dob: dob*/)) {
    on<ResetFormStatus>(_mapResetFormStatus);
    on<PhoneChanged>(_mapPhoneChanged);
    on<PhoneSubmitted>(_mapPhoneAuthSubmitted);
    on<CodeChanged>(_mapCodeChanged);
    on<CodeSubmitted>(_mapCodeSubmitted);
  }

  _mapResetFormStatus(ResetFormStatus event, Emitter<PhoneState> emit) {
    emit(state.copyWith(formStatus: const InitialFormStatus()));
  }

  _mapPhoneChanged(PhoneChanged event, Emitter<PhoneState> emit) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  _mapPhoneAuthSubmitted(PhoneSubmitted event, Emitter<PhoneState> emit) async {
    emit(state.copyWith(formStatus: FormSubmitting()));

    await authRepo.signInWithOtp(state.phoneNumber!, name, dob);
    emit(state.copyWith(formStatus: SubmissionSuccess()));

    authCubit.showPhoneConfirmation(/*name: state.name, dob: state.dob, phoneAuthBloc: event.phoneAuthBloc*/);
  }

  _mapCodeChanged(CodeChanged event, Emitter<PhoneState> emit) {
    emit(state.copyWith(code: event.code));
  }

  _mapCodeSubmitted(CodeSubmitted event, Emitter<PhoneState> emit) async {
    emit(state.copyWith(formStatus: FormSubmitting()));
    await authRepo.verifyOtp(state.phoneNumber!, state.code!);
    emit(state.copyWith(formStatus: SubmissionSuccess()));

    authCubit.launchSession();
  }
}
