// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/auth_repository.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/dob/dob_event.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/dob/dob_state.dart';

class DobBloc extends Bloc<DobEvent, DobState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;
  // final String name;

  DobBloc({
    required this.authRepo,
    required this.authCubit,
    /*required this.name*/
  }) : super(DobState(/*name: name*/)) {
    on<DobChanged>(_mapDobChanged);
    on<DobSubmitted>(_mapDobSubmitted);
    on<ResetFormStatus>(_mapResetFormStatus);
  }

  _mapResetFormStatus(ResetFormStatus event, Emitter<DobState> emit) {
    emit(state.copyWith(formStatus: const InitialFormStatus()));
  }

  _mapDobChanged(DobChanged event, Emitter<DobState> emit) {
    emit(state.copyWith(dob: event.dob));
  }

  _mapDobSubmitted(DobSubmitted event, Emitter<DobState> emit) async {
    emit(state.copyWith(formStatus: FormSubmitting()));
    emit(state.copyWith(formStatus: SubmissionSuccess()));
    authCubit.updateDob(state.dob);
    authCubit.showPhone(/*state.name, state.dob*/);
  }
}
