// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tts_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TtsStateData {
  TtsStatus get status => throw _privateConstructorUsedError;
  String get currentText => throw _privateConstructorUsedError;
  bool get isSpeaking => throw _privateConstructorUsedError;
  bool get usedPhoneticFallback => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of TtsStateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TtsStateDataCopyWith<TtsStateData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TtsStateDataCopyWith<$Res> {
  factory $TtsStateDataCopyWith(
          TtsStateData value, $Res Function(TtsStateData) then) =
      _$TtsStateDataCopyWithImpl<$Res, TtsStateData>;
  @useResult
  $Res call(
      {TtsStatus status,
      String currentText,
      bool isSpeaking,
      bool usedPhoneticFallback,
      String? errorMessage});
}

/// @nodoc
class _$TtsStateDataCopyWithImpl<$Res, $Val extends TtsStateData>
    implements $TtsStateDataCopyWith<$Res> {
  _$TtsStateDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TtsStateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentText = null,
    Object? isSpeaking = null,
    Object? usedPhoneticFallback = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TtsStatus,
      currentText: null == currentText
          ? _value.currentText
          : currentText // ignore: cast_nullable_to_non_nullable
              as String,
      isSpeaking: null == isSpeaking
          ? _value.isSpeaking
          : isSpeaking // ignore: cast_nullable_to_non_nullable
              as bool,
      usedPhoneticFallback: null == usedPhoneticFallback
          ? _value.usedPhoneticFallback
          : usedPhoneticFallback // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TtsStateDataImplCopyWith<$Res>
    implements $TtsStateDataCopyWith<$Res> {
  factory _$$TtsStateDataImplCopyWith(
          _$TtsStateDataImpl value, $Res Function(_$TtsStateDataImpl) then) =
      __$$TtsStateDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TtsStatus status,
      String currentText,
      bool isSpeaking,
      bool usedPhoneticFallback,
      String? errorMessage});
}

/// @nodoc
class __$$TtsStateDataImplCopyWithImpl<$Res>
    extends _$TtsStateDataCopyWithImpl<$Res, _$TtsStateDataImpl>
    implements _$$TtsStateDataImplCopyWith<$Res> {
  __$$TtsStateDataImplCopyWithImpl(
      _$TtsStateDataImpl _value, $Res Function(_$TtsStateDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TtsStateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentText = null,
    Object? isSpeaking = null,
    Object? usedPhoneticFallback = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$TtsStateDataImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TtsStatus,
      currentText: null == currentText
          ? _value.currentText
          : currentText // ignore: cast_nullable_to_non_nullable
              as String,
      isSpeaking: null == isSpeaking
          ? _value.isSpeaking
          : isSpeaking // ignore: cast_nullable_to_non_nullable
              as bool,
      usedPhoneticFallback: null == usedPhoneticFallback
          ? _value.usedPhoneticFallback
          : usedPhoneticFallback // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TtsStateDataImpl implements _TtsStateData {
  const _$TtsStateDataImpl(
      {this.status = TtsStatus.stopped,
      this.currentText = '',
      this.isSpeaking = false,
      this.usedPhoneticFallback = false,
      this.errorMessage});

  @override
  @JsonKey()
  final TtsStatus status;
  @override
  @JsonKey()
  final String currentText;
  @override
  @JsonKey()
  final bool isSpeaking;
  @override
  @JsonKey()
  final bool usedPhoneticFallback;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'TtsStateData(status: $status, currentText: $currentText, isSpeaking: $isSpeaking, usedPhoneticFallback: $usedPhoneticFallback, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TtsStateDataImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentText, currentText) ||
                other.currentText == currentText) &&
            (identical(other.isSpeaking, isSpeaking) ||
                other.isSpeaking == isSpeaking) &&
            (identical(other.usedPhoneticFallback, usedPhoneticFallback) ||
                other.usedPhoneticFallback == usedPhoneticFallback) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, currentText, isSpeaking,
      usedPhoneticFallback, errorMessage);

  /// Create a copy of TtsStateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TtsStateDataImplCopyWith<_$TtsStateDataImpl> get copyWith =>
      __$$TtsStateDataImplCopyWithImpl<_$TtsStateDataImpl>(this, _$identity);
}

abstract class _TtsStateData implements TtsStateData {
  const factory _TtsStateData(
      {final TtsStatus status,
      final String currentText,
      final bool isSpeaking,
      final bool usedPhoneticFallback,
      final String? errorMessage}) = _$TtsStateDataImpl;

  @override
  TtsStatus get status;
  @override
  String get currentText;
  @override
  bool get isSpeaking;
  @override
  bool get usedPhoneticFallback;
  @override
  String? get errorMessage;

  /// Create a copy of TtsStateData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TtsStateDataImplCopyWith<_$TtsStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
