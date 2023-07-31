// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/auth_repository.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/name/name_state.dart';

import 'name_event.dart';

class NameBloc extends Bloc<NameEvent, NameState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;

  NameBloc({required this.authRepo, required this.authCubit}) : super(NameState()) {
    on<NameChanged>(_mapNameChanged);
    on<NameSubmitted>(_mapNameSubmitted);
    on<ResetFormStatus>(_mapResetFormStatus);
  }

  _mapResetFormStatus(ResetFormStatus event, Emitter<NameState> emit) {
    emit(state.copyWith(formStatus: const InitialFormStatus()));
  }

  _mapNameChanged(NameChanged event, Emitter<NameState> emit) {
    emit(state.copyWith(name: event.name));
  }

  _mapNameSubmitted(NameSubmitted event, Emitter<NameState> emit) async {
    emit(state.copyWith(formStatus: FormSubmitting()));
    emit(state.copyWith(formStatus: SubmissionSuccess()));
    authCubit.updateName(state.name);
    authCubit.showDOB();
  }
}
