import 'package:flow_chat/data/remote/firebase_repository.dart';
import 'package:flow_chat/models/user_model.dart';
import 'package:flow_chat/utils/FormatDateTime.dart';
import 'package:flow_chat/utils/SharedPref.dart';
import 'package:flutter/material.dart';

import '../models/message_model.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  String userId;
  HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        actionsIconTheme: IconThemeData(color: Colors.white),
        title: Text("Flow Chat", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () async {
              SharedPref sharedPref = SharedPref();
              await sharedPref.setSharedPref(
                FirebaseRepository.PREF_USER_KEY,
                "",
              );
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: Icon(Icons.logout),
          ),
        ],
        elevation: 5,
      ),
      body: StreamBuilder(
        stream: FirebaseRepository.getChatRoomIdStream(),
        builder: (context, idSnapshot) {
          if (idSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (idSnapshot.hasError) {
            return Center(child: Text("Error: ${idSnapshot.error}"));
          } else if (idSnapshot.hasData && idSnapshot.data != null) {
            print("idSnapshot.data: ${idSnapshot.data}");
            print("idSnapshot.dataSize: ${idSnapshot.data?.size}");
            // Extract the IDs from the documents
            var chatRoomIds = List.generate(idSnapshot.data!.docs.length, (
              index,
            ) {
              var mData =
                  idSnapshot.data!.docs[index].get('ids') as List<dynamic>;
              mData.removeWhere((element) => element == widget.userId);
              return mData[0];
            });
            chatRoomIds = chatRoomIds.toSet().toList();
            print("chatRoomIds: $chatRoomIds");
            return ListView.builder(
              itemBuilder: (context, index) {
                return FutureBuilder(
                  future: FirebaseRepository.getUsersByUserId(
                    userId: chatRoomIds[index],
                  ),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container();
                    } else if (userSnapshot.hasError) {
                      return Center(
                        child: Text("Error: ${userSnapshot.error}"),
                      );
                    } else if (userSnapshot.hasData &&
                        userSnapshot.data != null) {
                      print("userSnapshot.data: ${userSnapshot.data!.data()}");
                      UserModel currentContact = UserModel.fromJSON(
                        userSnapshot.data!.data()!,
                      );
                      if (currentContact.userId == widget.userId) {
                        currentContact.name = "${currentContact.name!} (Me)";
                      }
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatScreen(user: currentContact),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.grey.shade800,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  currentContact.profilePic != null &&
                                          currentContact.profilePic!.isNotEmpty
                                      ? NetworkImage(
                                        "${currentContact.profilePic}",
                                      )
                                      : AssetImage("assets/images/user.png"),
                            ),
                            title: Text(
                              currentContact.name!,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: StreamBuilder(
                              stream: FirebaseRepository.getLastMessage(
                                fromId: widget.userId,
                                toId: currentContact.userId!,
                              ),
                              builder: (_, lastMsgSnapshot) {
                                if (lastMsgSnapshot.hasData) {
                                  var lastMsg = MessageModel.fromMap(
                                    lastMsgSnapshot.data!.docs[0].data(),
                                  );
                                  return lastMsg.fromId == widget.userId
                                      ? Row(
                                        children: [
                                          Icon(
                                            Icons.done_all,
                                            color:
                                                lastMsg.readAt!.isNotEmpty
                                                    ? Colors.blue
                                                    : Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            lastMsg.message!,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Text(
                                        lastMsg.message!,
                                        style: TextStyle(color: Colors.white),
                                      );
                                }
                                return Text(
                                  currentContact.email!,
                                  style: TextStyle(color: Colors.white),
                                );
                              },
                            ),
                            trailing: StreamBuilder(
                              stream: FirebaseRepository.getLastMessage(
                                fromId: widget.userId,
                                toId: currentContact.userId!,
                              ),
                              builder: (context, msgSnapshot) {
                                if (msgSnapshot.hasData) {
                                  var lastMsg = MessageModel.fromMap(
                                    msgSnapshot.data!.docs[0].data(),
                                  );
                                  String time =
                                      FormatDataTime.getFormattedDateTime(
                                        lastMsg.sentAt!,
                                      );
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        time,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      StreamBuilder(stream: FirebaseRepository.getUnreadMsgCount(fromId: widget.userId, toId: currentContact.userId!),
                                          builder: (context, unreadMsgCountSnapshot){
                                              if(unreadMsgCountSnapshot.hasData){
                                                var unreadMsgCount = unreadMsgCountSnapshot.data!.docs.length;
                                                if(unreadMsgCount > 0){
                                                  return CircleAvatar(
                                                    radius: 10,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                      child: Text(unreadMsgCount.toString(), style: TextStyle(color: Colors.white, fontSize: 10),),
                                                    ),
                                                    backgroundColor: Colors.greenAccent.shade700,
                                                  );
                                                }
                                              }
                                              return SizedBox(width: 0, height: 0,);
                                          })
                                    ],
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          "No Data Found!!",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                );
              },
              itemCount: chatRoomIds.length,
            );
          } else {
            return Container(
              child: Center(
                child: Text(
                  "No Data Found!!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/contacts');
        },
        child: Icon(Icons.contacts_outlined),
      ),
    );
  }
}
