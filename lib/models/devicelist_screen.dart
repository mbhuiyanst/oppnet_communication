
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:oppnet_chat/chat_screen.dart';

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {

  const DevicesListScreen({Key ? key}): super(key: key);

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {

  List<Device> devices = []; // Store and show list of available advertised devices....
  List<Device> connectedDevices = []; // Store and show List of Connected devices......
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  String _currentDevice='';

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
    //_getCurrentDevice();
  }

  @override
  void dispose() {
    subscription.cancel();
    nearbyService.stopBrowsingForPeers(); // Stop scanning for peers......
    nearbyService.stopAdvertisingPeer();   //Stop advertising for peers.....
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Oppnet Chat Application"),
            backgroundColor: Colors.indigoAccent,
            centerTitle: true
        ),
        backgroundColor: Colors.white,
        body: ListView.builder(
            itemCount: getItemCount(),
            itemBuilder: (context, index) {
              final device = devices[index];
              return Container(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          // Tab on connected device
                            child: GestureDetector(
                              onTap: () => _onTabItemListener2(device,nearbyService), // open chat screen
                              child: Column(
                                children: [
                                  Text(device.deviceName),
                                  Text(
                                    getStateName(device.state),
                                    style: TextStyle(
                                        color: getStateColor(device.state)),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            )
                        ),
                        //Tap on connect button
                        SizedBox(
                            height: 45,
                            width: 110,
                            child: TextButton(
                                onPressed: (){
                                  _onButtonClicked(device);
                                },
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                                    foregroundColor: MaterialStateProperty.all<Color>(getButtonColor(device.state)),
                                    backgroundColor: MaterialStateProperty.all<Color>(getButtonColor(device.state)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            side: BorderSide(color: getButtonColor(device.state))
                                        )
                                    )
                                ),
                                child: Center(
                                  child: Text(
                                    getButtonStateName(device.state),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                            )
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.grey,
                    )
                  ],
                ),
              );
            }));
  }

  // get current state name
  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }
  //Open chat Screen Method
  _onTabItemListener2(Device device, NearbyService nearbyService){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPageView( device: device,nearbyService:nearbyService)));
  }

  int getItemCount() {
    return devices.length;
  }
// Request connect from scanning devices.....
  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: _currentDevice,
        );
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }
  // ios and android device identification with required  information
  void init() async {
    nearbyService = NearbyService();
    String devInfo = '';
    // ios and android device identification with required  information
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.model;
      _currentDevice=devInfo;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel;
      _currentDevice=devInfo;
    }

    //Initialize nearby Sevice package
    await nearbyService.init(
        serviceType: 'mpconn',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER, // defining cluster_shaped connection topology.....
        callback: (isRunning) async {
          ////////////////browsing and advertising implement
          if(isRunning){
            await nearbyService.stopAdvertisingPeer();
            await nearbyService.stopBrowsingForPeers();
            await Future.delayed(const Duration(microseconds: 200));
            nearbyService.startAdvertisingPeer();
            nearbyService.startBrowsingForPeers();
          }
        });

    ///Subscription for device connectionstate
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
          for (var element in devicesList) {
            print(" deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}") ;
            if (Platform.isAndroid) {
              if (element.state == SessionState.connected) {
                nearbyService.stopBrowsingForPeers();
              } else {
                nearbyService.startBrowsingForPeers();
              }
            }
          }
          setState(() {
            devices.clear();
            devices.addAll(devicesList);
            connectedDevices.clear();
            List<Device> attached=devicesList.where((d) => d.state == SessionState.connected).toList();
            attached.forEach((element) {
              print(element.deviceName);
            });
            connectedDevices.addAll(devicesList.where((d) => d.state == SessionState.connected).toList());
          });//,_currentDevice
        });
  }
}