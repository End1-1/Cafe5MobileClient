import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({required int f_id, required String f_name, required int f_product}) = _Task;
  factory Task.fromJson(Map<String,dynamic> json) => _$TaskFromJson(json);
}