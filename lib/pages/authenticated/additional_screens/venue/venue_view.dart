import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/match_posts.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/padded_title.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';

class VenueView extends StatefulWidget {
  final FriendsBloc friendsBloc;
  const VenueView({Key? key, required this.friendsBloc}) : super(key: key);

  @override
  State<VenueView> createState() => _VenueViewState();
}

class _VenueViewState extends State<VenueView> {
  @override
  Widget build(BuildContext context) {
    // final venue = widget.venue;
    return BlocProvider.value(
        value: context.read<VenueBloc>(),
        child: BlocBuilder<VenueBloc, VenueState>(builder: (context, state) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(capitalise(state.venue.name)!),
                // actions: [
                //   IconButton(
                //       icon: const Icon(Icons.clear),
                //       onPressed: () async {
                //         await Future.delayed(const Duration(milliseconds: 800));
                //         Navigator.of(context).popUntil(ModalRoute.withName("/firstOfChain"));
                //         Navigator.pop(context);
                //       }),
                // ],
              ),
              body: RefreshIndicator(
                  onRefresh: () async {
                    // context.read<FeedBloc>().add(VenueReloadEvent(venue));
                  },
                  child: GestureDetector(onTap: () => FocusScope.of(context).requestFocus(FocusNode()), child: _venuePage(state.venue))));
        }));
  }

  Widget _venuePage(Venue venue) {
    return BlocBuilder<VenueBloc, VenueState>(builder: (context, state) {
      var matches = state.tonightsMatches;
      final width = MediaQuery.of(context).size.width;
      final FriendsBloc friendsBloc = widget.friendsBloc;
      final AppViewBloc appViewBloc = friendsBloc.appViewBloc;

      void onVenueTap(Venue venue) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BlocProvider(
                    create: (context) => VenueBloc(
                          currentUser: state.currentUser,
                          venue: venue,
                          likesRepo: context.read<LikesRepository>(),
                          venueRepo: context.read<VenueRepository>(),
                        )..add(InitVenueEvent()),
                    child: VenueView(friendsBloc: friendsBloc))));
      }

      void onProfileTap(Profile userProfile) async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BlocProvider(
                    create: (context) => ProfileViewBloc(
                          appViewBloc: appViewBloc,
                          likesRepo: context.read<LikesRepository>(),
                          currentUser: state.currentUser,
                          userProfile: userProfile,
                        )..add(InitViewProfileEvent()),
                    child: ProfileView(
                      friendsBloc: friendsBloc,
                    ))));
      }

      return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              _venuePicture(venue.venueUrl),
              if (venue.city != null) _addressTile(venue.city!),
              if (matches != null && matches.isNotEmpty) paddedUnderlinedTitle("Tonight", width * 0.8),
              if (matches != null && matches.isNotEmpty) matchPosts(matches, width, onVenueTap: onVenueTap, onProfileTap: onProfileTap),
              // if (state.users != null) _usersGoingWidget(),
            ],
          ),
        ),
      );
    });
  }

  Widget _venuePicture(String? imageUrl) {
    // return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
    return Container(
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.transparent,
          border: Border(
              bottom: BorderSide(
            width: 2,
            color: Colors.black,
          )),
          boxShadow: [BoxShadow(offset: Offset.zero, blurRadius: 0.0, spreadRadius: 0.0)],
        ),
        width: double.infinity,
        height: 300,
        child: ClipRRect(
          child: imageUrl != null
              ? CachedNetworkImage(
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
                  errorWidget: (context, url, error) => IconButton(
                    onPressed: () {
                      // context.read<ProfileBloc>().add(ChangeAvatarRequest());
                    },
                    icon: const Icon(
                      Icons.photo_camera,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    // context.read<ProfileBloc>().add(ChangeAvatarRequest());
                  },
                  icon: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
          //     Image.network(
          //   state.getImageURL,
          //   errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          //     return IconButton(
          //       onPressed: () {
          //         context.read<ProfileBloc>().add(ChangeAvatarRequest());
          //       },
          //       icon: const Icon(
          //         Icons.photo_camera,
          //         color: Colors.white,
          //         size: 50,
          //       ),
          //     );
          //   },
          // ),
        ));
    // });
  }

  Widget _addressTile(String address) {
    // return BlocBuilder<VenueBloc, VenueState>(builder: (context, state) {
    return ListTile(
        tileColor: Colors.white,
        leading: const Icon(Icons.location_on),
        title: GestureDetector(
          child: Text(address),
          onTap: () {
            // MapsLauncher.launchQuery(address);
          },
        ));
    // });
  }

//   Widget _usersGoingWidget() {
//     return BlocBuilder<VenueBloc, VenueState>(builder: (context, state) {
//       var users = state.users!;
//       if (users.isNotEmpty) {
//         return ListTile(
//           leading: const Icon(Icons.people),
//           title: Padding(
//             padding: const EdgeInsets.all(2.0),
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
//                       right: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
//                       left: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
//                       bottom: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(5),
//                       topRight: Radius.circular(5),
//                       bottomLeft: Radius.circular(1),
//                       bottomRight: Radius.circular(1),
//                     ),
//                   ),
//                   child: const ListTile(
//                     title: Text(
//                       "4 friends and 26 other people going",
//                     ),
//                   ),
//                   // )
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
//                     // borderRadius: BorderRadius.circular(5),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(5),
//                       bottomRight: Radius.circular(5),
//                     ),
//                   ),
//                   // height: 150,
//                   constraints: const BoxConstraints(maxHeight: 150),
//                   child: ShaderMask(
//                     shaderCallback: (Rect rect) {
//                       return const LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
//                         stops: [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
//                       ).createShader(rect);
//                     },
//                     blendMode: BlendMode.dstOut,
//                     child: ListView.builder(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         primary: false,
//                         shrinkWrap: true,
//                         itemCount: users.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           Profile? userProfile = users[index];
//                           return Container(
//                             decoration: BoxDecoration(
//                               border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
//                             ),
//                             child: ListTile(
//                               onTap: () async {
//                                 Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileView(userProfile: userProfile, friendsBloc: context.read<FriendsBloc>())));
//                               },
//                               trailing: _avatar(userProfile!.avatarUrl),
//                               title: Text(
//                                 userProfile.name ?? "",
//                                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             // )
//                           );
//                           // subtitle: orderFriendsForTile(state.potentialFriends![index]!.friends),
//                         }),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // ),
//         );
//       } else {
//         return Container();
//       }
//     });
//   }

//   Widget _avatar(String? imageUrl) {
//     return BlocBuilder<VenueBloc, VenueState>(builder: (context, state) {
//       return Container(
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.transparent,
//         ),
//         width: 50,
//         height: 50,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(25),
//           child: imageUrl != null
//               ? CachedNetworkImage(
//                   imageUrl: imageUrl,
//                   imageBuilder: (context, imageProvider) => Container(
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: imageProvider,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   placeholder: (context, url) => const CircularProgressIndicator(),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                 )
//               : const Icon(
//                   Icons.person,
//                   color: Colors.white,
//                   size: 50,
//                 ),
//         ),
//       );
//     });
//   }
// }
}
