import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_state.dart';

PreferredSizeWidget introAppBar(BuildContext context) {
  final appBarHeight = AppBar().preferredSize.height;
  return PreferredSize(
    preferredSize: Size.fromHeight(appBarHeight),
    child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return AppBar(bottomOpacity: 0.0, elevation: 0.0, backgroundColor: Colors.black, foregroundColor: Colors.black, title: _icon(), actions: [
        TextButton(
          child: const Text("Skip", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
          onPressed: () {
            context.read<AuthCubit>().showName();
          },
        ),
      ]);
    }),
  );
}

Widget _icon() {
  return ClipRRect(
      borderRadius: BorderRadius.circular(37.5),
      child: Image.asset(
        'assets/images/logo.png',
        width: 200.0,
        height: 75.0,
        fit: BoxFit.fill,
      ));
}

PreferredSizeWidget signUpAppBar(BuildContext context) {
  final appBarHeight = AppBar().preferredSize.height;
  return PreferredSize(
    preferredSize: Size.fromHeight(appBarHeight),
    child: AppBar(
      // leading: IconButton(
      //   icon: Icon(Icons.arrow_back, color: Colors.white70),
      //   // onPressed: () => Navigator.of(context).pop(),
      // ),
      bottomOpacity: 0.0,
      elevation: 0.0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.black,
      title: _icon(),
    ),
  );
}
