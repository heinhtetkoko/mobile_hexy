class BaseResponse<T> {
  const BaseResponse({required this.success, this.data, this.message});

  final bool success;
  final T? data;
  final String? message;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) decode,
  ) => BaseResponse<T>(
    success: json['success'] == true,
    data: json['data'] == null ? null : decode(json['data']),
    message: json['message']?.toString(),
  );
}
