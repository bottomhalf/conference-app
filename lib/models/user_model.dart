/// Represents an authenticated user returned from the login API.
class UserModel {
  final String email;
  final String userId;
  final String firstName;
  final String lastName;
  final String token;
  final String code;

  UserModel({
    required this.email,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.token,
    required this.code,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      token: json['token'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
      'code': code,
    };
  }

  /// Full display name.
  String get fullName => '$firstName $lastName';

  @override
  String toString() => 'UserModel($userId, $fullName, $email)';
}
