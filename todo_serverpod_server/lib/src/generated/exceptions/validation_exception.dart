/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ValidationException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  ValidationException._({
    int? statusCode,
    String? message,
    String? errorCode,
  }) : statusCode = statusCode ?? 400,
       message = message ?? 'Invalid request.',
       errorCode = errorCode ?? 'VALIDATION_ERROR';

  factory ValidationException({
    int? statusCode,
    String? message,
    String? errorCode,
  }) = _ValidationExceptionImpl;

  factory ValidationException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ValidationException(
      statusCode: jsonSerialization['statusCode'] as int?,
      message: jsonSerialization['message'] as String?,
      errorCode: jsonSerialization['errorCode'] as String?,
    );
  }

  int statusCode;

  String message;

  String errorCode;

  /// Returns a shallow copy of this [ValidationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ValidationException copyWith({
    int? statusCode,
    String? message,
    String? errorCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ValidationException',
      'statusCode': statusCode,
      'message': message,
      'errorCode': errorCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ValidationException',
      'statusCode': statusCode,
      'message': message,
      'errorCode': errorCode,
    };
  }

  @override
  String toString() {
    return 'ValidationException(statusCode: $statusCode, message: $message, errorCode: $errorCode)';
  }
}

class _ValidationExceptionImpl extends ValidationException {
  _ValidationExceptionImpl({
    int? statusCode,
    String? message,
    String? errorCode,
  }) : super._(
         statusCode: statusCode,
         message: message,
         errorCode: errorCode,
       );

  /// Returns a shallow copy of this [ValidationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ValidationException copyWith({
    int? statusCode,
    String? message,
    String? errorCode,
  }) {
    return ValidationException(
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
    );
  }
}
