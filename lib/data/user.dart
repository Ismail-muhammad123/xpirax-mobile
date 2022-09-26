class User {
  int business;
  String fullName;
  String email;
  String mobileNumber;
  bool isOwner;

  User({
    required this.business,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.isOwner,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      business: json["business"],
      fullName: json["full_name"],
      email: json["email"],
      mobileNumber: json["mobile_number"],
      isOwner: json['is_owner'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["business"] = this.business;
    data["full_name"] = this.fullName;
    data["email"] = this.email;
    data["mobile_number"] = this.mobileNumber;
    data["is_owner"] = this.isOwner;
    return data;
  }
}
