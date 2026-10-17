import 'package:equatable/equatable.dart';

/// Base sealed class for functional error handling across all layers.
/// Uses Dart 3.13 `const` primary constructor `()` directly in the header.
sealed class const Result<T>() {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Extracts data if [Success], otherwise returns null.
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Failure<T>() => null,
  };

  /// Extracts [AppFailure] if [Failure], otherwise returns null.
  AppFailure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final failure) => failure,
  };

  /// Pattern-matches both states explicitly.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) => switch (this) {
    Success<T>(:final data) => onSuccess(data),
    Failure<T>(:final failure) => onFailure(failure),
  };

  /// Transforms the success value while preserving any failure.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success<T>(:final data) => Success(transform(data)),
    Failure<T>(:final failure) => Failure(failure),
  };
}

/// Dart 3.13 declaring primary constructors
final class const Success<T>(final T data) extends Result<T>;

final class const Failure<T>(final AppFailure failure) extends Result<T>;

/// Base failure class using Dart named declaring parameters + Equatable mixin.
sealed class const AppFailure({
  required final String message,
  final String? code,
  final StackTrace? stackTrace,
}) with Equatable {
  @override
  List<Object?> get props => [message, code];
}

final class const NetworkFailure({required super.message, super.code, super.stackTrace})
    extends AppFailure;

final class const StorageFailure({required super.message, super.code, super.stackTrace})
    extends AppFailure;

final class const IsolateExecutionFailure({required super.message, super.code, super.stackTrace})
    extends AppFailure;

final class const HardwareThermalFailure({required super.message, super.code, super.stackTrace})
    extends AppFailure;
