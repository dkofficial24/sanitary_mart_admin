class EndUser {
  String? id;
  String name;
  String mobile;
  String village;

  EndUser({
    this.id,
    required this.name,
    required this.mobile,
    required this.village,
  });

  // Convert JSON to EndUser object
  factory EndUser.fromJson(Map<String, dynamic> json) {
    return EndUser(
      id: json['id'] as String?,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      village: json['village'] as String,
    );
  }

  // Convert EndUser object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'village': village,
    };
  }
}
