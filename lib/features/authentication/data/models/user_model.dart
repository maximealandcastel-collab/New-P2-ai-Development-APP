class UserModel {
  String? sId;
  String? name;
  String? email;
  String? image;
  String? role;
  String? profileStatus;
  bool? isPaid;
  int? phone;
  String? height;
  String? weight;
  String? occupation;
  String? age;

  UserModel({
    this.sId,
    this.name,
    this.email,
    this.image,
    this.role,
    this.profileStatus,
    this.isPaid,
    this.phone,
    this.height,
    this.weight,
    this.occupation,
    this.age,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    image = json['image'];
    role = json['role'];
    profileStatus = json['profileStatus'];
    isPaid = json['isPaid'];
    phone = json['phone'];
    height = json['height'];
    weight = json['weight'];
    occupation = json['occupation'];
    age = json['age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['image'] = image;
    data['role'] = role;
    data['profileStatus'] = profileStatus;
    data['isPaid'] = isPaid;
    data['phone'] = phone;
    data['height'] = height;
    data['weight'] = weight;
    data['occupation'] = occupation;
    data['age'] = age;
    return data;
  }

  UserModel copyWith({
    String? sId,
    String? name,
    String? email,
    String? image,
    String? role,
    String? profileStatus,
    bool? isPaid,
    int? phone,
    String? height,
    String? weight,
    String? occupation,
    String? age,
  }) {
    return UserModel(
      sId: sId ?? this.sId,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      role: role ?? this.role,
      profileStatus: profileStatus ?? this.profileStatus,
      isPaid: isPaid ?? this.isPaid,
      phone: phone ?? this.phone,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      occupation: occupation ?? this.occupation,
      age: age ?? this.age,
    );
  }
}