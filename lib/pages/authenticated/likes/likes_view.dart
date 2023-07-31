import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match_confirmation.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/button_dialog.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/empty_screen.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/generic_black_text_button.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/group_card.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/padded_title.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/premium_dialog.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/update_first_blur.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/likes/likes_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/likes/likes_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/likes/likes_state.dart';

class LikesView extends StatefulWidget {
  const LikesView({Key? key}) : super(key: key);

  @override
  State<LikesView> createState() => _LikesViewState();
}

class _LikesViewState extends State<LikesView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LikesBloc, LikesState>(listener: (context, state) {
      if (state.directReroute == true) {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (_) => ConfirmMatchScreen(
        //               group: state.pendingMatches!.first, // V Loose?? Will it always push the correct one?
        //               venues: state.venues ?? [],
        //               likesRepo: context.read<LikesRepository>(),
        //             )));
        // context.read<LikesBloc>().add(ResetRouteEvent());
      }
    }, child: BlocBuilder<LikesBloc, LikesState>(builder: (context, state) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Matches & Likes"),
          ),
          body: RefreshIndicator(
              onRefresh: () async {
                context.read<LikesBloc>().add(LikesReloadEvent());
              },
              child: GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Center(
                    child: _body(),
                  ))));
    }));
  }

  Widget _body() {
    return BlocBuilder<LikesBloc, LikesState>(builder: (context, state) {
      final loadingState = state.loadingState;
      final bool blur = (state.user.subscription == "premium") ? false : true;
      bool? userProfileUpdated = isUserProfileUpdated(state.user);
      final bool userHasMatch = state.confirmedMatch != null ? true : false;
      final boxWidth = MediaQuery.of(context).size.width;
      final boxHeight = MediaQuery.of(context).size.height;
      return loadingState is Loading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 10),
                Center(
                  child: CircularProgressIndicator(),
                ),
                SizedBox(height: 100),
              ],
            )
          : (!userProfileUpdated)
              ? updateFirstBlur(context, backgroundWidget, "Update your profile and the likes will start flowing in!", Colors.black, onPressed, boxWidth, boxHeight)
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child:
                      // Center(
                      //   child:
                      (state.pendingMatches != null && state.pendingMatches!.isNotEmpty) || (state.receivedLikes != null && state.receivedLikes!.isNotEmpty)
                          ? Container(
                              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.75),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (userHasMatch) match(),
                                  pendingMatches(),
                                  receivedLikes(blur),
                                  // if (userHasMatch)
                                  //   BackdropFilter(
                                  //     filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                  //     child: Container(
                                  //       // height: 50,
                                  //       decoration: BoxDecoration(
                                  //         color: Colors.white.withOpacity(0.0),
                                  //       ),
                                  //     ),
                                  //   )
                                ],
                              ))
                          : emptyScreen(context, "No likes quite yet", onPressed, "Get your crew and get out there!"),
                );
    });
  }

  Widget match() {
    return BlocBuilder<LikesBloc, LikesState>(builder: (context, state) {
      final match = state.confirmedMatch;
      return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
              initiallyExpanded: true,
              maintainState: true,
              title: const Text(
                "Match",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              children: [matchCard()]));
    });
  }

  Widget matchCard() {
    return Container();
  }

  Widget pendingMatches() {
    return BlocBuilder<LikesBloc, LikesState>(builder: (context, state) {
      var pendingMatches = state.pendingMatches;
      final bool userHasMatch = state.confirmedMatch != null ? true : false;
      var headingText = "Pending matches " + ((pendingMatches != null && pendingMatches.isNotEmpty) ? "(" + pendingMatches.length.toString() + ")" : "");
      return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
              initiallyExpanded: !userHasMatch,
              maintainState: true,
              title: Text(
                headingText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              children: [
                if (pendingMatches != null && pendingMatches.isNotEmpty)
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pendingMatches.length,
                      itemBuilder: (BuildContext context, int index) {
                        final pendingMatch = pendingMatches.values.elementAt(index);
                        return pendingMatchCard(pendingMatch);
                      }),
                if (pendingMatches == null || pendingMatches.isEmpty) emptyPendingMatches()
              ]));
    });
  }

  Widget pendingMatchCard(MatchConfirmation pendingMatch) {
    return BlocBuilder<LikesBloc, LikesState>(builder: (context, state) {
      Crew? ownCrew = state.user.crew;
      TextSpan? otherNamesOwnCrew = otherNamesFromOwnCrew(state.user, ownCrew);
      Crew? crew = pendingMatch.otherCrew;
      List<Profile?> users = crew!.users!.values.toList();
      List<String> names = [for (var user in users) user!.name!.split(" ").first];
      String nameString = (names.length > 2) ? names[0] + ', ' + names[1] + ' and ' + names[2] : names[0] + ' and ' + names[1];
      var heading = nameString;
      bool confirmed = (pendingMatch.confirmed != null && pendingMatch.confirmed!);
      void onConfirmPressed() => context.read<LikesBloc>().add(ConfirmPendingMatchEvent(pendingMatch: pendingMatch));
      // var subheading = 'Friends with ... and 348 others';
      // var supportingText = 'Last week, they were out with ...';
      return GestureDetector(
        onTap: () {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (_) => ConfirmMatchScreen(
          //               group: group,
          //               venues: venues ?? [],
          //               likesRepo: context.read<LikesRepository>(),
          //             )));
        },
        child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    heading,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // subtitle: Text(subheading),
                  // trailing: const Icon(
                  //   Icons.celebration_rounded,
                  //   color: Colors.pink,
                  // ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width - 34,
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: GroupCard(
                      roundedTopCorners: true,
                      crew: crew,
                    ),
                  )),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20, right: 10, left: 20, bottom: 15),
                  // padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                          child: Text.rich(TextSpan(text: "They want to go out tonight with you", children: <TextSpan>[
                        otherNamesOwnCrew ?? const TextSpan(text: ""),
                      ]))),
                      const SizedBox(
                        width: 30,
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(confirmed ? Colors.black : Colors.white),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 1, color: Colors.black.withOpacity(0.5)), borderRadius: BorderRadius.circular(5))),
                          // side: MaterialStateProperty.all(const BorderSide(width: 1, color: Colors.black))
                        ),
                        onPressed: () {
                          showButtonDialog(context, "Confirm", const Text("Are you sure you want to go out with them tonight?"),
                              onConfirmed: onConfirmPressed,
                              subContent: const Text("Once everybody confirms, we'll pick a venue!",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  )));
                        },
                        child: (confirmed)
                            ? const Text(
                                "Waiting on others...",
                                style: TextStyle(color: Colors.white),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.celebration),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Let's go!",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      );
    });
  }

  Widget emptyPendingMatches() {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
              child: Container(
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1, color: Colors.black.withOpacity(0.1)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(7.0),
              child: Text(
                "No matches just yet, keep swiping!",
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget receivedLikes(bool blur) {
    return BlocBuilder<LikesBloc, LikesState>(
      builder: (context, state) {
        var receivedLikes = state.receivedLikes;
        var olderReceivedLikes = state.olderReceivedLikes;
        var pendingMatches = state.pendingMatches;
        var headingText = "Likes " + ((receivedLikes != null && receivedLikes.isNotEmpty) ? "(" + receivedLikes.length.toString() + ")" : "");
        String buttonText = "Load older likes";
        bool premium = !blur;
        double width = MediaQuery.of(context).size.width;
        void onButtonPressed() {
          if (premium) {
            context.read<LikesBloc>().add(LoadOlderLikes());
          } else {
            showPremiumDialog(context);
          }
        }

        return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
                initiallyExpanded: (pendingMatches == null || pendingMatches.isEmpty),
                maintainState: true,
                title: Text(
                  headingText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                children: [
                  receivedLikes != null
                      ? receivedLikes.length > 1
                          ? Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                for (var user in receivedLikes.values.toList())
                                  if (user != null) likeCard(user, blur)
                              ],
                            )
                          : Row(
                              children: [
                                for (var user in receivedLikes.values.toList())
                                  if (user != null) likeCard(user, blur)
                              ],
                            )
                      : Container(),
                  if (olderReceivedLikes != null) paddedUnderlinedTitle("Older", width),
                  olderReceivedLikes != null
                      ? olderReceivedLikes.length > 1
                          ? Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                for (var like in olderReceivedLikes.values.toList())
                                  // TODO: implement date on older received likes card, maybe in place of "last week"
                                  if (like != null) likeCard(like.user!, blur)
                              ],
                            )
                          : Row(
                              children: [
                                for (var like in olderReceivedLikes.values.toList())
                                  if (like != null) likeCard(like.user!, blur)
                              ],
                            )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  genericButton(buttonText, onButtonPressed),
                  const SizedBox(
                    height: 10,
                  ),
                ]));
      },
    );
  }

  Widget likeCard(Profile user, bool blur) {
    String? name = user.name!;
    var heading = name;
    var friends = user.friends?.values;
    var matchHistory = user.matchHistory;
    var subheading = (friends != null && friends.isNotEmpty)
        ? Text(
            'Friends with ' + friends.first.name! + ((friends.length > 1) ? " and " + (friends.length - 1).toString() + " other" : "") + ((friends.length > 2) ? "s" : ""),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        : null;
    var supportingText = (matchHistory != null && matchHistory.isNotEmpty) ? userMatchHistoryToText(matchHistory) : null;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: () {
          // TODO: implement view profile here
        },
        child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 4.0,
            child: SizedBox(
              width: (MediaQuery.of(context).size.width - 18) / 2,
              child: likeColumn(user, blur),
            )),
      )
    ]);
  }

  Widget likeColumn(Profile user, bool blur) {
    return BlocBuilder<LikesBloc, LikesState>(builder: (context, state) {
      String? name = user.name!;
      var heading = name;
      var friends = user.friends?.values;
      var matchHistory = user.matchHistory;
      var subheading = (friends != null && friends.isNotEmpty)
          ? Text(
              'Friends with ' + friends.first.name! + ((friends.length > 1) ? " and " + (friends.length - 1).toString() + " other" : "") + ((friends.length > 2) ? "s" : ""),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null;
      var supportingText = (matchHistory != null && matchHistory.isNotEmpty) ? userMatchHistoryToText(matchHistory) : null;
      return Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  heading,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: subheading,
                trailing: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.width - 34) / 2,
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: cardImage(context, user.avatarUrl!, blur),
                )),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: supportingText,
              ),
            ],
          ),
          if (blur)
            Positioned.fill(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.0),
                      ),
                    ),
                  )),
            )
        ],
      );
    });
  }

  Widget cardImage(BuildContext context, String imageUrl, bool blur) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        height: 220,
        width: MediaQuery.of(context).size.width / 2.2,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey.withOpacity(0.5)),
          color: Colors.transparent,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: blur
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    // height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.0),
                    ),
                  ),
                ),
              )
            : Container(),
      ),
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  Widget backgroundWidget() {
    // TODO: implement likesView background widget
    return GestureDetector(
      onTap: () {
        // do nothing
        // this is so that anything behind the blur widget is untouchable
      },
      child: SizedBox(
        height: double.infinity,
        child: receivedLikes(false),

        // Center(
        //   child: Text(
        //       "This should be blurred, Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32. There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc. There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc. There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc."),
        // ),
      ),
    );
  }

  void onPressed() => context.read<AppViewBloc>().add(UpdateIndexEvent(index: 4));
}
