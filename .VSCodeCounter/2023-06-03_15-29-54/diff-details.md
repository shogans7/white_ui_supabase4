# Diff Details

Date : 2023-06-03 15:29:54

Directory /Users/shanehogan/development/white_ui_supabase4

Total : 46 files,  1187 codes, 309 comments, 102 blanks, all 1598 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/auxiliaries/helpers/formatters/date_textfield_formatter.dart](/lib/auxiliaries/helpers/formatters/date_textfield_formatter.dart) | Dart | 0 | 1 | 0 | 1 |
| [lib/auxiliaries/helpers/local_functions.dart](/lib/auxiliaries/helpers/local_functions.dart) | Dart | 145 | 6 | 15 | 166 |
| [lib/auxiliaries/models/crew.dart](/lib/auxiliaries/models/crew.dart) | Dart | 0 | -1 | 1 | 0 |
| [lib/auxiliaries/models/crew_request.dart](/lib/auxiliaries/models/crew_request.dart) | Dart | 16 | 19 | 1 | 36 |
| [lib/auxiliaries/models/match.dart](/lib/auxiliaries/models/match.dart) | Dart | -6 | 1 | 1 | -4 |
| [lib/auxiliaries/models/profile.dart](/lib/auxiliaries/models/profile.dart) | Dart | 33 | 1 | 0 | 34 |
| [lib/auxiliaries/repos/auth_repository.dart](/lib/auxiliaries/repos/auth_repository.dart) | Dart | 58 | 1 | 0 | 59 |
| [lib/auxiliaries/repos/crew_repository.dart](/lib/auxiliaries/repos/crew_repository.dart) | Dart | 29 | 3 | 4 | 36 |
| [lib/auxiliaries/repos/droptime_repository.dart](/lib/auxiliaries/repos/droptime_repository.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/auxiliaries/repos/likes_repository.dart](/lib/auxiliaries/repos/likes_repository.dart) | Dart | 4 | 0 | 1 | 5 |
| [lib/auxiliaries/repos/misc_functions_repository.dart](/lib/auxiliaries/repos/misc_functions_repository.dart) | Dart | 21 | 2 | 0 | 23 |
| [lib/auxiliaries/widgets/button_dialog.dart](/lib/auxiliaries/widgets/button_dialog.dart) | Dart | 8 | 0 | 0 | 8 |
| [lib/auxiliaries/widgets/group_card.dart](/lib/auxiliaries/widgets/group_card.dart) | Dart | 7 | -10 | -1 | -4 |
| [lib/auxiliaries/widgets/match_history_widget.dart](/lib/auxiliaries/widgets/match_history_widget.dart) | Dart | 0 | -10 | 0 | -10 |
| [lib/auxiliaries/widgets/user_card.dart](/lib/auxiliaries/widgets/user_card.dart) | Dart | -1 | 0 | 0 | -1 |
| [lib/auxiliaries/widgets/user_image_small_empty_button.dart](/lib/auxiliaries/widgets/user_image_small_empty_button.dart) | Dart | 27 | 6 | 4 | 37 |
| [lib/auxiliaries/widgets/view_user.dart](/lib/auxiliaries/widgets/view_user.dart) | Dart | 24 | 0 | 1 | 25 |
| [lib/pages/authenticated/app_view/app_view.dart](/lib/pages/authenticated/app_view/app_view.dart) | Dart | 10 | -20 | -1 | -11 |
| [lib/pages/authenticated/app_view/app_view_bloc.dart](/lib/pages/authenticated/app_view/app_view_bloc.dart) | Dart | -2 | -12 | -2 | -16 |
| [lib/pages/authenticated/app_view/app_view_event.dart](/lib/pages/authenticated/app_view/app_view_event.dart) | Dart | -6 | 5 | 0 | -1 |
| [lib/pages/authenticated/feed/venue_screen.dart](/lib/pages/authenticated/feed/venue_screen.dart) | Dart | 98 | 171 | 10 | 279 |
| [lib/pages/authenticated/friends/friend_list_screen.dart](/lib/pages/authenticated/friends/friend_list_screen.dart) | Dart | -1 | 1 | 0 | 0 |
| [lib/pages/authenticated/friends/friend_request_screen.dart](/lib/pages/authenticated/friends/friend_request_screen.dart) | Dart | -1 | 0 | 0 | -1 |
| [lib/pages/authenticated/friends/friends_bloc.dart](/lib/pages/authenticated/friends/friends_bloc.dart) | Dart | -2 | 1 | 0 | -1 |
| [lib/pages/authenticated/likes/basic_likes_view.dart](/lib/pages/authenticated/likes/basic_likes_view.dart) | Dart | -27 | -3 | -3 | -33 |
| [lib/pages/authenticated/likes/likes_bloc.dart](/lib/pages/authenticated/likes/likes_bloc.dart) | Dart | 59 | 19 | 11 | 89 |
| [lib/pages/authenticated/likes/likes_event.dart](/lib/pages/authenticated/likes/likes_event.dart) | Dart | 15 | 9 | 15 | 39 |
| [lib/pages/authenticated/likes/likes_state.dart](/lib/pages/authenticated/likes/likes_state.dart) | Dart | 29 | 5 | 4 | 38 |
| [lib/pages/authenticated/likes/likes_view.dart](/lib/pages/authenticated/likes/likes_view.dart) | Dart | 359 | 58 | 19 | 436 |
| [lib/pages/authenticated/meet/crew/add_third_screen.dart](/lib/pages/authenticated/meet/crew/add_third_screen.dart) | Dart | 61 | 3 | 5 | 69 |
| [lib/pages/authenticated/meet/crew/crew_request_bloc.dart](/lib/pages/authenticated/meet/crew/crew_request_bloc.dart) | Dart | 19 | 0 | 1 | 20 |
| [lib/pages/authenticated/meet/crew/crew_request_event.dart](/lib/pages/authenticated/meet/crew/crew_request_event.dart) | Dart | 4 | 1 | 2 | 7 |
| [lib/pages/authenticated/meet/crew/crew_request_screen.dart](/lib/pages/authenticated/meet/crew/crew_request_screen.dart) | Dart | 131 | 24 | 3 | 158 |
| [lib/pages/authenticated/meet/match_list_screen.dart](/lib/pages/authenticated/meet/match_list_screen.dart) | Dart | 25 | -1 | 3 | 27 |
| [lib/pages/authenticated/meet/meet_bloc.dart](/lib/pages/authenticated/meet/meet_bloc.dart) | Dart | -2 | 14 | -1 | 11 |
| [lib/pages/authenticated/meet/meet_event.dart](/lib/pages/authenticated/meet/meet_event.dart) | Dart | -2 | 0 | 0 | -2 |
| [lib/pages/authenticated/meet/meet_view.dart](/lib/pages/authenticated/meet/meet_view.dart) | Dart | 63 | 4 | 5 | 72 |
| [lib/pages/authenticated/profile/edit_profile/edit_profile_bloc.dart](/lib/pages/authenticated/profile/edit_profile/edit_profile_bloc.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/pages/authenticated/profile/view_profile/profile_view.dart](/lib/pages/authenticated/profile/view_profile/profile_view.dart) | Dart | 7 | 2 | 1 | 10 |
| [lib/pages/authenticated/profile/view_profile/profile_view_bloc.dart](/lib/pages/authenticated/profile/view_profile/profile_view_bloc.dart) | Dart | -12 | 7 | 1 | -4 |
| [lib/pages/authenticated/profile/view_profile/profile_view_event.dart](/lib/pages/authenticated/profile/view_profile/profile_view_event.dart) | Dart | -1 | 0 | 0 | -1 |
| [lib/pages/authenticated/profile/view_profile/profile_view_state.dart](/lib/pages/authenticated/profile/view_profile/profile_view_state.dart) | Dart | -2 | 0 | 0 | -2 |
| [lib/pages/onboarding/screens/contacts_screen.dart](/lib/pages/onboarding/screens/contacts_screen.dart) | Dart | 0 | -2 | 1 | -1 |
| [lib/pages/onboarding/screens/profile_photo_screen.dart](/lib/pages/onboarding/screens/profile_photo_screen.dart) | Dart | 0 | 1 | 1 | 2 |
| [lib/pages/unauthenticated/auth/dob/dob_state.dart](/lib/pages/unauthenticated/auth/dob/dob_state.dart) | Dart | 0 | 1 | 0 | 1 |
| [lib/pages/unauthenticated/auth/phone/phone_confirmation_screen.dart](/lib/pages/unauthenticated/auth/phone/phone_confirmation_screen.dart) | Dart | -2 | 2 | 0 | 0 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details