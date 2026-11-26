import '../models/entities.dart';
class StudentStats {
  static double attendance(List<DailyRecord> rows) => rows.isEmpty ? 0 : rows.where((r)=>r.present).length*100/rows.length;
  static double memorization(Student s,List<DailyRecord> rows) {
    final pages=s.pagesBefore+rows.where((r)=>r.present).fold<double>(0,(v,r)=>v+r.newPages);
    return (pages*100/604).clamp(0,100);
  }
  static double averageGrade(List<DailyRecord> rows) {
    final grades=rows.where((r)=>r.present && r.grade>0).map((r)=>r.grade).toList();
    return grades.isEmpty?0:grades.reduce((a,b)=>a+b)/grades.length;
  }
  static String gradeLabel(double v)=>v>=3.5?'ممتاز':v>=2.5?'جيد جداً':v>=1.5?'جيد':'مقبول';
}
