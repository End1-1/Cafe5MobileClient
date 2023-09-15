import 'package:freezed_annotation/freezed_annotation.dart';

part 'work.freezed.dart';

part 'work.g.dart';

@freezed
class Work with _$Work {
  const factory Work(
      {required int f_goal,
      required int f_id,
      required int f_laststep,
      required int f_taskid,
      required double f_price,
      required int f_process,
      required String f_productname,
      required String f_processname,
      required int f_qty,
      required int f_ready}) = _Work;

  factory Work.fromJson(Map<String, dynamic> json) => _$WorkFromJson(json);
}
