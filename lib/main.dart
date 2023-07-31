import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/pages/unauthenticated/auth/auth_cubit.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/palette.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/auth_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/droptime_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/friends_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/session_navigation/session_cubit.dart';
import 'package:white_ui_supabase4/session_navigation/session_navigator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Supabase.initialize(
    url: 'https://lihuydxngmioixulujmp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxpaHV5ZHhuZ21pb2l4dWx1am1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzQzNjg2MTAsImV4cCI6MTk4OTk0NDYxMH0.Pcg8XJEH7FIcz0-CysytbN5K6VX311EaKPGK8l1aIa0',
  );
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool('isFirstOpen', true);
  var contactsPermission = await Hive.openBox('contacts_permission');
  bool? permission = contactsPermission.get('permission');
  if (permission != null && permission) {
    debugPrint(" -- Found permission to access contacts for this device -- ");
    final contacts = await FlutterContacts.getContacts();
    Map<dynamic, dynamic> contactsMap = await convertContactsToMap(contacts);
    var contactBox = await Hive.openBox('contacts');
    await contactBox.putAll(contactsMap);
  }
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("d721be26-cb61-47a0-b398-724b0eef1568");

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  runApp(MyApp(
    preferences: preferences,
  ));
}

class MyApp extends StatefulWidget {
  final SharedPreferences preferences;
  const MyApp({Key? key, required this.preferences}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SharedPreferences preferences = widget.preferences;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => StorageRepository()),
        RepositoryProvider(create: (context) => FriendsRepository()),
        RepositoryProvider(create: (context) => CrewRepository()),
        RepositoryProvider(create: (context) => LikesRepository()),
        RepositoryProvider(create: (context) => DroptimeRepository()),
        RepositoryProvider(create: (context) => VenueRepository())
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => SessionCubit(
            authRepo: context.read<AuthRepository>(),
            storageRepo: context.read<StorageRepository>(),
            friendsRepo: context.read<FriendsRepository>(),
            crewRepo: context.read<CrewRepository>(),
            likesRepo: context.read<LikesRepository>(),
            dropRepo: context.read<DroptimeRepository>(),
            venueRepo: context.read<VenueRepository>(),
          ),
        ),
        BlocProvider(create: (context) => AuthCubit(sessionCubit: context.read<SessionCubit>(), preferences: preferences)),
      ], child: MaterialApp(theme: ThemeData(primarySwatch: Palette.kToDark, fontFamily: 'Urbanist'), debugShowCheckedModeBanner: false, home: const SessionNavigator())),
    );
  }
}
