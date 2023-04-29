class InvalidCredentialsException implements Exception {
  final String message;

  InvalidCredentialsException({required this.message});

  @override
  String toString() => 'InvalidCredentialsException: $message';
}
