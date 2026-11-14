class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.body});

  const ApiException.timeout()
    : message = 'A agência demorou demais para responder.',
      statusCode = null,
      body = null;

  const ApiException.unreachable()
    : message = 'Não foi possível falar com a agência. Verifique se ela está no ar.',
      statusCode = null,
      body = null;

  const ApiException.unexpected({this.statusCode})
    : message = 'Não foi possível concluir a operação.',
      body = null;

  final String message;
  final int? statusCode;
  final Map<String, Object?>? body;

  bool get isNetworkFailure => statusCode == null;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
