import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/app_bars.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/continue_button.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/text_form_field.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_bloc.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_event.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_state.dart';

class PhoneConfirmationScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  PhoneConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: context.read<PhoneBloc>(), //phoneBloc,
        child: BlocListener<PhoneBloc, PhoneState>(
          listener: (context, state) {
            // final formStatus = state.formStatus;
            // if (formStatus is SubmissionSuccess) {
            //   _showSnackBar(context, "Friend request sent");
            //   context.read<FriendsBloc>().add(FriendsResetFormStatus());
            // }
            // if (formStatus is SubmissionFailed) {
            //   _showSnackBar(context, formStatus.exception.toString());
            //   context.read<FriendsBloc>().add(FriendsResetFormStatus());
            // }
          },
          child: Scaffold(
            appBar: signUpAppBar(context),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  _codeForm(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _codeForm() {
    return BlocListener<PhoneBloc, PhoneState>(listener: (context, state) {
      // final formStatus = state.formStatus;
      // if (formStatus is SubmissionFailed) {
      //   _showSnackBar(context, formStatus.exception.toString());
      //   context.read<NameBloc>().add(ResetFormStatus());
      // }
    }, child: BlocBuilder<PhoneBloc, PhoneState>(builder: (context, state) {
      void onPressed() {
        if (_formKey.currentState!.validate()) {
          context.read<PhoneBloc>().add(CodeSubmitted());
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
                      "Input your code?",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 15),
                    _codeField(),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 10.0),
                  child: SizedBox(width: double.infinity, height: 50, child: continueButton(onPressed, formStatus: state.formStatus)),
                ),
              ),
            ],
          ),
        ),
      );
    }));
  }

  Widget _codeField() {
    return BlocBuilder<PhoneBloc, PhoneState>(builder: (context, state) {
      String hintText = "Your code?";
      String? validator(value) => state.isValidCode ? null : 'Invalid Code';
      void onChanged(value) => context.read<PhoneBloc>().add(
            CodeChanged(code: value),
          );
      return customTextFormField(hintText, TextInputType.number, validator, onChanged);
    });
  }
}
