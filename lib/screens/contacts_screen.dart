import 'package:flow_chat/data/remote/firebase_repository.dart';
import 'package:flow_chat/models/user_model.dart';
import 'package:flow_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  String currentUserId = "";
  @override
  void initState() {
    super.initState();
    getUserId();
  }

  getUserId() async {
    currentUserId = await FirebaseRepository.getFromId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        actionsIconTheme: IconThemeData(color: Colors.white),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text("All Contacts", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black54,
        elevation: 3,
      ),
      body: FutureBuilder(
        future: FirebaseRepository.getAllContacts(),
        builder: (context, snaphots) {
          if (snaphots.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snaphots.hasError) {
            return Center(child: Text("Error: ${snaphots.error}"));
          } else if (snaphots.hasData) {
            if (snaphots.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  UserModel currentContact = UserModel.fromJSON(
                    snaphots.data!.docs[index].data(),
                  );
                  if(currentContact.userId == currentUserId){
                    currentContact.name = "${currentContact.name!} (Me)";
                  }
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user: currentContact)));
                    },
                    child: Card(
                      color: Colors.grey.shade800,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: currentContact.profilePic != null && currentContact.profilePic!.isNotEmpty ? NetworkImage("${currentContact.profilePic}") : AssetImage("assets/images/user.png"),
                        ),
                        title: Text(
                          currentContact.name!,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          currentContact.email!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: snaphots.data!.docs.length,
              );
            } else {
              return Center(child: Text("No Data Found"));
            }
          } else {
            return Center(child: Text("No Data Found"));
          }
        },
      ),
    );
  }
}
