import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helpers/dialogs.dart';
import 'package:chat_app/models/chat_user_model.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../apis/apis.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formkey = GlobalKey<FormState>();
  String? pickedimage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile Screen")),
        body: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Container(
              height: mq.height,
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  height: mq.height * .03,
                  width: mq.width,
                ),
                Stack(children: [
                  pickedimage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.3),
                          child: Image.file(
                            width: mq.height * 0.15,
                            height: mq.height * 0.15,
                            File(pickedimage!),
                            fit: BoxFit.fill,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.3),
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            width: mq.height * 0.15,
                            height: mq.height * 0.15,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                          ),
                        ),
                  Positioned(
                    bottom: -5,
                    right: -25,
                    child: MaterialButton(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      onPressed: () {
                        _showBottomsheet();
                      },
                      child: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ]),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
                SizedBox(
                  height: mq.height * 0.05,
                ),
                TextFormField(
                  onSaved: (newValue) => APis.me.name = newValue ?? "",
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : "Required Field",
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person),
                      hintText: "Eg: Bill Gates",
                      label: const Text("Name")),
                  initialValue: widget.user.name,
                ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                TextFormField(
                  onSaved: (newValue) => APis.me.about = newValue ?? "",
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : "Required Field",
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.info_outline),
                      hintText: "Eg: Connecting with world",
                      label: const Text("About")),
                  initialValue: widget.user.about,
                ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      elevation: 1,
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * 0.04, mq.height * 0.055)),
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      formkey.currentState!.save();
                      APis.updateUser().then((value) => Dialogs.showsnackbar(
                          context, "Updated SUccessfully"));
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Update"),
                ),
                const Spacer(),
                Container(
                  margin: EdgeInsets.only(bottom: mq.height * 0.01),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        elevation: 1,
                        shape: const StadiumBorder(),
                        minimumSize: Size(mq.width * 0.04, mq.height * 0.055)),
                    onPressed: () async {
                      Dialogs.showProgressIndicator(context);

                      await APis.updateActiveStatus(false);

                      await APis.auth.signOut().then(
                        (value) async {
                          await GoogleSignIn().signOut().then(
                                (value) => {
                                  Navigator.pop(
                                      context), // poping circular progress indicator
                                  Navigator.pop(
                                      context), // for moving to home screen
                                  APis.auth = FirebaseAuth.instance,
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  ),
                                },
                              );
                        },
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomsheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
          children: [
            Text(
              "Pick your profile picture",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      fixedSize: Size(mq.width * .3, mq.height * .15)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        pickedimage = image.path;
                      });
                    }
                    APis.updateProfilePicture(File(pickedimage!));

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  child: Image.asset("assets/images/photo-gallery.png"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      fixedSize: Size(mq.width * .3, mq.height * .15)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        pickedimage = image.path;
                      });
                      APis.updateProfilePicture(File(pickedimage!));
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset("assets/images/camera.png"),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
