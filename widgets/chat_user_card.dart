import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/apis/apis.dart';
import 'package:chat_app/helpers/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user_model.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? message;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(user: widget.user),
              ),
            );
          },
          child: StreamBuilder(
            stream: APis.getlastmsg(widget.user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(
                  child: CircularProgressIndicator(),
                ); 
              }
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList();
              if (list!.isNotEmpty) {
                message = list[0];
              }

              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(user: widget.user),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.3),
                    child: CachedNetworkImage(
                      width: mq.height * 0.055,
                      height: mq.height * 0.055,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                    ),
                  ),
                ),
                trailing: message == null
                    ? null
                    : message!.read.isEmpty && message!.fromId != APis.me.id
                        ? Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.greenAccent.shade400),
                          )
                        : Text(
                            MydateUtil.getLastMessageTime(
                                context: context, time: message!.sent),
                            style: const TextStyle(color: Colors.black54),
                          ),
                title: Text(widget.user.name),
                subtitle: Text(
                  message != null
                      ? message!.type == Type.image
                          ? "Image"
                          : message!.msg
                      : widget.user.about,
                  maxLines: 1,
                ),
              );
            },
          )),
    );
  }
}
