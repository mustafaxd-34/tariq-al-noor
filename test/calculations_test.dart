import 'package:flutter_test/flutter_test.dart';
import 'package:tariq_al_noor/data/calculations.dart';
import 'package:tariq_al_noor/models/entities.dart';
void main(){
 test('attendance percentage counts recorded sessions',(){
  final rows=[DailyRecord(studentId:1,date:'2026-01-01',present:true),DailyRecord(studentId:1,date:'2026-01-02',present:false)];
  expect(StudentStats.attendance(rows),50);
 });
 test('memorization percentage is capped at 100',(){
  const s=Student(institutionId:1,name:'أحمد',joinDate:'2026-01-01',pagesBefore:600);
  final rows=[DailyRecord(studentId:1,date:'2026-01-01',newPages:10)];
  expect(StudentStats.memorization(s,rows),100);
 });
 test('grade labels follow thresholds',(){
  expect(StudentStats.gradeLabel(3.7),'ممتاز');
  expect(StudentStats.gradeLabel(2.8),'جيد جداً');
  expect(StudentStats.gradeLabel(1.8),'جيد');
 });
}
