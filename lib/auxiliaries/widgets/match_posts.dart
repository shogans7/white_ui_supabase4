import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/avatar.dart';

Widget matchPosts(Map<dynamic, Match> previousMatches, double width, {Function? onProfileTap, Function? onVenueTap}) {
  return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: previousMatches.length,
      itemBuilder: (BuildContext context, int index) {
        final match = previousMatches.values.elementAt(index);
        return Card(
          child: Column(
            children: [
              if (match.venue != null && match.venue!.venueUrl != null) _venueImage(match.venue!, width, onVenueTap: onVenueTap),
              _groupsRow(match.crewOne!, match.crewTwo!, width, onProfileTap),
              _detailsRow(match.createdAt!, 23),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: const EdgeInsets.all(10),
        );
      });
  // } else {
  //   return emptyScreen(context, "Your feed is empty!", onPressed, "Add some more friends to see what's happening");
  //   // return SizedBox(
  //   //   width: MediaQuery.of(context).size.width,
  //   //   height: MediaQuery.of(context).size.width * (5 / 3),
  //   //   child: Center(
  //   //     child: Stack(
  //   //       children: const [
  //   //         Text("This is your feed"),
  //   //       ],
  //   //     ),
  //   //   ),
  //   // );
  // }
}

Widget _venueImage(Venue venue, double width, {Function? onVenueTap}) {
  return SizedBox(
    height: width / 3,
    width: width,
    // height: MediaQuery.of(context).size.width / 3, // + appBarHeight,
    // width: MediaQuery.of(context).size.width,
    child: GestureDetector(
      child: CachedNetworkImage(
        imageUrl: venue.venueUrl!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.topCenter,
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 4,
                blurRadius: 4,
                offset: const Offset(3, 3),
              )
            ],
          ),
        ),
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      onTap: () {
        if (onVenueTap != null) onVenueTap(venue);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         settings: const RouteSettings(name: "/firstOfChain"),
        //         builder: (_) => BlocProvider(
        //               create: (__) => VenueBloc(
        //                 venue: venue,
        //                 likesRepo: context.read<LikesRepository>(),
        //                 venuesRepo: context.read<VenuesRepository>(),
        //               )..add(InitVenueEvent()),
        //               child: VenueScreen(
        //                 // venue: match.venue,
        //                 feedBloc: context.read<FeedBloc>(),
        //               ),
        //             )));
      },
    ),
  );
}

Widget _groupsRow(Crew crewOne, Crew crewTwo, double width, Function? onProfileTap) {
  return Padding(
    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
    child: Row(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          // color: Colors.amber,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
          ),
          width: width / 2.2,
          child: _crewColumn(crewOne, onProfileTap),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
          ),
          width: width / 2.2,
          child: _crewColumn(crewTwo, onProfileTap),
        ),
      ],
    ),
  );
}

Widget _crewColumn(Crew crew, Function? onProfileTap) {
  return ListView(
    shrinkWrap: true,
    children: [
      Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
        ),
        child: _userRow(crew.users!.values.elementAt(0), onProfileTap),
      ),
      _userRow(crew.users!.values.elementAt(1), onProfileTap)
    ],
  );
}

Widget _userRow(Profile? user, Function? onProfileTap) {
  return GestureDetector(
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        // children: [
        leading: avatar(user?.avatarUrl ?? ""),
        title: Text(
          user?.name ?? "",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        // ],
      ),
    ),
    onTap: () {
      if (onProfileTap != null) onProfileTap(user);
    },
  );
}

Widget _detailsRow(String date, int likes) {
  String dateString = dateToReadableTimeAgoString(date);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(dateString),
        Container(),
        // ClipRRect(
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [const Icon(Icons.favorite, color: Colors.red), const SizedBox(width: 10), Text(likes.toString())],
        //   ),
        // ),
      ],
    ),
  );
}
