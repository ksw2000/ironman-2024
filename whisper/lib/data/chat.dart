class Chat {
  Chat({
    this.profile = "https://i.imgur.com/1N9WlmT.png",
    required this.userName,
    required this.userID,
    required this.messages,
  });
  String profile;
  String userName;
  int userID;
  List<String> messages = [];
}
