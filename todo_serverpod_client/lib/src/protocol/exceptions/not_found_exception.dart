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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class NotFoundException
    implements _i1.SerializableException, _i1.SerializableModel {
  NotFoundException._({
    int? statusCode,
    String? message,
    String? errorCode,
  }) : statusCode = statusCode ?? 404,
       message = message ?? 'Resource not found.',
       errorCode = errorCode ?? 'NOT_FOUND';

  factory NotFoundException({
    int? statusCode,
    String? message,
    String? errorCode,
  }) = _NotFoundExceptionImpl;

  factory NotFoundException.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotFoundException(
      statusCode: jsonSerialization['statusCode'] as int?,
      message: jsonSerialization['message'] as String?,
      errorCode: jsonSerialization['errorCode'] as String?,
    );
  }

  int statusCode;

  String message;

  String errorCode;

  /// Returns a shallow copy of this [NotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NotFoundException copyWith({
    int? statusCode,
    String? message,
    String? errorCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NotFoundException',
      'statusCode': statusCode,
      'message': message,
      'errorCode': errorCode,
    };
  }

  @override
  String toString() {
    return 'NotFoundException(statusCode: $statusCode, message: $message, errorCode: $errorCode)';
  }
}

class _NotFoundExceptionImpl extends NotFoundException {
  _NotFoundExceptionImpl({
    int? statusCode,
    String? message,
    String? errorCode,
  }) : super._(
         statusCode: statusCode,
         message: message,
         errorCode: errorCode,
       );

  /// Returns a shallow copy of this [NotFoundException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NotFoundException copyWith({
    int? statusCode,
    String? message,
    String? errorCode,
  }) {
    return NotFoundException(
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
    );
  }
}
