import 'package:flutter/material.dart';
import 'package:flutter_library_app/routing/app_routes.dart';
import 'package:flutter_library_app/ui/account/widgets/account_screen.dart';
import 'package:flutter_library_app/ui/add_book/widgets/add_book_screen.dart';
import 'package:flutter_library_app/ui/calendar/widgets/calendar_screen.dart';
import 'package:flutter_library_app/ui/currently_reading/widgets/currently_reading_screen.dart';
import 'package:flutter_library_app/ui/home/widgets/home_screen.dart';
import 'package:flutter_library_app/ui/library/widgets/library_screen.dart';
import 'package:flutter_library_app/ui/objective/widgets/objective_screen.dart';
import 'package:flutter_library_app/ui/statistics/widgets/statistics_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.addBook:
        return MaterialPageRoute(builder: (_) => const AddBookScreen());
      case AppRoutes.account:
        return MaterialPageRoute(builder: (_) => const AccountScreen());
      case AppRoutes.calendar:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case AppRoutes.currentlyReading:
        return MaterialPageRoute(builder: (_) => const CurrentlyReadingScreen());
      case AppRoutes.library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case AppRoutes.objective:
        return MaterialPageRoute(builder: (_) => const ObjectiveScreen());
      case AppRoutes.statistics:
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))));
    }
  }
}
