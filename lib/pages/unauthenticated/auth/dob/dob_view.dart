import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/formatters/date_textfield_formatter.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/snack_bar.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/auth_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/app_bars.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/continue_button.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/text_form_field.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/dob/dob_bloc.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/dob/dob_event.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/dob/dob_state.dart';

class DobView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  DobView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: signUpAppBar(context),
      body: BlocProvider(
        create: (context) => DobBloc(
          authRepo: context.read<AuthRepository>(),
          authCubit: context.read<AuthCubit>(),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _dobForm(),
            ],
          ),
        ),
      ),
      // )
    );
  }

  Widget _dobForm() {
    return BlocListener<DobBloc, DobState>(listener: (context, state) {
      final formStatus = state.formStatus;
      if (formStatus is SubmissionFailed) {
        showSnackBar(context, formStatus.exception.toString());
        context.read<DobBloc>().add(ResetFormStatus());
      }
    }, child: BlocBuilder<DobBloc, DobState>(builder: (context, state) {
      void onPressed() {
        if (_formKey.currentState!.validate()) {
          context.read<DobBloc>().add(DobSubmitted());
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
                    // _icon(),
                    const SizedBox(height: 35),
                    const Text(
                      "When's your birthday?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 15),
                    _dobField(),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 10.0),
                  child: SizedBox(width: double.infinity, height: 50, child: continueButton(onPressed, formStatus: state.formStatus, enableButton: (state.isValidDob && state.isValidAge))),
                ),
              ),
            ],
          ),
        ),
      );
    }));
  }

  Widget _dobField() {
    return BlocBuilder<DobBloc, DobState>(builder: (context, state) {
      // floatingLabelBehavior: FloatingLabelBehavior.always,
      String hintText = "DD/MM/YYYY";
      String? validator(value) => state.isValidAge ? null : 'User age not valid';
      void onChanged(value) => context.read<DobBloc>().add(
            DobChanged(dob: value),
          );
      List<TextInputFormatter> inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
        LengthLimitingTextInputFormatter(10),
        DateTextFieldFormatter(),
        // https://stackoverflow.com/questions/62467842/flutter-textfield-input-validation-for-a-date
      ];
      return customTextFormField(hintText, TextInputType.number, validator, onChanged, inputFormatters: inputFormatters);
    });
  }
}
