import 'package:flutter/material.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';

Widget continueButton(void Function() onPressed, {FormSubmissionStatus? formStatus, LoadingState? loadingState, bool? enableButton}) {
  return formStatus is FormSubmitting || loadingState is Loading
      ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator()]),
            const SizedBox(
              height: 5,
            )
          ],
        )
      : ElevatedButton(
          style: ButtonStyle(
            backgroundColor: (enableButton != null && enableButton == false) ? MaterialStateProperty.all(Colors.black.withOpacity(0.5)) : MaterialStateProperty.all(Colors.black),
            maximumSize: MaterialStateProperty.all<Size>(const Size(100, 50)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: (enableButton != null && enableButton == false) ? const BorderSide(width: 1, color: Colors.grey) : const BorderSide(width: 1, color: Colors.black54),
            )),
          ),
          onPressed: (enableButton != null && enableButton == false) ? null : onPressed,
          child: Text('Continue',
              style: TextStyle(
                color: (enableButton != null && enableButton == false) ? Colors.white.withOpacity(0.5) : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )));
}
