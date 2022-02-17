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
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DevicesListScreen(deviceType: DeviceType.browser)));
              },
              child: Container(
                color: Colors.red,
                child: const Center(
                    child: Text(
                      'Browsing',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DevicesListScreen(deviceType: DeviceType.advertiser)));
              },
              child: Container(
                color: Colors.green,
                child: const Center(
                    child: Text(
                      'Advertising',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

