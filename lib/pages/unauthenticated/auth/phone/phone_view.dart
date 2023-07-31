import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/snack_bar.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/app_bars.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/continue_button.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/text_form_field.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_bloc.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_event.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_state.dart';

class PhoneView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  PhoneView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: signUpAppBar(context),
      body: BlocProvider.value(
        value: context.read<PhoneBloc>(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _phoneNumberForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneNumberForm() {
    return BlocListener<PhoneBloc, PhoneState>(listener: (context, state) {
      final formStatus = state.formStatus;
      if (formStatus is SubmissionFailed) {
        showSnackBar(context, formStatus.exception.toString());
        context.read<PhoneBloc>().add(ResetFormStatus());
      }
    }, child: BlocBuilder<PhoneBloc, PhoneState>(builder: (context, state) {
      void onPressed() {
        if (_formKey.currentState!.validate()) {
          context.read<PhoneBloc>().add(PhoneSubmitted());
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
                      "What's your phone number?",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 15),
                    _phoneNumberField(),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 10.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: continueButton(onPressed, formStatus: state.formStatus),
                      ))),
            ],
          ),
        ),
      );
    }));
  }

  Widget _phoneNumberField() {
    return BlocBuilder<PhoneBloc, PhoneState>(builder: (context, state) {
      // floatingLabelBehavior: FloatingLabelBehavior.always,
      String hintText = "Your phone";
      return IntlPhoneField(
        autofocus: true,
        decoration: inputDecoration(hintText),
        initialCountryCode: 'AU',
        onChanged: (phone) {
          context.read<PhoneBloc>().add(
                PhoneChanged(phoneNumber: phone.completeNumber),
              );
          // print(phone.completeNumber);
        },
      );
    });
  }
}
