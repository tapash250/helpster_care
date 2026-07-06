import 'package:freezed_annotation/freezed_annotation.dart';

part 'ward.freezed.dart';
part 'ward.g.dart';

/// Hospital ward.
@freezed
class Ward with _$Ward {
  const factory Ward({
    required String id,
    required String hospitalId,
    required String name,
    String? description,
    @Default(0) int capacity,
    @Default(true) bool isActive,
  }) = _Ward;

  factory Ward.fromJson(Map<String, dynamic> json) => _$WardFromJson(json);
}
