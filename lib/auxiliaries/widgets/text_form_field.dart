import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/input_border.dart';

Widget customTextFormField(String hintText, TextInputType? keyboardType, String? Function(String?)? validator, void Function(String)? onChanged, {List<TextInputFormatter>? inputFormatters}) {
  return TextFormField(
    style: const TextStyle(fontSize: 24),
    autofocus: true,
    keyboardType: keyboardType,
    textCapitalization: TextCapitalization.words,
    onEditingComplete: () {},
    decoration: inputDecoration(hintText),
    validator: validator, //state.isValidCode ? null : 'Invalid Code',
    onChanged: onChanged,
    inputFormatters: inputFormatters,
  );
}

InputDecoration inputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    // floatingLabelBehavior: FloatingLabelBehavior.always,
    hintStyle: const TextStyle(
      fontSize: 24,
      color: Colors.grey,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
    border: border(),
    focusedBorder: border(),
    disabledBorder: border(),
    enabledBorder: border(),
    errorBorder: border(),
  );
}
