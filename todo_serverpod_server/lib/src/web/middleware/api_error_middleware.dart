import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';

Middleware apiErrorMiddleware() {
  return createMiddleware(
    onError: (error, stackTrace) {
      if (error is ValidationException) {
        return _errorResponse(
          statusCode: error.statusCode,
          errorCode: error.errorCode,
          message: error.message,
        );
      }
      if (error is NotFoundException) {
        return _errorResponse(
          statusCode: error.statusCode,
          errorCode: error.errorCode,
          message: error.message,
        );
      }

      return _errorResponse(
        statusCode: 500,
        errorCode: 'INTERNAL_SERVER_ERROR',
        message: 'Unexpected server error.',
      );
    },
  );
}

Response _errorResponse({
  required int statusCode,
  required String errorCode,
  required String message,
}) {
  final body = Body.fromString(
    jsonEncode({
      'statusCode': statusCode,
      'errorCode': errorCode,
      'message': message,
    }),
    mimeType: MimeType.json,
  );

  switch (statusCode) {
    case 400:
      return Response.badRequest(body: body);
    case 401:
      return Response.unauthorized(body: body);
    case 403:
      return Response.forbidden(body: body);
    case 404:
      return Response.notFound(body: body);
    default:
      return Response.internalServerError(body: body);
  }
}
