class MessageModel {
  final bool sent;
  final String toId;
  final String fromId;
  final String message;
  final DateTime dateTime;

  MessageModel(
      {required this.sent,
        required this.toId,
        required this.fromId,
        required this.message,
        required this.dateTime});
}
