class Business {
  String? name;
  String? address;
  String? logo;

  Business({
    this.name,
    this.address,
    this.logo,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      name: json['name'],
      address: json['address'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["name"] = name;
    data["address"] = address;
    data["logo"] = logo;
    return data;
  }
}
