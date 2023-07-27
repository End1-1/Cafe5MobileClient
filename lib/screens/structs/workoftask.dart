import 'package:freezed_annotation/freezed_annotation.dart';

part 'workoftask.freezed.dart';
part 'workoftask.g.dart';

@freezed
class WorkOfTask with _$WorkOfTask {
  const factory WorkOfTask({
    required int f_id,
    required int f_rowid,
    required int f_product,
    required String f_grname,
    required int f_process,
    required String f_acname,
    required int f_durationsec,
    required double f_price,
    required int f_state
}) = _WorkOfTask;
  factory WorkOfTask.fromJson(Map<String,dynamic> json) => _$WorkOfTaskFromJson(json);
}