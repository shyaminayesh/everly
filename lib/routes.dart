import 'package:flutter/material.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'screens/create_event.dart';
import 'screens/add_vendor.dart';
import 'screens/edit_vendor.dart';
import 'screens/add_guest.dart';
import 'screens/edit_guest.dart';
import 'screens/add_budget.dart';
import 'screens/edit_budget.dart';
import 'screens/help.dart';
import 'screens/about_us.dart';
import 'models/wedding_event.dart';
import 'models/vendor.dart';
import 'models/guest.dart';
import 'models/budget.dart';

class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String createEvent = '/create-event';
  static const String addVendor = '/add-vendor';
  static const String editVendor = '/edit-vendor';
  static const String addGuest = '/add-guest';
  static const String editGuest = '/edit-guest';
  static const String addBudget = '/add-budget';
  static const String editBudget = '/edit-budget';
  static const String help = '/help';
  static const String aboutUs = '/about-us';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(title: 'Everly'),
    // createEvent removed from here to use onGenerateRoute for arguments
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen(title: 'Everly'));
      case createEvent:
        final existingEvent = settings.arguments as WeddingEvent?;
        return MaterialPageRoute(
          builder: (context) => CreateEventScreen(existingEvent: existingEvent),
        );
      case addVendor:
        return MaterialPageRoute(
          builder: (context) => const AddVendorScreen(),
        );
      case editVendor:
        final vendor = settings.arguments as Vendor;
        return MaterialPageRoute(
          builder: (context) => EditVendorScreen(vendor: vendor),
        );
      case addGuest:
        return MaterialPageRoute(
          builder: (context) => const AddGuestScreen(),
        );
      case editGuest:
        final guest = settings.arguments as Guest;
        return MaterialPageRoute(
          builder: (context) => EditGuestScreen(guest: guest),
        );
      case addBudget:
        return MaterialPageRoute(
          builder: (context) => const AddBudgetScreen(),
        );
      case editBudget:
        final budget = settings.arguments as Budget;
        return MaterialPageRoute(
          builder: (context) => EditBudgetScreen(budget: budget),
        );
      case help:
        return MaterialPageRoute(
          builder: (context) => const HelpScreen(),
        );
      case aboutUs:
        return MaterialPageRoute(
          builder: (context) => const AboutUsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}