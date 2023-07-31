import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/choice_button.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/empty_screen.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/generic_black_text_button.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/group_card.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/page_loading_view.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/timer.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/update_first_blur.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/user_card.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/view_user.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/friends/friend_list_screen.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_screen.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/match_list_screen.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';

class MeetView extends StatefulWidget {
  final ScrollController controller;
  const MeetView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<MeetView> createState() => _MeetViewState();
}

class _MeetViewState extends State<MeetView> {
  final supabase = Supabase.instance.client;
  final keys = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    // final userId = supabase.auth.currentUser!.id;
    // initListeners(userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AppViewBloc>()),
          BlocProvider.value(value: context.read<FriendsBloc>()),
          BlocProvider.value(value: context.read<MeetBloc>()),
        ],
        child: BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
          return Scaffold(
            appBar: _appBar(),
            body: _meetPeopleBody(controller),
          );
        }));
  }

  PreferredSizeWidget _appBar() {
    final appBarHeight = AppBar().preferredSize.height;
    return PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
          final appViewBloc = context.read<AppViewBloc>();
          bool userHasCrew = (state.usersCrew != null);
          List<Profile>? otherUsers = getOtherUsersFromCrew(currentUser: state.user, usersCrew: state.usersCrew);
          int? notifications = state.user.receivedCrewRequests?.length;
          return AppBar(
            actions: [
              Center(
                  child: Stack(children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: userHasCrew
                      ? _crewDisplayButton(state.usersCrew?.groupPhotoUrl ?? otherUsers.first.avatarUrl!)
                      : IconButton(
                          icon: const Icon(
                            Icons.group_add,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                        create: (context) => CrewRequestBloc(appViewBloc: appViewBloc, crewRepo: context.read<CrewRepository>(), user: state.user)..add(InitCrewRequestEvent()),
                                        child: CrewRequestScreen(
                                          friends: context.read<FriendsBloc>().state.friends,
                                          meetBloc: context.read<MeetBloc>(),
                                          storageRepo: context.read<StorageRepository>(),
                                        ))));
                          },
                        ),
                ),
                if (notifications != 0 && notifications != null && !userHasCrew)
                  Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Center(
                            child: Text(
                              notifications.toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      )),
              ])),
            ],
            title: Text(state.city),
          );
        }));
  }

  Widget _crewDisplayButton(String imageUrl) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      final appViewBloc = context.read<AppViewBloc>();
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BlocProvider(
                        create: (context) => CrewRequestBloc(appViewBloc: appViewBloc, crewRepo: context.read<CrewRepository>(), user: state.user)..add(InitCrewRequestEvent()),
                        child: CrewRequestScreen(
                          friends: context.read<FriendsBloc>().state.friends,
                          meetBloc: context.read<MeetBloc>(),
                          storageRepo: context.read<StorageRepository>(),
                        ),
                      )));
        },
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.black,
          ),
          width: 40,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      );
    });
  }

  Widget _meetPeopleBody(ScrollController controller) {
    return BlocBuilder<MeetBloc, MeetState>(
      builder: (context, state) {
        final boxWidth = MediaQuery.of(context).size.width;
        final boxHeight = MediaQuery.of(context).size.height - (AppBar().preferredSize.height);
        bool? userProfileUpdated = isUserProfileUpdated(state.user);
        final crews = state.crews ?? [];
        Match? confirmedMatch = state.confirmedMatch;
        // Crew? confirmedMatchOtherCrew = (confirmedMatch?.crewIdOne == state.usersCrew?.id) ? confirmedMatch?.crewTwo : confirmedMatch?.crewOne;
        final loadingState = state.loadingState;
        void onLoadMoreCrews() => context.read<MeetBloc>().add(RefreshCrewsAlreadySwipedEvent());
        bool dropToday = (state.dropTime != null);
        return loadingState is Loading
            ? pageLoadingView()
            : (!userProfileUpdated)
                ? updateFirstBlur(context, backgroundWidget, "Update your profile to see what all the Buzz is about!", Colors.white, onPressed, boxWidth, boxHeight)
                : dropToday
                    ? DateTime.now().isAfter(state.dropTime!)
                        ? (confirmedMatch != null)
                            ? _confirmedMatchScreen()
                            : (crews.isNotEmpty)
                                ? _crewScreen(controller)
                                : emptyScreen(context, "No crews to display!", onLoadMoreCrews, "Refresh crews you've already swiped")
                        : const Scaffold(
                            body: Center(
                              child: Text("Dropping soon...."),
                            ),
                          )
                    : const Scaffold(
                        body: Center(
                          child: Text("Dropping later this week...."),
                        ),
                      );
      },
    );
  }

  Widget _crewScreen(ScrollController controller) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      final crews = state.crews ?? [];
      return Stack(
        alignment: Alignment.center,
        children: [
          if (state.pressed && state.like) const Center(child: Icon(Icons.celebration, color: Colors.black, size: 110)),
          if (state.pressed && !state.like) const Center(child: Icon(Icons.clear, color: Colors.black, size: 80)),
          _crewDisplay(crews[0], controller),
          _dislikeButton(controller),
          _likeButton(controller),
        ],
      );
    });
  }

  Widget _crewDisplay(Crew crew, ScrollController controller) {
    return BlocBuilder<MeetBloc, MeetState>(
      builder: (context, state) {
        bool pressed = state.pressed;
        final List<GlobalKey> _keys = List.generate(crew.users!.length, (index) => GlobalKey());
        Function? onUserTap(int index) {
          var currentScrollOffset = controller.offset;
          var offset = (_keys[index].currentContext!.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
          controller.animateTo(currentScrollOffset + offset.dy - 125, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
        }

        return AnimatedPositioned(
          top: pressed ? 1000.0 : 0.0,
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          duration: const Duration(milliseconds: 650),
          child: SingleChildScrollView(
              controller: controller,
              primary: false,
              physics: const ScrollPhysics(),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                _names(crew),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.95,
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: GroupCard(
                    crew: crew,
                    roundedTopCorners: true,
                    onUserTap: onUserTap,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                _viewCrewWidget(crew),
                const SizedBox(
                  height: 40,
                ),
                _viewUsers(_keys),
                const SizedBox(
                  height: 120,
                ),
              ])),
        );
      },
    );
  }

  Widget _names(Crew crew) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      List<Profile?> users = crew.users!.values.toList();
      List<String> names = [for (var user in users) user!.name!.split(" ").first];
      String nameString = (names.length > 2) ? names[0] + ', ' + names[1] + ' and ' + names[2] : names[0] + ' and ' + names[1];
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            width: 20,
            height: 80,
          ),
          Text(nameString, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      );
    });
  }

  Widget _viewCrewWidget(Crew crew) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      double width = MediaQuery.of(context).size.width * 0.95;
      int? receivedLikes = crew.receivedLikes?.length;
      Map<dynamic, Profile>? mutualFriends = crew.usersMutualFriends;
      Map<dynamic, Match>? previousMatchesTogether = crew.previousMatchesTogether;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.2) /*Colors.black.withOpacity(0.1)*/, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        constraints: BoxConstraints(maxWidth: width),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            if (mutualFriends != null && mutualFriends.isNotEmpty) _friendsTogether(crew),
            if (previousMatchesTogether != null && previousMatchesTogether.isNotEmpty) _matchesTogether(crew),
            if (receivedLikes != null && receivedLikes >= 3) _receivedLikes(crew),
          ],
        ),

        // ),
      );
    });
  }

  Widget _friendsTogether(Crew crew) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      Map<dynamic, Profile> mutualFriends = crew.usersMutualFriends!;
      List<Profile?> users = crew.users!.values.toList();
      List<String> names = [for (var user in users) user!.name!.split(" ").first];
      String nameString = (names.length > 2) ? names[0] + ', ' + names[1] + ' and ' + names[2] : names[0] + ' and ' + names[1];
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FriendListScreen(
                        friendsBloc: context.read<FriendsBloc>(),
                        friends: mutualFriends,
                        heading: nameString + "'s friends",
                        currentUser: state.user,
                        // friendsBloc: context.read<FriendsBloc>(),
                      )));
        },
        child: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 50.0),
            child: ListTile(
                leading: const Icon(
                  Icons.people,
                  color: Colors.black,
                ),
                title: crewMutualFriendsToText(mutualFriends))),
      );
    });
  }

  Widget _matchesTogether(Crew crew) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      Map<dynamic, Match> previousMatchesTogether = crew.previousMatchesTogether!;
      List<Profile?> users = crew.users!.values.toList();
      List<String> names = [for (var user in users) user!.name!.split(" ").first];
      String nameString = (names.length > 2) ? names[0] + ', ' + names[1] + ' and ' + names[2] : names[0] + ' and ' + names[1];
      bool mutualFriends = (crew.usersMutualFriends != null && crew.usersMutualFriends!.isNotEmpty);

      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => MatchListScreen(
                        matchHistory: previousMatchesTogether,
                        // friendsBloc: context.read<FriendsBloc>(),
                        // friends: friends,
                        heading: nameString + "'s matches",
                        currentUser: state.user,
                        friendsBloc: context.read<FriendsBloc>(),
                      )));
        },
        child: Container(
          decoration: BoxDecoration(
            border: (mutualFriends) ? Border(top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ListTile(
              leading: const Icon(
                Icons.celebration,
                color: Colors.black,
              ),
              title: crewPreviousMatchesToText(crew.previousMatchesTogether!),
            ),
          ),
        ),
      );
    });
  }

  Widget _receivedLikes(Crew crew) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      int receivedLikes = crew.receivedLikes!.length;
      bool mutualFriends = (crew.usersMutualFriends != null && crew.usersMutualFriends!.isNotEmpty);
      bool previousMatches = (crew.previousMatchesTogether != null && crew.previousMatchesTogether!.isNotEmpty);
      return GestureDetector(
        onTap: () {
          if (state.user.subscription == 'premium') {
            // TODO: implement Navigation to some likes view screen here
            debugPrint("yeah you can go here");
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: (mutualFriends || previousMatches) ? Border(top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)) : null,
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  title: Text.rich(
                    TextSpan(text: "They've received ", style: const TextStyle(fontSize: 16), children: [
                      TextSpan(
                        text: receivedLikes.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " like" + (receivedLikes == 1 ? "" : "s") + " already!"),
                    ]),
                  ))),
        ),
      );
    });
  }

  Widget _viewUsers(List<GlobalKey> _keys) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      final appViewBloc = context.read<AppViewBloc>();
      final width = MediaQuery.of(context).size.width * 0.95;
      void onProfileTap(Profile userProfile) {
        Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: "/firstOfChain"),
                builder: (_) => BlocProvider(
                      create: (context) => ProfileViewBloc(
                        appViewBloc: appViewBloc,
                        likesRepo: context.read<LikesRepository>(),
                        currentUser: state.user,
                        userProfile: userProfile,
                      )..add(InitViewProfileEvent()),
                      child: ProfileView(
                        friendsBloc: context.read<FriendsBloc>(),
                      ),
                    )));
      }

      final users = state.crews![0].users;

      return SizedBox(
        width: width,
        child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => const SizedBox(height: 50),
            itemCount: users!.length,
            itemBuilder: (context, index) {
              final user = users.values.elementAt(index);

              void onFriendsTap(Map<dynamic, Profile> friends) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FriendListScreen(
                              friendsBloc: context.read<FriendsBloc>(),
                              friends: friends,
                              heading: user.name! + "'s friends",
                              currentUser: state.user,
                              // friendsBloc: context.read<FriendsBloc>(),
                            )));
              }

              void onMatchHistoryTap(Map<dynamic, Match> previousMatchesTogether) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MatchListScreen(
                              matchHistory: previousMatchesTogether,
                              // friendsBloc: context.read<FriendsBloc>(),
                              // friends: friends,
                              heading: user.name! + "'s matches",
                              currentUser: state.user,
                              friendsBloc: context.read<FriendsBloc>(),
                            )));
              }

              return Container(
                key: _keys[index],
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.2) /*Colors.black.withOpacity(0.1)*/, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                constraints: BoxConstraints(maxWidth: width),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: () {
                        onProfileTap(user);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 60,
                          ),
                          Text(user.name!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        onProfileTap(user);
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.95,
                        child: UserCard(
                          user: user,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    viewUserWidget(user, width, onProfileTap, onFriendsTap: onFriendsTap, onMatchHistoryTap: onMatchHistoryTap, border: false),
                    // const SizedBox(
                    //   height: 10,
                    // )
                  ],
                ),
              );
            }),
      );
    });
  }

  Widget _dislikeButton(ScrollController controller) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      final crews = state.crews!;
      return Positioned(
        left: 20,
        bottom: 20,
        child: InkWell(
            borderRadius: BorderRadius.circular(30),
            child: ChoiceButton(
              color: Theme.of(context).colorScheme.secondary,
              icon: Icons.clear_rounded,
            ),
            onTap: () async {
              if (crews.isNotEmpty && !state.pressed) {
                context.read<MeetBloc>().add(SendLikeEvent(
                      user: state.user,
                      currentCrew: state.usersCrew,
                      otherCrew: crews[0],
                      like: false,
                    ));
                await Future.delayed(const Duration(milliseconds: 850));
                setState(() {
                  crews.remove(crews[0]);
                  controller.jumpTo(0);
                });
                context.read<MeetBloc>().add(ButtonPressed(pressed: false));
              }
            }),
      );
    });
  }

  Widget _likeButton(ScrollController controller) {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      final crews = state.crews!;
      return Positioned(
        right: 20,
        bottom: 20,
        child: InkWell(
            borderRadius: BorderRadius.circular(40),
            child: const ChoiceButton(
              width: 80,
              height: 80,
              size: 30,
              color: Colors.white,
              hasGradient: true,
              icon: Icons.celebration,
            ),
            onTap: () async {
              if (crews.isNotEmpty && !state.pressed) {
                context.read<MeetBloc>().add(SendLikeEvent(
                      user: state.user,
                      currentCrew: state.usersCrew,
                      otherCrew: crews[0],
                      like: true,
                    ));
                await Future.delayed(const Duration(milliseconds: 850));
                setState(() {
                  crews.remove(crews[0]);
                  controller.jumpTo(0);
                });
                context.read<MeetBloc>().add(ButtonPressed(pressed: false));
              }
            }),
      );
    });
  }

  Widget _confirmedMatchScreen() {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      Match confirmedMatch = state.confirmedMatch!;
      dynamic time = matchCountdownTime(/*confirmedMatch.createdAt!*/);

      Crew? confirmedMatchOtherCrew = (confirmedMatch.crewIdOne == state.usersCrew?.id) ? confirmedMatch.crewTwo : confirmedMatch.crewOne;
      void onButtonPressed() {
        context.read<MeetBloc>().add(UpdateSelectedVenues());
      }

      return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.width * (1.4), width: MediaQuery.of(context).size.width, child: Center(child: GroupCard(crew: confirmedMatchOtherCrew!))),
              const SizedBox(height: 40),
              // _viewMatchWidget(),
              // const SizedBox(height: 40),
              _venuesList(),
              const SizedBox(height: 20),
              genericButton("Save selection", onButtonPressed),
              CountDownTimer(secondsRemaining: time),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _viewMatchWidget() {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      double width = MediaQuery.of(context).size.width * 0.95;
      Match? confirmedMatch = state.confirmedMatch;
      Crew? confirmedMatchOtherCrew = (confirmedMatch?.crewIdOne == state.usersCrew?.id) ? confirmedMatch?.crewTwo : confirmedMatch?.crewOne;
      List<Profile?> users = confirmedMatchOtherCrew!.users!.values.toList();
      List<String> names = [for (var user in users) user!.name!.split(" ").first];
      String nameString = (names.length > 2) ? names[0] + ', ' + names[1] + ' and ' + names[2] : names[0] + ' and ' + names[1];

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.2) /*Colors.black.withOpacity(0.1)*/, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        constraints: BoxConstraints(maxWidth: width),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Text("Match with " + nameString),
          ],
        ),

        // ),
      );
    });
  }

  Widget _venuesList() {
    return BlocBuilder<MeetBloc, MeetState>(builder: (context, state) {
      /* 
      - Each row should display 'Name and 4 othre friends went here recently / x people are going here tonight
      - When clicked, can see lists of who was there and their profiles, like FB event
    */
      Map<String, IconData> iconsMap = {
        'wine_bar': Icons.wine_bar,
        'pub': Icons.sports_bar,
        'restaurant': Icons.restaurant,
        'cocktail_bar': Icons.local_drink,
      };
      List<Venue> venues = state.venues!;

      List<bool> isChecked = state.venueIsChecked!;

      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: const BorderRadius.all(
              Radius.circular(15.0),
            ),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 2,
                spreadRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.venues?.length,
              itemBuilder: (BuildContext context, int index) {
                final venue = venues[index];
                return ListTile(
                  leading: Icon(iconsMap[venue.type]),
                  // leading: _avatar("https://firmbuilding.backendless.app/api/files/profile-pictures/" + state.potentialFriends![index]!.getObjectId()),
                  trailing: Checkbox(
                    value: isChecked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked[index] = value!;
                      });
                    },
                  ),
                  title: Text(venue.name!),
                  subtitle: const Text(
                    "Last Friday, Ronan O'Kelly and 4...",
                  ),
                );
              }),
        ),
      );
    });
  }

  Widget backgroundWidget() {
    return Container();
  }

  void onPressed() => context.read<AppViewBloc>().add(UpdateIndexEvent(index: 4));

  void initListeners(String userId) async {
    supabase.channel('crew_requests').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'crew_requests', filter: 'receiver_id=eq.$userId'),
      (payload, [ref]) {
        context.read<MeetBloc>().add(CrewRequestListenerEvent(data: payload));
      },
    ).subscribe();

    // supabase.channel('matches').on(
    //   RealtimeListenTypes.postgresChanges,
    //   ChannelFilter(event: 'INSERT', schema: 'public', table: 'matches', filter: 'receiver_id=eq.$userId'),
    //   (payload, [ref]) {
    //     context.read<MeetBloc>().add(MatchListenerEvent(data: payload));
    //   },
    // ).subscribe();
  }
}
