import 'package:freezed_annotation/freezed_annotation.dart';

part 'workdetails.freezed.dart';
part 'workdetails.g.dart';

@freezed
class WorkDetails with _$WorkDetails {
  const factory WorkDetails({required int f_id,
    required int f_process,
    required String f_color,
    required int f_34p,
    required int f_36p,
    required int f_38p,
    required int f_40p,
    required int f_42p,
    required int f_44p,
    required int f_46p,
    required int f_48p,
    required int f_50p,
    required int f_52p,
  }) = _WorkDetails;

  factory WorkDetails.fromJson(Map<String,dynamic> json) => _$WorkDetailsFromJson(json);
}

@freezed
class WorkDetailsDone with _$WorkDetailsDone {
  const factory WorkDetailsDone({required int f_id,
    required int f_processid,
    required String f_color,
    required int f_34d,
    required int f_36d,
    required int f_38d,
    required int f_40d,
    required int f_42d,
    required int f_44d,
    required int f_46d,
    required int f_48d,
    required int f_50d,
    required int f_52d,
    required int f_34p,
    required int f_36p,
    required int f_38p,
    required int f_40p,
    required int f_42p,
    required int f_44p,
    required int f_46p,
    required int f_48p,
    required int f_50p,
    required int f_52p,
    required int f_34c,
    required int f_36c,
    required int f_38c,
    required int f_40c,
    required int f_42c,
    required int f_44c,
    required int f_46c,
    required int f_48c,
    required int f_50c,
    required int f_52c,
  }) = _WorkDetailsDone;

  factory WorkDetailsDone.fromJson(Map<String,dynamic> json) => _$WorkDetailsDoneFromJson(json);
}