import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
          // width: mq.width * .80,
          height: mq.height * .35,
          child: Stack(
            children: [
              //user profile picture
              Positioned(
                // top: mq.height * .075,
                // left: mq.width * .1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .25),
                      child: CachedNetworkImage(
                        width: mq.width * .49,
                        height: mq.height * .23,
                        fit: BoxFit.cover,
                        imageUrl: user.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                  ),
                ),
              ),

              //user name
              Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: SizedBox(width: mq.width,
                  child: Text(user.name,textAlign: TextAlign.center,
                      style: const TextStyle(
                        
                          fontSize: 18, fontWeight: FontWeight.w500,)),
                ),
              ),

              //info button
            ],
          )),
    );
  }
}
