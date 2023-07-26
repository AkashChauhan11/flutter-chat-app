import 'package:chat_app/apis/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user_model.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> users = [];
  final List<ChatUser> _searchList = [];
  bool issearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APis.getselfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APis.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (issearching) {
            setState(() {
              issearching = false;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    issearching = !issearching;
                  });
                },
                icon: Icon(issearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: APis.me),
                      ));
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
            leading: const Icon(CupertinoIcons.home),
            title: issearching
                ? TextField(
                    keyboardType: TextInputType.visiblePassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Name , Email ...",
                    ),
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (value) {
                      _searchList.clear();
                      for (var i in users) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toString().toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toString().toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : const Text(
                    "We Chat",
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _addChatUserDialog();
            },
            child: const Icon(Icons.add_comment_rounded),
          ),
          body: StreamBuilder(
            stream: APis.getMyUsersId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                return StreamBuilder(
                  stream: APis.getalluser(
                      snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      // return const Center(
                      //     child: CircularProgressIndicator());

                      //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        users = data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];
                    }

                    if (users.isNotEmpty) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(
                            decelerationRate: ScrollDecelerationRate.normal),
                        padding: EdgeInsets.only(top: mq.height * 0.005),
                        itemCount:
                            issearching ? _searchList.length : users.length,
                        itemBuilder: (context, index) => ChatUserCard(
                          user: issearching ? _searchList[index] : users[index],
                        ),
                      );
                    } else {
                      //when no chat available here
                      return const Center(
                        child: Text('No Connections Found!',
                            style: TextStyle(fontSize: 20)),
                      );
                    }
                  },
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APis.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showsnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
