import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/empty_screen.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/match_posts.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/match_posts.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/padded_title.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/update_first_blur.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/feed/feed_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/feed/feed_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/feed/feed_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
      final boxWidth = MediaQuery.of(context).size.width;
      final boxHeight = MediaQuery.of(context).size.height - (AppBar().preferredSize.height);
      return Scaffold(
          appBar: AppBar(
            title: const Text("Feed"),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<FeedBloc>().add(FeedReloadEvent());
              setState(() {
                print("I'm reloading");
              });
            },
            child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: _feedPage(),
            ),
          ));
    });
  }

  Widget _feedPage() {
    return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
      final FriendsBloc friendsBloc = context.read<FriendsBloc>();
      final AppViewBloc appViewBloc = friendsBloc.appViewBloc;

      final loadingState = state.loadingState;
      final boxWidth = MediaQuery.of(context).size.width;
      final boxHeight = MediaQuery.of(context).size.height;
      var todaysMatches = state.todaysMatches;
      var previousMatches = state.previousMatches;
      double width = MediaQuery.of(context).size.width;

      void onVenueTap(Venue venue) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BlocProvider(
                    create: (context) => VenueBloc(
                          currentUser: state.user,
                          venue: venue,
                          likesRepo: context.read<LikesRepository>(),
                          venueRepo: context.read<VenueRepository>(),
                        )..add(InitVenueEvent()),
                    child: VenueView(
                      friendsBloc: friendsBloc,
                    ))));
      }

      void onProfileTap(Profile userProfile) async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BlocProvider(
                    create: (context) => ProfileViewBloc(
                          appViewBloc: appViewBloc,
                          likesRepo: context.read<LikesRepository>(),
                          currentUser: state.user,
                          userProfile: userProfile,
                        )..add(InitViewProfileEvent()),
                    child: ProfileView(
                      friendsBloc: friendsBloc,
                    ))));
      }

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
          : (state.userHasFriends != null && !state.userHasFriends!)
              ? updateFirstBlur(context, backgroundWidget, "Add some friends to see what's happening!", Colors.white, onPressed, boxWidth, boxHeight)
              : (todaysMatches != null && todaysMatches.isNotEmpty)
                  ? SingleChildScrollView(
                      physics: const ScrollPhysics(),
                      child: Center(
                        child: Stack(children: [
                          // SafeArea(
                          //     child: SizedBox(
                          //   height: boxHeight,
                          //   width: boxWidth,
                          //   child:
                          Center(
                              child: Column(
                            children: [
                              paddedUnderlinedTitle("Tonight", width * 0.8),
                              matchPosts(todaysMatches, width, onVenueTap: onVenueTap, onProfileTap: onProfileTap),
                              if (previousMatches != null) paddedUnderlinedTitle("Older", width * 0.8),
                              if (previousMatches != null) matchPosts(previousMatches, width, onVenueTap: onVenueTap, onProfileTap: onProfileTap),
                              const SizedBox(
                                height: 10,
                              ),
                              _loadMorePostsButton(),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                            // )),
                          )),
                          // if (state.userHasFriends != null && !state.userHasFriends!)
                          //   updateFirstBlur(context, "Add some friends to get in on the action", () {
                          //     context.read<AppViewBloc>().add(UpdateIndexEvent(index: 3));
                          //   }, boxWidth, boxHeight),
                        ]),
                      ))
                  : emptyScreen(context, "Your feed is empty!", onPressed, "Add some more friends to see what's happening");
    });
  }

  // Widget _matchPosts(Map<dynamic, Match> matches) {
  //   return BlocBuilder<FeedBloc, FeedState>(
  //     builder: (context, state) {
  //       return ListView.builder(
  //           physics: const NeverScrollableScrollPhysics(),
  //           shrinkWrap: true,
  //           itemCount: matches.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             final match = matches.values.elementAt(index);
  //             return Card(
  //               child: Column(
  //                 children: [_venueImage(match.venue!), _crewsRow(match.crewOne!, match.crewTwo!)],
  //               ),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10.0),
  //               ),
  //               elevation: 5,
  //               margin: const EdgeInsets.all(10),
  //             );
  //           });
  //     },
  //   );
  // }

  // Widget _venueImage(Venue venue) {
  //   return SizedBox(
  //     height: MediaQuery.of(context).size.width / 3, // + appBarHeight,
  //     width: MediaQuery.of(context).size.width,
  //     child: GestureDetector(
  //       child: CachedNetworkImage(
  //         imageUrl: venue.venueUrl!,
  //         imageBuilder: (context, imageProvider) => Container(
  //           decoration: BoxDecoration(
  //             image: DecorationImage(
  //               alignment: Alignment.topCenter,
  //               image: imageProvider,
  //               fit: BoxFit.cover,
  //             ),
  //             borderRadius: const BorderRadius.all(Radius.circular(10)),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.5),
  //                 spreadRadius: 4,
  //                 blurRadius: 4,
  //                 offset: const Offset(3, 3),
  //               )
  //             ],
  //           ),
  //         ),
  //         placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
  //         errorWidget: (context, url, error) => const Icon(Icons.error),
  //       ),
  //       onTap: () {
  //         // TODO: implement this
  //         // Navigator.push(
  //         //     context,
  //         //     MaterialPageRoute(
  //         //         settings: const RouteSettings(name: "/firstOfChain"),
  //         //         builder: (_) => BlocProvider(
  //         //               create: (__) => VenueBloc(
  //         //                 venue: venue,
  //         //                 likesRepo: context.read<LikesRepository>(),
  //         //                 venuesRepo: context.read<VenuesRepository>(),
  //         //               )..add(InitVenueEvent()),
  //         //               child: VenueScreen(
  //         //                 // venue: match.venue,
  //         //                 feedBloc: context.read<FeedBloc>(),
  //         //               ),
  //         //             )));
  //       },
  //     ),
  //   );
  // }

  // Widget _crewsRow(Crew crewOne, Crew crewTwo) {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
  //     child: Row(
  //       // mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         Container(
  //           // color: Colors.amber,
  //           decoration: BoxDecoration(
  //             border: Border(right: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
  //           ),
  //           width: MediaQuery.of(context).size.width / 2.2,
  //           child: _crewColumn(crewOne),
  //         ),
  //         Container(
  //           decoration: BoxDecoration(
  //             border: Border(left: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
  //           ),
  //           width: MediaQuery.of(context).size.width / 2.2,
  //           child: _crewColumn(crewTwo),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _crewColumn(Crew crew) {
  //   return ListView(
  //     shrinkWrap: true,
  //     children: [
  //       Container(
  //           decoration: BoxDecoration(
  //             border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
  //           ),
  //           child: _userRow(crew.users!.values.first)),
  //       _userRow(crew.users!.values.elementAt(1))
  //     ],
  //   );
  // }

  // Widget _userRow(Profile user) {
  //   return GestureDetector(
  //     child: Padding(
  //       padding: const EdgeInsets.all(4.0),
  //       child: ListTile(
  //         // children: [
  //         leading: _avatar(user.avatarUrl),
  //         title: Text(
  //           user.name!,
  //           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //         ),
  //         // ],
  //       ),
  //     ),
  //     onTap: () async {
  //       // TODO: implement this
  //       // Profile? userProfile = await getUserById(userId);/
  //       // Navigator.push(
  //       //     context,
  //       //     MaterialPageRoute(
  //       //         settings: const RouteSettings(name: "/firstOfChain"),
  //       //         builder: (_) => ProfileView(
  //       //               userProfile: userProfile,
  //       //               friendsBloc: context.read<FriendsBloc>(),
  //       //             )));
  //     },
  //   );
  // }

  // Widget _avatar(String? imageUrl) {
  //   return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
  //     return Container(
  //       decoration: const BoxDecoration(
  //         shape: BoxShape.circle,
  //         color: Colors.transparent,
  //       ),
  //       width: 50,
  //       height: 50,
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(25),
  //         child: imageUrl != null
  //             ? CachedNetworkImage(
  //                 imageUrl: imageUrl,
  //                 imageBuilder: (context, imageProvider) => Container(
  //                   decoration: BoxDecoration(
  //                     image: DecorationImage(
  //                       image: imageProvider,
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                 ),
  //                 placeholder: (context, url) => const CircularProgressIndicator(),
  //                 errorWidget: (context, url, error) => const Icon(Icons.error),
  //               )
  //             : const Icon(
  //                 Icons.person,
  //                 color: Colors.white,
  //                 size: 50,
  //               ),
  //       ),
  //     );
  //   });
  // }

  Widget _loadMorePostsButton() {
    return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
      return
          // (state.formStatus is FormSubmitting)
          //     ? const CircularProgressIndicator()
          //     :
          ElevatedButton(
        style: ButtonStyle(
          side: MaterialStateProperty.all(const BorderSide(width: 3)),
        ),
        onPressed: () {
          context.read<FeedBloc>().add(LoadOlderPosts());
        },
        child: const Text('Load More Posts'),
      );
    });
  }

  Widget backgroundWidget() {
    return GestureDetector(
      onTap: () {
        // do nothing
        // this is so that anything behind the blur widget is untouchable
      },
      child: SizedBox(
          // color: Colors.orange[300],
          height: double.infinity,
          child: Container()

          // Center(
          //   child: Text(
          //       "This should be blurred, Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32. There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc. There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc. There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc."),
          // ),
          ),
    );
  }

  void onPressed() => context.read<AppViewBloc>().add(UpdateIndexEvent(index: 3));
}
