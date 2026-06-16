class LoginModel {
  User? user;
  bool? isProfile;
  String? token;

  LoginModel({this.user, this.isProfile, this.token});

  LoginModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    isProfile = json['isProfile'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['isProfile'] = isProfile;
    data['token'] = token;
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? email;
  String? role;

  User({this.sId, this.name, this.email, this.role});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    return data;
  }
}
