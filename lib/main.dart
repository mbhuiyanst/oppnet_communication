import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:oppnet_chat/chat_screen.dart';
import 'models/attached_device.dart';
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
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const Home());
    case 'browser':
      return MaterialPageRoute(
          builder: (_) => const DevicesListScreen(deviceType: DeviceType.browser));
    case 'advertiser':
      return MaterialPageRoute(
          builder: (_) => const DevicesListScreen(deviceType: DeviceType.advertiser));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text('No route defined for ${settings.name}')),
          )
      );
  }
}


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
                //Navigator.pushNamed(context, 'advertiser');
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
// Advertising and Scanning , connection request and message send/receive implementation.....

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {

  const DevicesListScreen({required this.deviceType,Key ? key}): super(key: key);

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {

  List<Device> devices = []; // Store and show list of available advertised devices....
  List<Device> connectedDevices = []; // Store and show List of Connected devices......
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  String _currentDevice='';

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
    //_getCurrentDevice();
  }

  /*_getCurrentDevice()async{
    if(Platform.isAndroid){
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _currentDevice=androidInfo.model;
    }

  }*/

  @override
  void dispose() {
    subscription.cancel();
    receivedDataSubscription.cancel();
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
              final device = widget.deviceType == DeviceType.advertiser
                  ? connectedDevices[index]
                  :  devices[index];

              return Container(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                              onTap: () => _onTabItemListener2(device,nearbyService),
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
                            )),


                        GestureDetector(
                          onTap: () => _onButtonClicked(device),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: const EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(device.state),
                            child: Center(
                              child: Text(
                                getButtonStateName(device.state),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
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
    // Send/received messages among the connected devices......
  _onTabItemListener2(Device device, NearbyService nearbyService){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPageView( device: device,nearbyService:nearbyService)));
  }

  _onTabItemListener(Device device) {
    if (device.state == SessionState.connected) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            final myController = TextEditingController();
            return AlertDialog(
              title: const Text("Write  message"),
              content: TextField(controller: myController),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Send"),
                  onPressed: () {
                    nearbyService.sendMessage(
                        device.deviceId, myController.text +device.deviceName);
                    myController.text = '';
                  },
                )
              ],
            );
          });
    }
  }

  int getItemCount() {
    if (widget.deviceType == DeviceType.advertiser) {
      return connectedDevices.length;
    } else {
      return devices.length;
    }
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

    await nearbyService.init(
        serviceType: 'mpconn',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER, // defining cluster_shaped connection topology.....
        callback: (isRunning) async {

          if (isRunning) {
            if (widget.deviceType == DeviceType.browser) {
              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(const Duration(microseconds: 200));
              await nearbyService.startBrowsingForPeers();
            } else {
              await nearbyService.stopAdvertisingPeer();
              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(const Duration(microseconds: 200));
              await nearbyService.startAdvertisingPeer();
              await nearbyService.startBrowsingForPeers();
            }
          }
        });
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

    /*devices.forEach((element) {
       print('list of available device ${element.deviceName}');
    });
    connectedDevices.forEach((element) {
      print('list of connected device ${element.deviceName}');
    });*/
    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) {
          print("dataReceivedSubscription: ${jsonEncode(data)}");
          showToast(jsonEncode(data),
              context: context,
              axis: Axis.horizontal,
              alignment: Alignment.center,
              position: StyledToastPosition.bottom);
        });
  }
}