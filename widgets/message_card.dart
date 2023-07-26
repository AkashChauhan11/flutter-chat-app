import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/apis/apis.dart';
import 'package:chat_app/helpers/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../helpers/dialogs.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APis.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  Widget _greenMessage() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            const SizedBox(
              width: 2,
            ),
            Text(
              MydateUtil.getformatteddate(
                  context: context, time: widget.message.sent),
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
      Flexible(
        child: Container(
          margin:
              EdgeInsets.only(top: mq.height * 0.007, right: mq.height * 0.015),
          padding: EdgeInsets.all(widget.message.type == Type.image
              ? mq.width * 0.02
              : mq.width * 0.03),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 255, 176),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(color: Colors.greenAccent)),
          child: widget.message.type == Type.image
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.015),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: CircularProgressIndicator(),
                    ),

                    imageUrl: widget.message.msg,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image),
                  ),
                )
              : Text(
                  widget.message.msg,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
        ),
      ),
    ]);
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APis.updateMessageReadStatus(widget.message);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(
        child: Container(
          margin:
              EdgeInsets.only(top: mq.height * 0.007, left: mq.height * 0.015),
          padding: EdgeInsets.all(widget.message.type == Type.image
              ? mq.width * 0.02
              : mq.width * 0.03),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 199, 231, 255),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(color: Colors.blueAccent)),
          child: widget.message.type == Type.image
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .015),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: CircularProgressIndicator(),
                    ),

                    imageUrl: widget.message.msg,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image),
                  ),
                )
              : Text(
                  widget.message.msg,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(right: mq.width * 0.04),
        child: Text(
          MydateUtil.getformatteddate(
              context: context, time: widget.message.sent),
          style: const TextStyle(color: Colors.black54),
        ),
      )
    ]);
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.type == Type.text
                  ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);

                          Dialogs.showsnackbar(context, 'Text Copied!');
                        });
                      })
                  :
                  //save option
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          log('Image Url: ${widget.message.msg}');
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'We Chat')
                              .then((success) {
                            //for hiding bottom sheet
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showsnackbar(
                                  context, 'Image Successfully Saved!');
                            }
                          });
                        } catch (e) {
                          log('ErrorWhileSavingImg: $e');
                        }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);

                      // _showMessageUpdateDialog();
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await APis.deleteMessage(widget.message).then((value) {
                        //for hiding bottom sheet
                        Navigator.pop(context);
                      });
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      'Sent At: ${MydateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MydateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
