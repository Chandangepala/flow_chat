import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow_chat/models/message_model.dart';

import '../../models/user_model.dart';
import '../../utils/SharedPref.dart';

class FirebaseRepository {
  static const String PREF_USER_KEY = "userId";
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const String COLLECTION_USERS = "users";
  static const String COLLECTION_CHATROOM = "chatroom";
  static const String COLLECTION_MESSAGES = "messages";
  static const String COLLECTION_IDs = "IDs";
  int index = 0;
  Future<void> createUser({
    required UserModel user,
    required String password,
  }) async {
    try {
      var userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: user.email!,
        password: password,
      );

      if (userCredential.user != null) {
        user.userId = userCredential.user!.uid;
        firestore
            .collection(COLLECTION_USERS)
            .doc(userCredential.user!.uid)
            .set(user.toMap())
            .catchError((e) {
              throw (Exception("Error: $e"));
            });
      }
    } on FirebaseAuthException catch (e) {
      throw (Exception("Error: $e"));
    } catch (e) {
      throw (Exception("Error: $e"));
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      var userCred = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCred.user != null) {
        var sharedPref = SharedPref();
        await sharedPref.setSharedPref(PREF_USER_KEY, userCred.user!.uid);
        return userCred.user!.uid;
      }
    } on FirebaseAuthException catch (e) {
      throw (Exception("Error: Invalid email or password!"));
    } catch (e) {
      throw (Exception("Error: $e"));
    }
    return "";
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAllContacts() async {
    QuerySnapshot<Map<String, dynamic>> usersMap =
        await firestore.collection(COLLECTION_USERS).get();
    return usersMap;
  }

  static Future<String> getFromId() async {
    String userId = await SharedPref().getSharedPref(PREF_USER_KEY);
    print("getFromId::userId: $userId");
    return userId;
  }

  static String getChatId({required String fromId, required String toId}) {
    if (fromId.hashCode <= toId.hashCode) {
      return "${fromId}_${toId}";
    } else {
      return "${toId}_${fromId}";
    }
  }

  static Future<void> sendTextMessage({
    required String toId,
    required String message,
  }) async {
    try {
      var currentTime = DateTime.now().microsecondsSinceEpoch.toString();
      var fromId = await getFromId();
      var chatId = getChatId(fromId: fromId, toId: toId);

      // Optional: Check if essential data is valid
      if (fromId.isEmpty || chatId.isEmpty || message.trim().isEmpty) {
        print(
          "Invalid data provided for sending message:: fromId: $fromId, chatId: $chatId, message: $message",
        );
        throw Exception("Invalid data provided for sending message.");
      }

      var messageModel = MessageModel(
        msgId: currentTime,
        message: message,
        fromId: fromId,
        toId: toId,
        sentAt: currentTime,
      );

      await firestore.collection(COLLECTION_CHATROOM).doc(chatId).get().then((
        value,
      ) {
        if (value.exists) {
          firestore
              .collection(COLLECTION_CHATROOM)
              .doc(chatId)
              .collection(COLLECTION_MESSAGES)
              .doc(currentTime)
              .set(messageModel.toMap());
        } else {
          //adding all chat ids in chat document fields
          firestore
              .collection(COLLECTION_CHATROOM)
              .doc(chatId)
              .set({
                'ids': [fromId, toId],
              })
              .then(
                (value) => firestore
                    .collection(COLLECTION_CHATROOM)
                    .doc(chatId)
                    .collection(COLLECTION_MESSAGES)
                    .doc(currentTime)
                    .set(messageModel.toMap()),
              );
        }
      });
    } catch (e) {
      print("Error sending message: $e");
      throw Exception("Error sending message: $e");
    }
  }

  static sendImageMessage({
    required String toId,
    String? message,
    required String imgUrl,
  }) async {
    var currentTime = DateTime.now().microsecondsSinceEpoch.toString();
    var fromId = await getFromId();
    var chatId = await getChatId(fromId: fromId, toId: toId);

    var messageModel = MessageModel(
      msgId: currentTime,
      message: message ?? "",
      fromId: fromId,
      toId: toId,
      sentAt: currentTime,
      imgUrl: imgUrl,
      msgType: 1,
    );

    await firestore
        .collection(COLLECTION_CHATROOM)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .doc(currentTime)
        .set(messageModel.toMap());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatStream({
    required String fromId,
    required String toId,
  }) {
    String chatId = getChatId(fromId: fromId, toId: toId);
    return firestore
        .collection(COLLECTION_CHATROOM)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatRoomIdStream() {
    return firestore.collection(COLLECTION_CHATROOM).snapshots();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUsersByUserId({
    required String userId,
  }) async {
    return await firestore.collection(COLLECTION_USERS).doc(userId).get();
  }

  static void updateReadStatus({
    required String messageId,
    required String fromId,
    required String toId,
  }) {
    String currentTime = DateTime.now().microsecondsSinceEpoch.toString();
    String chatId = getChatId(fromId: fromId, toId: toId);
    firestore
        .collection(COLLECTION_CHATROOM)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .doc(messageId)
        .update({"readAt": currentTime});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage({required String fromId, required String toId}){
    String chatId = getChatId(fromId: fromId, toId: toId);
    return firestore
        .collection(COLLECTION_CHATROOM)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .orderBy("sentAt", descending: true)
        .limit(1)
        .snapshots();
  }
  
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUnreadMsgCount({required String fromId, required String toId}){
    String chatId = getChatId(fromId: fromId, toId: toId);
    return firestore
        .collection(COLLECTION_CHATROOM)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .where("readAt", isEqualTo: "")
        .where("fromId", isEqualTo: toId)
        .snapshots();
  }
}
