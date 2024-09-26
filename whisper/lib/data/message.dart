class Message {
  Message(
      {required this.senderUID, required this.plaintext, required this.time});
  int senderUID;
  String plaintext;
  DateTime time;
}
