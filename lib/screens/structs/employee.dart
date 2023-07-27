import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';
part 'employee.g.dart';

@freezed
class Teamlead with _$Teamlead {
  const factory Teamlead({required int f_id, required String f_name}) = _Teamlead;
  factory Teamlead.fromJson(Map<String, dynamic> json) => _$TeamleadFromJson(json);
}

@freezed
class Employee with _$Employee {
  const factory Employee({required int f_id, required int f_teamlead, required String f_name}) = _Employee;
  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
}