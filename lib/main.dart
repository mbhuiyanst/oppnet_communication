import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:oppnet_chat/chat_screen.dart';
import 'package:oppnet_chat/route.dart';
import 'models/attached_device.dart';
import 'models/devicelist_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}
//Routing the application pages........
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Showing application home page..............
    return Scaffold(
        appBar: AppBar(
            title: Text("Oppnet Chat Application"),
            backgroundColor: Colors.indigoAccent,
            centerTitle: true

        ),
        body:
        Padding(
            padding: EdgeInsets.only(
                left:  MediaQuery.of(context).size.width * 0.17,
                top: MediaQuery.of(context).size.height * 0.25
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(140),
              child: SizedBox(
                width: 240,
                height: 240,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(primary: Colors.indigoAccent),
                  icon: const Icon(
                    Icons.search_rounded,
                    size: 30,
                  ),
                  label: const Text(
                    'Search Devices',
                    style: TextStyle(fontSize: 25),
                  ),
                  onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DevicesListScreen())); },
                ),
              ),
            )
        )

    );
  }
}