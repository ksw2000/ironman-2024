class Chat {
  Chat({
    this.profile,
    required this.userName,
    required this.userID,
    required this.lastMessage,
    required this.channelID,
  });
  String? profile;
  String userName;
  int userID;
  int channelID;
  String? lastMessage;
}
