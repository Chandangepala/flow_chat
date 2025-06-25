class UserModel{
  String? userId;
  String? name;
  String? email;
  String? mobileNo;
  String? gender;
  String? createdAt;
  bool isOnline = false;
  int? status = 1; //1:active/2:in-active/3:suspended
  String? profilePic = "";
  int? profileStatus = 1; //1:public/2:private/3:friends

  UserModel({
    this.userId,
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.gender,
    required this.createdAt,
    required this.isOnline,
    required this.status,
    required this.profilePic,
    required this.profileStatus,
  });

  factory UserModel.fromJSON(Map<String, dynamic> map) => UserModel(
    userId: map['userId'],
    name: map['name'],
    email: map['email'],
    mobileNo: map['mobileNo'],
    gender: map['gender'],
    createdAt: map['createdAt'],
    isOnline: map['isOnline'],
    status: map['status'],
    profilePic: map['profilePic'],
    profileStatus: map['profileStatus'],
  );

  Map<String, dynamic> toMap() => {
    "userId": userId,
    "name": name,
    "email": email,
    "mobileNo": mobileNo,
    "gender": gender,
    "createdAt": createdAt,
    "isOnline": isOnline,
    "status": status,
    "profilePic": profilePic,
    "profileStatus": profileStatus,
  };
}