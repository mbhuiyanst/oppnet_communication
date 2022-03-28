import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:oppnet_chat/Global/Colors.dart' as MyColors;
import 'package:oppnet_chat/Global/Settings.dart' as Settings;
import 'package:oppnet_chat/Widget/ReceivedMessageWidget.dart';
import 'package:oppnet_chat/Widget/SendedMessageWidget.dart';
import 'package:oppnet_chat/models/message.dart';

class ChatPageView extends StatefulWidget {
  const ChatPageView({
    required this.device,
    required this.nearbyService,
  });

  final Device device;
  final NearbyService nearbyService;
  //final String add = "riad";

  @override
  _ChatPageViewState createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<ChatPageView> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var childList = <Widget>[];

  List<MessageModel> messages = []; //as Stream<List<MessageModel>>;
  final List<MessageModel> _chatMessages = [];

  Stream<List<MessageModel>> _chat() async* {
    yield _chatMessages;
  }

  var r;

  @override
  void initState() {
    super.initState();
    r = widget.nearbyService.dataReceivedSubscription(callback: (data) {
      if (data != null) {
        setState(() {
          _chatMessages.add(MessageModel(
              sent: false,
              toId: "",
              fromId: "",
              message: data['message'].toString(),
              dateTime: DateTime.now()));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 65,
                  child: Container(
                    color:
                        Settings.isDarkMode ? Colors.grey[900] : MyColors.blue,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.device.deviceName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            const Text(
                              "online",
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 0,
                  color: Colors.black54,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: const AssetImage(
                              "assets/images/chat-background-1.jpg"),
                          fit: BoxFit.cover,
                          colorFilter: Settings.isDarkMode
                              ? const ColorFilter.mode(Colors.white,
                                  BlendMode.hardLight) //COLOR white SSSS
                              : const ColorFilter.linearToSrgbGamma()),
                    ),
                    child: SingleChildScrollView(
                        controller: _scrollController,
                        // reverse: true,
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          //mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            //Text("Hello"),
                            //Text("Second value"),
                            StreamBuilder(
                                stream: _chat(),
                                builder: (context,
                                    AsyncSnapshot<List<MessageModel>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),

                                      ///Scroling
                                      shrinkWrap: true,
                                      key: UniqueKey(),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        final chatItem = snapshot.data![index];
                                        return chatItem.sent
                                            ? SendedMessageWidget(
                                                content: chatItem.message,
                                                time: DateFormat(
                                                        'yyyy-MM-dd – kk:mm')
                                                    .format(chatItem.dateTime)
                                                    .toString(),
                                                isImage: false)
                                            : ReceivedMessageWidget(
                                                content: chatItem.message,
                                                time: DateFormat(
                                                        'yyyy-MM-dd – kk:mm')
                                                    .format(chatItem.dateTime)
                                                    .toString(),
                                                isImage: false);
                                      },
                                    );
                                  }
                                  return const LinearProgressIndicator();
                                })
                          ],
                        )),
                  ),
                ),
                const Divider(height: 0, color: Colors.black26),
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      maxLines: 20,
                      controller: _text,
                      decoration: InputDecoration(
                        suffixIcon: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                widget.nearbyService.sendMessage(
                                    widget.device.deviceId, _text.text);
                                setState(() {
                                  _chatMessages.add(MessageModel(
                                      sent: true,
                                      toId: "",
                                      fromId: "",
                                      message: _text.text,
                                      dateTime: DateTime.now()));
                                });

                                _text.clear();
                              },
                            ),
                          ],
                        ),
                        border: InputBorder.none,
                        hintText: "Enter Your Message",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
