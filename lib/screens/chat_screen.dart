import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_chat/data/remote/firebase_repository.dart';
import 'package:flow_chat/models/user_model.dart';
import 'package:flow_chat/utils/FormatDateTime.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  UserModel user;

  ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  String fromId = "";

  @override
  void initState() {
    super.initState();
    initChatroom();
  }

  initChatroom() async {
    fromId = await FirebaseRepository.getFromId();
    print("initChatroom::fromId: $fromId");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        actionsIconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black54,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  widget.user.profilePic != null &&
                          widget.user.profilePic!.isNotEmpty
                      ? NetworkImage("${widget.user.profilePic}")
                      : AssetImage("assets/images/user.png"),
            ),
            SizedBox(width: 25),
            Text(widget.user.name!, style: TextStyle(color: Colors.white)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child:
                fromId.isEmpty
                    ? Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseRepository.getChatStream(
                        fromId: fromId,
                        toId: widget.user.userId!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Something went wrong: ${snapshot.error}",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (!snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                "No messages yet!",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          } else {
                            List<MessageModel> messages = List.generate(
                              snapshot.data!.docs.length,
                              (index) => MessageModel.fromMap(
                                snapshot.data!.docs[index].data(),
                              ),
                            );
                            if (messages.isEmpty) {
                              return Center(
                                child: Text(
                                  "No messages yet!!",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                            else {
                              _scrollToEnd();
                              return ListView.builder(
                                itemBuilder: (context, index) {
                                  print("messages[index].fromId: ${messages[index].fromId}");
                                  if(fromId != messages[index].fromId && messages[index].readAt!.isEmpty){
                                    FirebaseRepository.updateReadStatus(messageId: messages[index].msgId!, fromId: fromId, toId: widget.user.userId!);
                                  }
                                  return Align(
                                    alignment:
                                        fromId == messages[index].fromId
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.5,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            fromId == messages[index].fromId
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade700,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomLeft:
                                              fromId == messages[index].fromId
                                                  ? Radius.circular(15)
                                                  : Radius.circular(0),
                                          bottomRight:
                                              fromId == messages[index].fromId
                                                  ? Radius.circular(0)
                                                  : Radius.circular(15),
                                        ),
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 7,
                                          horizontal: 3,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              messages[index].message!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 10),

                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  FormatDataTime.getFormattedDateTime(
                                                    messages[index].sentAt!,
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade300,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                fromId == messages[index].fromId
                                                    ? Icon(
                                                      Icons.done_all,
                                                      color: messages[index].readAt!.isNotEmpty
                                                          ? Colors.blue : Colors.white,
                                                      size: 16,
                                                    )
                                                    : Container(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: messages.length,
                                controller: scrollController,
                              );

                            }
                          }
                        } else {
                          return Container(
                            child: Center(
                              child: Text(
                                "Something went wrong!!: ${snapshot.error}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      },
                    ),
          ),

          TextField(
            controller: messageController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              hintText: "Type a message",
              suffixIcon: IconButton(
                onPressed: () async {
                  if (messageController.text.isNotEmpty) {
                    await FirebaseRepository.sendTextMessage(
                      toId: widget.user.userId!,
                      message: messageController.text,
                    );
                    messageController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Message can't be empty")),
                    );
                  }
                },
                icon: Icon(Icons.send),
              ),
              prefixIcon: IconButton(
                onPressed: () {},
                icon: Icon(Icons.attach_file),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.greenAccent, width: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to scroll to the end of the list
  void _scrollToEnd() {
    // This is crucial: wait for the frame to render
    // before attempting to scroll, especially if new items are added.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
