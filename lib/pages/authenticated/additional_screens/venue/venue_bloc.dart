import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_state.dart';

class VenueBloc extends Bloc<VenueEvent, VenueState> {
  final LikesRepository likesRepo;
  final VenueRepository venueRepo;

  VenueBloc({
    required Profile currentUser,
    required Venue venue,
    required this.likesRepo,
    required this.venueRepo,
  }) : super(VenueState(currentUser: currentUser, venue: venue)) {
    on<InitVenueEvent>(_mapInitVenueEvent);
  }

  _mapInitVenueEvent(InitVenueEvent event, Emitter<VenueState> emit) async {
    Map<dynamic, Match>? tonightsMatches = await venueRepo.getTonightsMatchesAtVenue(state.venue.id!);
    print(tonightsMatches != null);
    emit(state.copyWith(tonightsMatches: tonightsMatches, loadingState: const Loaded()));
  }
}
