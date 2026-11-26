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
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();final today=DateFormat('yyyy-MM-dd').format(DateTime.now());
  final rows=s.records.where((r)=>s.students.any((st)=>st.id==r.studentId)).toList();
  return ListView(padding:const EdgeInsets.all(16),children:[
   const Text('التقارير والمتابعة',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
   const SizedBox(height:12),SegmentedButton<String>(segments:const [ButtonSegment(value:'يومي',label:Text('يومي')),ButtonSegment(value:'أسبوعي',label:Text('أسبوعي')),ButtonSegment(value:'شهري',label:Text('شهري'))],selected:{type},onSelectionChanged:(v)=>setState(()=>type=v.first)),
   const SizedBox(height:14),Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
    Text(s.selected?.name??'طريق النور',style:const TextStyle(color:AppTheme.gold,fontSize:22,fontWeight:FontWeight.bold)),
    Text(type=='يومي'?'جدول المتابعة اليومي':type=='أسبوعي'?'التقرير الأسبوعي':'التقييم الشهري'),
    Text('${s.selected?.section=='Women & Girls'?'نسائي':'رجالي'} • $today'),
    const Divider(),
    ...s.students.asMap().entries.map((entry){final st=entry.value;final rr=rows.where((r)=>r.studentId==st.id).toList();return ListTile(dense:true,title:Text('${entry.key+1}. ${st.name}'),subtitle:Text('الحضور ${StudentStats.attendance(rr).toStringAsFixed(0)}% • الحفظ ${StudentStats.memorization(st,rr).toStringAsFixed(1)}% • الحديث: ${rr.map((e)=>e.hadith).where((e)=>e.isNotEmpty).join('، ')}'),trailing:Text(StudentStats.gradeLabel(StudentStats.averageGrade(rr))));}),
    const Divider(),const Text('اللهم اجعل القرآن ربيع قلوبنا ونور صدورنا وذكرنا في الدنيا والآخرة',textAlign:TextAlign.center),
    const SizedBox(height:12),FilledButton.icon(onPressed:()=>_export(context,s),icon:const Icon(Icons.picture_as_pdf),label:const Text('تصدير PDF ومشاركة')),
   ]))),
  ]);
 }
 Future<void> _export(BuildContext context,AppStore s) async {
  final doc=pw.Document();
  doc.addPage(pw.MultiPage(build:(c)=>[
   pw.Header(level:0,child:pw.Text(s.selected?.name??'طريق النور')),
   pw.Text(type=='يومي'?'جدول المتابعة اليومي':type=='أسبوعي'?'التقرير الأسبوعي':'التقييم الشهري'),
   pw.Table.fromTextArray(headers:['م','الاسم','الحضور','الحفظ','الحديث','التقدير'],data:s.students.asMap().entries.map((e){final st=e.value;final r=s.forStudent(st.id!);return ['${e.key+1}',st.name,'${StudentStats.attendance(r).toStringAsFixed(0)}%','${StudentStats.memorization(st,r).toStringAsFixed(1)}%',r.map((x)=>x.hadith).where((x)=>x.isNotEmpty).join('، '),StudentStats.gradeLabel(StudentStats.averageGrade(r))];}).toList()),
   pw.SizedBox(height:20),pw.Text('اللهم اجعل القرآن ربيع قلوبنا ونور صدورنا وذكرنا في الدنيا والآخرة'),
  ]));
  final Uint8List bytes=await doc.save();
  await Printing.sharePdf(bytes:bytes,filename:'tariq_al_noor_report.pdf');
 }
}
