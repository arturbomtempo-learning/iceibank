class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  const ApiException.timeout()
    : message = 'A agência demorou demais para responder.',
      statusCode = null;

  const ApiException.unreachable()
    : message = 'Não foi possível falar com a agência. Verifique se ela está no ar.',
      statusCode = null;

  const ApiException.unexpected({this.statusCode})
    : message = 'Não foi possível concluir a operação.';

  final String message;
  final int? statusCode;

  bool get isNetworkFailure => statusCode == null;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
