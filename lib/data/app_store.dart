import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/entities.dart';

class AppStore extends ChangeNotifier {
  late Database db;
  List<Institution> institutions=[];
  List<Student> students=[];
  List<DailyRecord> records=[];
  Institution? selected;
  Future<void> initialize() async {
    final path=p.join(await getDatabasesPath(),'tariq_al_noor.db');
    db=await openDatabase(path,version:2,onCreate:(d,v) async {
      await d.execute('CREATE TABLE institutions(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,section TEXT NOT NULL)');
      await d.execute("CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT,institution_id INTEGER NOT NULL,name TEXT NOT NULL,phone TEXT,join_date TEXT NOT NULL,pages_before REAL NOT NULL DEFAULT 0,guardian_name TEXT NOT NULL DEFAULT '',guardian_phone TEXT NOT NULL DEFAULT '',address TEXT NOT NULL DEFAULT '',notes TEXT NOT NULL DEFAULT '',FOREIGN KEY(institution_id) REFERENCES institutions(id))");
      await d.execute("CREATE TABLE daily_records(id INTEGER PRIMARY KEY AUTOINCREMENT,student_id INTEGER NOT NULL,date TEXT NOT NULL,present INTEGER NOT NULL,new_memorization TEXT NOT NULL,review TEXT NOT NULL,hadith TEXT NOT NULL,jazariyya TEXT NOT NULL,tuhfa TEXT NOT NULL,new_pages REAL NOT NULL,grade INTEGER NOT NULL,notes TEXT NOT NULL DEFAULT '',teacher_name TEXT NOT NULL DEFAULT '',UNIQUE(student_id,date),FOREIGN KEY(student_id) REFERENCES students(id))");
      await d.execute('CREATE TABLE settings(key TEXT PRIMARY KEY,value TEXT NOT NULL)');
      await d.execute('CREATE TABLE report_archive(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,created_at TEXT NOT NULL,payload TEXT NOT NULL)');
    },onUpgrade:(d,oldVersion,newVersion) async {
      if(oldVersion<2){
        await d.execute("ALTER TABLE students ADD COLUMN guardian_name TEXT NOT NULL DEFAULT ''");
        await d.execute("ALTER TABLE students ADD COLUMN guardian_phone TEXT NOT NULL DEFAULT ''");
        await d.execute("ALTER TABLE students ADD COLUMN address TEXT NOT NULL DEFAULT ''");
        await d.execute("ALTER TABLE students ADD COLUMN notes TEXT NOT NULL DEFAULT ''");
        await d.execute("ALTER TABLE daily_records ADD COLUMN teacher_name TEXT NOT NULL DEFAULT ''");
      }
    });
    await refresh();
  }
  Future<void> refresh() async {
    institutions=(await db.query('institutions',orderBy:'id')).map(Institution.fromMap).toList();
    if(selected==null && institutions.isNotEmpty) selected=institutions.first;
    if(selected!=null && !institutions.any((e)=>e.id==selected!.id)) selected=institutions.isEmpty?null:institutions.first;
    students=(await db.query('students',where:selected==null?'1=0':'institution_id=?',whereArgs:selected==null?[]:[selected!.id],orderBy:'name COLLATE NOCASE')).map(Student.fromMap).toList();
    records=(await db.query('daily_records',orderBy:'date DESC')).map(DailyRecord.fromMap).toList();
    notifyListeners();
  }
  void select(Institution? i){selected=i;refresh();}
  Future<void> addInstitution(String name,String section) async {await db.insert('institutions',{'name':name,'section':section});await refresh();}
  Future<void> renameInstitution(int id,String name) async {await db.update('institutions',{'name':name},where:'id=?',whereArgs:[id]);await refresh();}
  Future<void> deleteInstitution(int id) async {
    final ids=(await db.query('students',columns:['id'],where:'institution_id=?',whereArgs:[id])).map((e)=>e['id'] as int).toList();
    for(final sid in ids){await db.delete('daily_records',where:'student_id=?',whereArgs:[sid]);}
    await db.delete('students',where:'institution_id=?',whereArgs:[id]);await db.delete('institutions',where:'id=?',whereArgs:[id]);selected=null;await refresh();
  }
  Future<void> addStudent(Student s) async {await db.insert('students',s.toMap());await refresh();}
  Future<void> updateStudent(Student s) async {await db.update('students',s.toMap()..remove('id'),where:'id=?',whereArgs:[s.id]);await refresh();}
  Future<void> deleteStudent(int id) async {await db.delete('daily_records',where:'student_id=?',whereArgs:[id]);await db.delete('students',where:'id=?',whereArgs:[id]);await refresh();}
  Future<void> saveRecord(DailyRecord r) async {
    await db.insert('daily_records',r.toMap(),conflictAlgorithm:ConflictAlgorithm.replace);
    await refresh();
  }
  List<DailyRecord> forStudent(int id)=>records.where((r)=>r.studentId==id).toList()..sort((a,b)=>a.date.compareTo(b.date));
  Future<void> saveSetting(String key,String value) async {await db.insert('settings',{'key':key,'value':value},conflictAlgorithm:ConflictAlgorithm.replace);}
  Future<String> setting(String key,{String fallback=''}) async {final r=await db.query('settings',where:'key=?',whereArgs:[key]);return r.isEmpty?fallback:r.first['value'] as String;}
}
