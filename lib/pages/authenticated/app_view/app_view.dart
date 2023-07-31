import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/precache_image_data.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/scroll_to_hide_widget.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/droptime_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/friends_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/loading_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/feed/feed_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/feed/feed_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/feed/feed_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/likes/likes_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/likes/likes_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/likes/likes_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/edit_profile/edit_profile.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/edit_profile/edit_profile_bloc.dart';
import 'package:white_ui_supabase4/session_navigation/session_cubit.dart';

class AppView extends StatefulWidget {
  final List<Crew>? initialCrews;
  const AppView({Key? key, required this.initialCrews}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  int currentIndex = 2;
  bool _imagesLoaded = false;
  final supabase = Supabase.instance.client;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  late ScrollController controller;
  late List<Widget> screens;

  @override
  void initState() {
    // final userId = supabase.auth.currentUser!.id;
    WidgetsBinding.instance!.addPostFrameCallback((_) => precacheGroupsImageData(widget.initialCrews, context, updateImagesLoadedState));
    // initListeners(userId);
    controller = ScrollController();
    generateSreens();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateIndex(int index) {
    setState(() => currentIndex = index);
  }

  void clearGroup() {
    context.read<AppViewBloc>().add(ClearGroup());
  }

  void updateImagesLoadedState() {
    debugPrint("Background image loading complete...");
    setState(() => _imagesLoaded = true);
  }

  generateSreens() {
    screens = [
      MeetView(controller: controller),
      const LikesView(),
      const FeedView(),
      const FriendsView(),
      const EditProfile(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sessionCubit = context.read<SessionCubit>();
    return MultiBlocProvider(
        providers: [
          // ############
          // MEET
          // ############
          BlocProvider(
            create: (context) => MeetBloc(
              appViewBloc: context.read<AppViewBloc>(),
              friendsRepo: context.read<FriendsRepository>(),
              storageRepo: context.read<StorageRepository>(),
              crewRepo: context.read<CrewRepository>(),
              likesRepo: context.read<LikesRepository>(),
              dropRepo: context.read<DroptimeRepository>(),
              venueRepo: context.read<VenueRepository>(),
              user: sessionCubit.state.user!,
              dropTime: sessionCubit.state.droptime,
            )..add(InitMeetEvent(initialCrews: widget.initialCrews!)),
          ),
          // ############
          // LIKES
          // ############
          BlocProvider(
              create: (context) => LikesBloc(
                    appViewBloc: context.read<AppViewBloc>(),
                    likesRepo: context.read<LikesRepository>(),
                    crewRepo: context.read<CrewRepository>(),
                    venueRepo: context.read<VenueRepository>(),
                    user: sessionCubit.state.user!,
                  )..add(InitLikesEvent())),
          // ############
          // FEED
          // ############
          BlocProvider(create: (context) => FeedBloc(appViewBloc: context.read<AppViewBloc>(), likesRepo: context.read<LikesRepository>(), user: sessionCubit.state.user!)..add(InitFeedEvent())),
          // ############
          // FRIENDS
          // ############
          BlocProvider(
            create: (context) => FriendsBloc(
              appViewBloc: context.read<AppViewBloc>(),
              friendsRepo: context.read<FriendsRepository>(),
              storageRepo: context.read<StorageRepository>(),
              user: sessionCubit.state.user!,
            )..add(InitFriendsEvent()),
          ),
          // ############
          // PROFILE
          // ############
          BlocProvider(
            create: (context) => EditProfileBloc(
              appViewBloc: context.read<AppViewBloc>(),
              storageRepo: context.read<StorageRepository>(),
              likesRepo: context.read<LikesRepository>(),
              userProfile: sessionCubit.state.user!,
            ),
          ),
        ],
        child: BlocListener<AppViewBloc, AppViewState>(listener: (context, state) {
          if (state.matchedCrew != null) {
            // Matched Group can be confirmed or pending
            if (state.matched == true) {
              // Navigator.of(context).push(createRoute(
              //   // MatchPopup(group: state.matchedGroup!)
              //   // updateIndex,
              //   // clearGroup,
              // ));
              // context.read<LikesBloc>().add(MatchMatchListenerEvent(group: state.matchedGroup, venue: state.matchedVenue)); // Matched Group can be confirmed or pending
              // context.read<SwipeBloc>().add(SwipeMatchListenerEvent(group: state.matchedGroup, venue: state.matchedVenue)); // Matched Group can be confirmed or pending
              // // do something in LikesBloc
              // do something in swipeBloc
            } else {
              // Navigator.of(context).push(createRoute(
              //   PendingMatchPopup(state.matchedGroup!, // Matched Group can be confirmed or pending
              //   updateIndex,
              //   clearGroup,
              // )));
              // context.read<LikesBloc>().add(PendingLikesEvent(listenerGroup: state.matchedGroup!)); // Matched Group can be confirmed or pending
            }
            // context
          }
          if (state.clearGroup == true) {
            // context.read<LikesBloc>().add(DirectRerouteEvent());
          }
          if (state.refreshFriends == true) {
            // context.read<FeedBloc>().add(FeedReloadEvent());
          }
          // if(state.refreshUser == true){
          //   context.read<LikesBloc>().add(MatchReloadEvent());
          //   context.read<SwipeBloc>().add(SwipeReloadEvent());
          // }
          if (state.screenIndex != null) {
            updateIndex(state.screenIndex!);
          }
        }, child: BlocBuilder<AppViewBloc, AppViewState>(builder: (context, state) {
          return Scaffold(
            body: _imagesLoaded
                ? IndexedStack(
                    index: currentIndex,
                    children: screens,
                  )
                : const LoadingView(),
            bottomNavigationBar: ScrollToHideWidget(
              controller: controller,
              child: BottomNavigationBar(
                // type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.white70,
                showUnselectedLabels: false,
                currentIndex: currentIndex,
                onTap: (index) => updateIndex(index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.celebration,
                      color: Colors.black,
                    ),
                    label: "Meet People",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.black,
                    ),
                    label: "Matches & Likes",
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.sports_bar,
                        color: Colors.black,
                      ),
                      label: "Feed"),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    label: "Friends",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person, color: Colors.black),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          );
        })));
  }

  void initListeners(String userId) async {
    // final today = formatter.format(DateTime.now());

    supabase.channel('friendships').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'friendships', filter: 'user_id=eq.$userId'),
      (payload, [ref]) {
        context.read<AppViewBloc>().add(FriendshipListenerEvent(data: payload));
      },
    ).subscribe();

    supabase.channel('crew').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'crew', filter: 'user_id_one=eq.$userId'),
      (payload, [ref]) {
        context.read<AppViewBloc>().add(CrewListenerEvent(data: payload));
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'crew', filter: 'user_id_two=eq.$userId'),
      (payload, [ref]) {
        context.read<AppViewBloc>().add(CrewListenerEvent(data: payload));
      },
    ).on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'crew', filter: 'user_id_three=eq.$userId'),
      (payload, [ref]) {
        context.read<AppViewBloc>().add(CrewListenerEvent(data: payload));
      },
    ).subscribe();
  }
}
