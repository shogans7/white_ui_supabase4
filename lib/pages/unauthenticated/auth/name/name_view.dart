import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/continue_button.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/snack_bar.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/auth_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/app_bars.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/text_form_field.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/name/name_bloc.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/name/name_event.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/name/name_state.dart';

class NameView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  NameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: signUpAppBar(context),
      body: BlocProvider(
        create: (context) => NameBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _nameForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameForm() {
    return BlocListener<NameBloc, NameState>(listener: (context, state) {
      final formStatus = state.formStatus;
      if (formStatus is SubmissionFailed) {
        showSnackBar(context, formStatus.exception.toString());
        context.read<NameBloc>().add(ResetFormStatus());
      }
    }, child: BlocBuilder<NameBloc, NameState>(builder: (context, state) {
      void onPressed() {
        if (_formKey.currentState!.validate()) {
          context.read<NameBloc>().add(NameSubmitted());
        }
      }

      return Form(
        key: _formKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 35),
                    const Text(
                      "Let's get going! What's your name?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 15),
                    _nameField(),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 10.0),
                    child: SizedBox(width: double.infinity, height: 50, child: continueButton(onPressed, formStatus: state.formStatus, enableButton: state.isValidUsername))),
              ),
            ],
          ),
        ),
      );
    }));
  }

  Widget _nameField() {
    return BlocBuilder<NameBloc, NameState>(builder: (context, state) {
      // textCapitalization: TextCapitalization.words,
      String hintText = "Your name?";
      String? validator(value) => state.isValidUsername ? null : 'Name is too short';
      void onChanged(value) => context.read<NameBloc>().add(
            NameChanged(name: value),
          );
      return customTextFormField(hintText, TextInputType.multiline, validator, onChanged);
    });
  }
}
