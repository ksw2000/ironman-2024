class Chat {
  Chat({
    this.profile,
    required this.userName,
    required this.userID,
    required this.messages,
  });
  String? profile;
  String userName;
  int userID;
  List<String> messages = [];
}
