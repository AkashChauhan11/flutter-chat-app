import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/apis/apis.dart';
import 'package:chat_app/helpers/my_date_util.dart';
import 'package:chat_app/models/chat_user_model.dart';
import 'package:chat_app/models/message.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 255, 255, 255)));
  }

  List<Message> messageList = [];
  final _textEditingcontroller = TextEditingController();
  bool show_emoji = false, _isuploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (show_emoji) {
              setState(() {
                show_emoji = false;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false, flexibleSpace: _appbar()),
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APis.getallmsg(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          messageList.clear();
                          messageList = data!
                              .map((e) => Message.fromJson(e.data()))
                              .toList();
                          if (messageList.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              physics: const BouncingScrollPhysics(
                                  decelerationRate:
                                      ScrollDecelerationRate.normal),
                              padding: EdgeInsets.only(top: mq.height * 0.005),
                              itemCount: messageList.length,
                              itemBuilder: (context, index) => MessageCard(
                                message: messageList[index],
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text("Say Hii!"),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isuploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                _chatInput(),
                if (show_emoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController:
                          _textEditingcontroller, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        initCategory: Category.SMILEYS,
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 *
                            (Platform.isIOS
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appbar() {
    return InkWell(
      child: StreamBuilder(
          stream: APis.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.3),
                  child: CachedNetworkImage(
                    width: mq.height * 0.05,
                    height: mq.height * 0.05,
                    imageUrl: widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MydateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MydateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ],
            );
          }),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        show_emoji = !show_emoji;
                      });
                    },
                    icon: const Icon(
                      size: 27,
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        if (show_emoji) {
                          setState(() {
                            show_emoji = !show_emoji;
                          });
                        }
                      },
                      controller: _textEditingcontroller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type Something...",
                          hintStyle: TextStyle(
                              color: Colors.blueAccent, fontSize: 12)),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> image =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in image) {
                        setState(() {
                          _isuploading = true;
                        });
                        await APis.sendChatImage(widget.user, File(i.path));
                        setState(() {
                          _isuploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      size: 27,
                      Icons.image,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        setState(() {
                          _isuploading = true;
                        });
                        await APis.sendChatImage(widget.user, File(image.path));
                        setState(() {
                          _isuploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      size: 27,
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            padding: EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 1),
            minWidth: 0,
            color: Colors.green,
            shape: const CircleBorder(),
            onPressed: () {
              if (_textEditingcontroller.text.isNotEmpty) {
                if (messageList.isEmpty) {
                  APis.sendFirstMessage(
                      widget.user, _textEditingcontroller.text, Type.text);
                }
                APis.sendMessage(
                    widget.user, _textEditingcontroller.text, Type.text);
                _textEditingcontroller.text = '';
              }
            },
            child: const Icon(
              color: Colors.white,
              (Icons.send),
            ),
          )
        ],
      ),
    );
  }
}
