class UpdatePersonalInfoRequest {
  const UpdatePersonalInfoRequest({
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.phone,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String displayName;
  final String phone;
  final String email;

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'display_name': displayName,
    'phone': phone,
    'email': email,
  };
}
