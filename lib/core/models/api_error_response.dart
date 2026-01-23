class ApiValidationError {
  final String errorCode;
  final String fieldValue;
  final String fieldName; // Mapping from "filedName" or "fieldName"

  ApiValidationError({
    required this.errorCode,
    required this.fieldValue,
    required this.fieldName,
  });

  factory ApiValidationError.fromJson(Map<String, dynamic> json) {
    return ApiValidationError(
      errorCode: json['errorCode'] ?? 'Unknown_Error',
      fieldValue: json['fieldValue'] ?? '',
      // Handling typo in API response "filedName"
      fieldName: json['filedName'] ?? json['fieldName'] ?? '',
    );
  }
}

class ApiErrorResponse {
  final List<ApiValidationError> errors;
  final bool success;
  final String message;

  ApiErrorResponse({
    required this.errors,
    required this.success,
    required this.message,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    // Parse errors list
    var errorsList = <ApiValidationError>[];
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errorsList = (json['errors'] as List)
            .map((e) => ApiValidationError.fromJson(e))
            .toList();
      }
    }

    return ApiErrorResponse(
      errors: errorsList,
      success: json['success'] ?? false,
      message: json['message'] ?? 'Validation failed',
    );
  }
}
