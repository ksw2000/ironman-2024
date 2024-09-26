import 'package:whisper/data/friend.dart';
import 'package:whisper/data/message.dart';

class Channel {
  Channel(
      {required this.friend,
      required this.channelID,
      required this.lastMessage,
      required this.messageList});
  Friend friend;
  int channelID;
  Message? lastMessage;
  List<Message> messageList;
}
