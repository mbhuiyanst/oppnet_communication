import 'package:flutter/material.dart';
import 'package:oppnet_chat/Global/Colors.dart' as myColors;

//Send Message allignment design......
class SendedMessageWidget extends StatelessWidget {
  final String content;
  final String imageAddress;
  final String time;
  final bool isImage;
  const SendedMessageWidget({
    key,
    required this.content,
    required this.time,
    this.imageAddress="",
    required this.isImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
            right: 8.0, left: 50.0, top: 4.0, bottom: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15)),
          child: Container(
            color: myColors.blue[500],
            // margin: const EdgeInsets.only(left: 10.0),
            child: Stack(children: <Widget>[
              !isImage
                  ? Padding(
                padding: const EdgeInsets.only(
                    right: 12.0, left: 23.0, top: 8.0, bottom: 15.0),
                child: Text(
                  content,
                ),
              )
                  : Padding(
                padding: const EdgeInsets.only(
                    right: 12.0, left: 23.0, top: 8.0, bottom: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: Image.asset(
                        imageAddress,
                        height: 130,
                        width: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      content,
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 1,
                left: 10,
                child: Text(
                  time,
                  style: TextStyle(
                      fontSize: 10, color: Colors.black.withOpacity(0.6)),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
