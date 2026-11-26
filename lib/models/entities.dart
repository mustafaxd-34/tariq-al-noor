class Institution {
  final int? id; final String name; final String section;
  const Institution({this.id, required this.name, required this.section});
  Map<String,Object?> toMap()=>{'id':id,'name':name,'section':section};
  factory Institution.fromMap(Map<String,Object?> m)=>Institution(id:m['id'] as int?,name:m['name'] as String,section:m['section'] as String);
}
class Student {
  final int? id; final int institutionId; final String name; final String? phone; final String joinDate; final double pagesBefore;
  const Student({this.id,required this.institutionId,required this.name,this.phone,required this.joinDate,this.pagesBefore=0});
  Map<String,Object?> toMap()=>{'id':id,'institution_id':institutionId,'name':name,'phone':phone,'join_date':joinDate,'pages_before':pagesBefore};
  factory Student.fromMap(Map<String,Object?> m)=>Student(id:m['id'] as int?,institutionId:m['institution_id'] as int,name:m['name'] as String,phone:m['phone'] as String?,joinDate:m['join_date'] as String,pagesBefore:(m['pages_before'] as num).toDouble());
}
class DailyRecord {
  final int? id; final int studentId; final String date; final bool present; final String newMemorization,review,hadith,jazariyya,tuhfa,notes; final double newPages; final int grade;
  const DailyRecord({this.id,required this.studentId,required this.date,this.present=true,this.newMemorization='',this.review='',this.hadith='',this.jazariyya='',this.tuhfa='',this.newPages=0,this.grade=0,this.notes=''});
  Map<String,Object?> toMap()=>{'id':id,'student_id':studentId,'date':date,'present':present?1:0,'new_memorization':newMemorization,'review':review,'hadith':hadith,'jazariyya':jazariyya,'tuhfa':tuhfa,'new_pages':newPages,'grade':grade,'notes':notes};
  factory DailyRecord.fromMap(Map<String,Object?> m)=>DailyRecord(id:m['id'] as int?,studentId:m['student_id'] as int,date:m['date'] as String,present:m['present']==1,newMemorization:m['new_memorization'] as String,review:m['review'] as String,hadith:m['hadith'] as String,jazariyya:m['jazariyya'] as String,tuhfa:m['tuhfa'] as String,newPages:(m['new_pages'] as num).toDouble(),grade:m['grade'] as int,notes:m['notes'] as String);
}
