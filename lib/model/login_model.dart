class LoginResponse {
  final String? token;
  final String? message;
  final int statusCode;

  LoginResponse({
    this.token,
    this.message,
    required this.statusCode,
  });

  // Factory untuk mengubah dari JSON ke LoginResponse
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json["token"] as String?,
      message: json["status"] as String?,
      statusCode:
          json.containsKey("statusCode") ? json["statusCode"] as int : 200,
    );
  }

  // Method untuk mengubah dari LoginResponse ke JSON
  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "message": message,
      "statusCode": statusCode,
    };
  }
}
