
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:oppnet_chat/chat_screen.dart';
import 'package:oppnet_chat/models/devicelist_screen.dart';

/// Application Page routing
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const Home());
    case 'browser':
      return MaterialPageRoute(
          builder: (_) => const DevicesListScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text('No route defined for ${settings.name}')),
          )
      );
  }
}