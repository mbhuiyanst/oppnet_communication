import 'package:oppnet_chat/models/message.dart';

/// Here a controller class is defined , "MessageController" is required for controlling send/recive text and showing them on the chat page for real time communication
class MessageController{
  List<MessageModel> messages = [];
  final List<MessageModel> _chatMessages = [];
}
