import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/onboarding/onboarding_cubit.dart';
import 'package:white_ui_supabase4/pages/onboarding/onboarding_navigator.dart';
import 'package:white_ui_supabase4/session_navigation/session_state.dart';
import 'package:white_ui_supabase4/session_navigation/session_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_navigator.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/loading_view.dart';

class SessionNavigator extends StatelessWidget {
  const SessionNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(builder: (context, state) {
      return Navigator(
        pages: [
          if (state is UnknownSessionState) const MaterialPage(child: LoadingView()),

          // Show auth flow
          if (state is Unauthenticated)
            MaterialPage(
              child: BlocProvider.value(
                value: context.read<AuthCubit>(),
                child: const AuthNavigator(),
              ),
            ),

          // Show onboarding flow
          if (state is Onboarding)
            MaterialPage(
              child: BlocProvider(
                create: (context) => OnboardingCubit(sessionCubit: context.read<SessionCubit>()),
                child: const OnboardingNavigator(),
              ),
            ),

          // Show session flow
          if (state is Authenticated) //MaterialPage(child: BasicView(user: context.read<SessionCubit>().state.user!)),
            MaterialPage(
              child: BlocProvider(
                  create: (context) => AppViewBloc(user: context.read<SessionCubit>().state.user!, crewRepo: context.read<CrewRepository>())..add(InitAppEvent()),
                  child: AppView(initialCrews: context.read<SessionCubit>().state.groups)), // could this be handled in an Init State event in the bloc?
            ),
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
