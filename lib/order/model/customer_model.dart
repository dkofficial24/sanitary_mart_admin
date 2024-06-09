class Customer {
  String uId;
  String userName;
  String email;
  String? phone;
  String? address;
  String userDeviceToken;
  bool? isAdmin;
  bool? isActive;
  DateTime? createdOn;
  bool? verified;

  Customer(
      {required this.uId,
      required this.userName,
      required this.email,
      this.phone,
      this.address,
      required this.userDeviceToken,
      this.isAdmin = false,
      this.isActive,
      this.createdOn,
      this.verified = false});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    uId: json['uId'] as String,
        userName: json['userName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        userDeviceToken: json['userDeviceToken'] as String,
        isAdmin: json['isAdmin'] as bool?,
        isActive: json['isActive'] as bool?,
        verified: json['verified'] as bool?,
        createdOn: json['createdOn'] != null
            ? DateTime.parse(json['createdOn'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'uId': uId,
        'userName': userName,
        'email': email,
        'phone': phone,
        'address': address,
        'userDeviceToken': userDeviceToken,
        'isAdmin': isAdmin,
        'isActive': isActive,
        'createdOn': createdOn?.toIso8601String(),
      };

  Map<String, dynamic> toOrderJson() =>
      {
        'uId': uId,
        'userName': userName,
        'email': email,
        'phone': phone,
        'address': address,
        'userDeviceToken': userDeviceToken,
      };

  factory Customer.fromOrderJson(Map<String, dynamic> json) => Customer(
    uId: json['uId'] as String,
        userName: json['userName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        userDeviceToken: json['userDeviceToken'] as String,
        isActive: json['isActive'] as bool,
        createdOn: DateTime.parse(json['createdOn'] as String),
        isAdmin: false,
      );
}
