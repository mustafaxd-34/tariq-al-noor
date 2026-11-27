import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../data/app_store.dart';
import '../data/calculations.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {const ReportsScreen({super.key});@override State<ReportsScreen> createState()=>_ReportsScreenState();}
class _ReportsScreenState extends State<ReportsScreen>{
 String type='يومي';
 DateTime selectedDate=DateTime.now();
 String get dayKey=>DateFormat('yyyy-MM-dd').format(selectedDate);
 List<dynamic> _filtered(AppStore s){
  final start=DateTime(selectedDate.year,selectedDate.month,selectedDate.day);
  DateTime from=start,to=start.add(const Duration(days:1));
  if(type=='أسبوعي'){from=start.subtract(Duration(days:start.weekday-1));to=from.add(const Duration(days:7));}
  if(type=='شهري'){from=DateTime(start.year,start.month,1);to=DateTime(start.year,start.month+1,1);}
  final ids=s.students.map((e)=>e.id).toSet();
  return s.records.where((r)=>ids.contains(r.studentId)&&!DateTime.parse(r.date).isBefore(from)&&DateTime.parse(r.date).isBefore(to)).toList()..sort((a,b)=>a.date.compareTo(b.date));
 }
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();final rows=_filtered(s);
  final grouped=<int,List<dynamic>>{};
  for(final r in rows){grouped.putIfAbsent(r.studentId,()=>[]).add(r);}
  return ListView(padding:const EdgeInsets.all(16),children:[
   const Text('التقارير والمتابعة',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
   const SizedBox(height:12),SegmentedButton<String>(segments:const [ButtonSegment(value:'يومي',label:Text('يومي')),ButtonSegment(value:'أسبوعي',label:Text('أسبوعي')),ButtonSegment(value:'شهري',label:Text('شهري'))],selected:{type},onSelectionChanged:(v)=>setState(()=>type=v.first)),
   ListTile(title:Text('الفترة: $dayKey'),trailing:IconButton(icon:const Icon(Icons.calendar_month),onPressed:()async{final d=await showDatePicker(context:context,initialDate:selectedDate,firstDate:DateTime(2020),lastDate:DateTime(2100));if(d!=null)setState(()=>selectedDate=d);})),
   Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
    Text(s.selected?.name??'طريق النور',style:const TextStyle(color:AppTheme.gold,fontSize:22,fontWeight:FontWeight.bold)),
    Text(type=='يومي'?'تقرير يوم $dayKey':type=='أسبوعي'?'التقرير الأسبوعي':'التقرير الشهري'),
    Text(s.selected?.section=='Women & Girls'?'نسائي':'رجالي'),
    const Divider(),
    Text('عدد الطلاب المسجل لهم في الفترة: ${grouped.length} • عدد السجلات: ${rows.length}'),
    ...s.students.where((st)=>grouped.containsKey(st.id)).map((st){final rr=grouped[st.id]!;final present=rr.where((r)=>r.present).length;return ListTile(dense:true,title:Text(st.name),subtitle:Text('أيام الحضور: $present من ${rr.length} • الحفظ: ${rr.fold<double>(0,(v,r)=>v+r.newPages).toStringAsFixed(1)} وجه • آخر تسجيل: ${rr.last.date}'),trailing:Text(StudentStats.gradeLabel(StudentStats.averageGrade(rr))));}),
    if(rows.isEmpty) const Padding(padding:EdgeInsets.all(16),child:Text('لا توجد سجلات في الفترة المحددة بعد.')),
    const Divider(),const Text('اللهم اجعل القرآن ربيع قلوبنا ونور صدورنا وذكرنا في الدنيا والآخرة',textAlign:TextAlign.center),
    const SizedBox(height:12),FilledButton.icon(onPressed:rows.isEmpty?null:()=>_export(context,s,rows),icon:const Icon(Icons.picture_as_pdf),label:const Text('تصدير تقرير الفترة PDF')),
   ]))),
  ]);
 }
 Future<void> _export(BuildContext context,AppStore s,List<dynamic> rows) async {
  final doc=pw.Document();
  doc.addPage(pw.MultiPage(build:(c)=>[
   pw.Header(level:0,child:pw.Text(s.selected?.name??'طريق النور')),
   pw.Text(type=='يومي'?'تقرير يوم $dayKey':type=='أسبوعي'?'التقرير الأسبوعي':'التقرير الشهري'),
   pw.Table.fromTextArray(headers:['التاريخ','الاسم','الحضور','الحفظ الجديد','المراجعة','الشيخ'],data:rows.map((r){final st=s.students.firstWhere((x)=>x.id==r.studentId);return [r.date,st.name,r.present?'حاضر':'غائب',r.newMemorization,r.review,r.teacherName];}).toList()),
   pw.SizedBox(height:20),pw.Text('اللهم اجعل القرآن ربيع قلوبنا ونور صدورنا وذكرنا في الدنيا والآخرة'),
  ]));
  final Uint8List bytes=await doc.save();
  await Printing.sharePdf(bytes:bytes,filename:'tariq_al_noor_${type}_report.pdf');
 }
}
