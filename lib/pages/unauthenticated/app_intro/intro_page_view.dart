import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/app_bars.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_state.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/app_intro/pages/intro_page_four.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/app_intro/pages/intro_page_five.dart';

import 'package:white_ui_supabase4/pages/unauthenticated/app_intro/pages/intro_page_one.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/app_intro/pages/intro_page_three.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/app_intro/pages/intro_page_two.dart';

class IntroPageView extends StatefulWidget {
  const IntroPageView({Key? key}) : super(key: key);

  @override
  State<IntroPageView> createState() => _IntroPageViewState();
}

class _IntroPageViewState extends State<IntroPageView> {
  final PageController _pageController = PageController(initialPage: 0);
  int _activePage = 0;

  final List<Widget> _pages = [
    const IntroPageOne(),
    const IntroPageTwo(),
    const IntroPageThree(),
    const IntroPageFour(),
    const IntroPageFive(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: introAppBar(context),
          body: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _activePage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _pages[index % _pages.length];
                },
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                      _pages.length,
                      (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: InkWell(
                              onTap: () {
                                _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                              },
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: _activePage == index ? Colors.black : Colors.grey,
                              ),
                            ),
                          )),
                ),
              ),
              Positioned(bottom: 30, left: 0, right: 0, child: Padding(padding: const EdgeInsets.all(20.0), child: _continueButton(_activePage))),
            ],
          ),
        );
      },
    );
  }

  Widget _continueButton(int index) {
    int nextIndex = index + 1;
    bool lastPage = (index == 4);
    return ElevatedButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(const Size(100, 50)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: const BorderSide(width: 1, color: Colors.black54),
          )),
        ),
        onPressed: () {
          lastPage ? _getStarted() : _pageController.animateToPage(nextIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        },
        child: Text(lastPage ? 'Get Started' : 'Continue',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )));
  }

  void _getStarted() {
    context.read<AuthCubit>().showName();
  }
}
