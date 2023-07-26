import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/models/chat_user_model.dart';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;
  static User get user => auth.currentUser!;

  //storing self information
  static ChatUser me = ChatUser(
      image: user.photoURL!,
      about: "Hey I am using this",
      name: user.displayName!,
      createdAt: "",
      lastActive: "",
      id: user.uid,
      isOnline: true,
      email: user.email!,
      pushToken: "");

  //getting firebase messaging token
  static Future<void> getFirebaseMessaging() async {
    await fmessaging.requestPermission();
    await fmessaging.getToken().then((token) => {
          if (token != null) {me.pushToken = token}
        });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAuXCGXkg:APA91bE8C1RLsmI5n1d-TDM1__awU9hvvvVhqRZy6PaNUKHqurskPcH2fzCIKsCo3ltYvkRvWbFaoevJvYyYDETNNg3wCl1lX52UM_QoWeEP6IEmKhW5o-jnj0Ps7QDHvkrae1igFZTV'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  //checking if a user already exists:-
  static Future<bool> userexists() async {
    return (await firestore.collection('Users').doc(user.uid).get()).exists;
  }

  //for getting current user information
  static Future<void> getselfInfo() async {
    await firestore.collection('Users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        getFirebaseMessaging();
        await APis.updateActiveStatus(true);
      } else {
        (createuser().then((value) => getselfInfo()));
      }
    });
  }

  // creating a user if user not exists
  static Future<void> createuser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey i am using this chat app",
        name: user.displayName.toString(),
        createdAt: time,
        lastActive: time,
        id: user.uid,
        isOnline: true,
        email: user.email.toString(),
        pushToken: '');

    return await firestore
        .collection('Users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  //getting all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getalluser(
      List<String> userIds) {
    return firestore
        .collection('Users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUser() async {
    await firestore
        .collection('Users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');
    await ref.putFile(file);
    me.image = await ref.getDownloadURL();

    await firestore
        .collection('Users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //getting conversation id
  static String getconversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // getting all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getallmsg(ChatUser user) {
    return firestore
        .collection('chats/${getconversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: type,
        sent: time,
        fromId: user.uid);
    final ref = firestore
        .collection('chats/${getconversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then(
          (value) =>
              sendPushNotification(chatUser, type == Type.text ? msg : 'image'),
        );
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getconversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getlastmsg(ChatUser user) {
    return firestore
        .collection('chats/${getconversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getconversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('Users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //get user id of this particular user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('Users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //Adding Chat User
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    await firestore.collection('Users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getconversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }
}
