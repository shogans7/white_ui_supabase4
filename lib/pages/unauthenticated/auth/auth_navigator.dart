import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/auth_repository.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_state.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/dob/dob_view.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/name/name_view.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_bloc.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_confirmation_screen.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/phone/phone_view.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/app_intro/intro_page_view.dart';

class AuthNavigator extends StatelessWidget {
  const AuthNavigator({Key? key}) : super(key: key);

  static Page<void> page() => const MaterialPage<void>(child: AuthNavigator());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Navigator(
        pages: [
          // Who they be attractin with that line
          if (state.screenState == ScreenState.intro) const MaterialPage(child: IntroPageView()),
          // What's your name?
          if (state.screenState == ScreenState.name) MaterialPage(child: NameView()),
          // What's your sign?
          if (state.screenState == ScreenState.dob) MaterialPage(child: DobView()),
          // As soon as he buy that wine, I just sneak up from behind...
          // Ask you what your interests are, who you be with
          // Things that make you smile, what numbers to dial
          if (state.screenState == ScreenState.phone || state.screenState == ScreenState.phoneConfirmation) ...[
            MaterialPage(
                child: BlocProvider(
              create: (context) => PhoneBloc(authRepo: context.read<AuthRepository>(), authCubit: context.read<AuthCubit>(), name: state.name!, dob: state.dob!),
              child: state.screenState == ScreenState.phone ? PhoneView() : PhoneConfirmationScreen(),
            )),
          ],
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
