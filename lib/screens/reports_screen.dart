import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:intl/intl.dart';
import '../data/app_store.dart';
import '../data/calculations.dart';
import '../data/pdf_arabic_font.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {const ReportsScreen({super.key});@override State<ReportsScreen> createState()=>_ReportsScreenState();}
class _ReportsScreenState extends State<ReportsScreen>{
 String type='يومي';DateTime selectedDate=DateTime.now();
 String get dayKey=>DateFormat('yyyy-MM-dd').format(selectedDate);
 List<dynamic> _filtered(AppStore s){
  final start=DateTime(selectedDate.year,selectedDate.month,selectedDate.day);DateTime from=start,to=start.add(const Duration(days:1));
  if(type=='أسبوعي'){from=start.subtract(Duration(days:start.weekday-1));to=from.add(const Duration(days:7));}
  if(type=='شهري'){from=DateTime(start.year,start.month,1);to=DateTime(start.year,start.month+1,1);}
  final ids=s.students.map((e)=>e.id).toSet();
  return s.records.where((r)=>ids.contains(r.studentId)&&!DateTime.parse(r.date).isBefore(from)&&DateTime.parse(r.date).isBefore(to)).toList()..sort((a,b)=>a.date.compareTo(b.date));
 }
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();final rows=_filtered(s);final grouped=<int,List<dynamic>>{};
  for(final r in rows){grouped.putIfAbsent(r.studentId,()=>[]).add(r);}
  return ListView(padding:const EdgeInsets.all(16),children:[
   const Text('التقارير والمتابعة',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:12),
   SegmentedButton<String>(segments:const [ButtonSegment(value:'يومي',label:Text('يومي')),ButtonSegment(value:'أسبوعي',label:Text('أسبوعي')),ButtonSegment(value:'شهري',label:Text('شهري'))],selected:{type},onSelectionChanged:(v)=>setState(()=>type=v.first)),
   ListTile(title:Text('الفترة: $dayKey'),trailing:IconButton(icon:const Icon(Icons.calendar_month),onPressed:()async{final d=await showDatePicker(context:context,initialDate:selectedDate,firstDate:DateTime(2020),lastDate:DateTime(2100));if(d!=null)setState(()=>selectedDate=d);})),
   Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
    Text(s.selected?.name??'طريق النور',style:const TextStyle(color:AppTheme.gold,fontSize:22,fontWeight:FontWeight.bold)),
    Text(type=='يومي'?'تقرير يوم $dayKey':type=='أسبوعي'?'التقرير الأسبوعي':'التقرير الشهري'),
    Text(s.selected?.section=='Women & Girls'?'نسائي':'رجالي'),const Divider(),
    Text('عدد الطلاب المسجل لهم في الفترة: ${grouped.length} • عدد السجلات: ${rows.length}'),
    ...s.students.where((st)=>grouped.containsKey(st.id)).map((st){final rr=grouped[st.id]!;final present=rr.where((r)=>r.present).length;return ListTile(dense:true,title:Text(st.name),subtitle:Text('أيام الحضور: $present من ${rr.length} • الحفظ: ${rr.fold<double>(0,(v,r)=>v+r.newPages).toStringAsFixed(1)} وجه • آخر تسجيل: ${rr.last.date}'),trailing:Text(StudentStats.gradeLabel(StudentStats.averageGrade(rr))));}),
    if(rows.isEmpty)const Padding(padding:EdgeInsets.all(16),child:Text('لا توجد سجلات في الفترة المحددة بعد.')),
    const Divider(),const Text('اللهم اجعل القرآن ربيع قلوبنا ونور صدورنا وذكرنا في الدنيا والآخرة',textAlign:TextAlign.center),
    const SizedBox(height:12),FilledButton.icon(onPressed:rows.isEmpty?null:()=>_exportPdf(s,rows),icon:const Icon(Icons.picture_as_pdf),label:const Text('تصدير PDF')),
    const SizedBox(height:8),OutlinedButton.icon(onPressed:rows.isEmpty?null:()=>_exportPng(s,rows),icon:const Icon(Icons.image_outlined),label:const Text('تصدير صفحات التقرير كصور PNG')),
   ]))),
  ]);
 }
 String _periodTitle()=>type=='يومي'?'التقرير اليومي - $dayKey':type=='أسبوعي'?'التقرير الأسبوعي':'التقرير الشهري - ${DateFormat('yyyy-MM').format(selectedDate)}';
 Future<Uint8List> _buildPdf(AppStore s,List<dynamic> rows) async{
  final font=loadArabicPdfFont();final doc=pw.Document();
  try{
   pw.Widget cell(String v,{bool header=false})=>pw.Padding(padding:const pw.EdgeInsets.all(5),child:arabicPdfText(v,font,size:header?10:9));
   final cells=<pw.TableRow>[];
   cells.add(pw.TableRow(decoration:const pw.BoxDecoration(color:PdfColors.blueGrey),children:['التاريخ','الطالب','الحضور','الحفظ الجديد','المراجعة','الشيخ'].map((v)=>cell(v,header:true)).toList()));
   for(final r in rows){final st=s.students.firstWhere((x)=>x.id==r.studentId);cells.add(pw.TableRow(children:[r.date,st.name,r.present?'حاضر':'غائب',r.newMemorization,r.review,r.teacherName].map((v)=>cell(v.isEmpty?'—':v)).toList()));}
   doc.addPage(pw.MultiPage(pageFormat:const PdfPageFormat(842,595),margin:const pw.EdgeInsets.all(26),footer:(c)=>pw.Align(alignment:pw.Alignment.center,child:arabicPdfText('طريق النور • صفحة ${c.pageNumber} من ${c.pagesCount}',font,size:9)),build:(c)=>[
    pw.Align(alignment:pw.Alignment.center,child:arabicPdfText(s.selected?.name??'طريق النور',font,size:22)),
    pw.SizedBox(height:6),pw.Align(alignment:pw.Alignment.center,child:arabicPdfText(_periodTitle(),font,size:16)),
    pw.SizedBox(height:12),arabicPdfText('عدد السجلات: ${rows.length} • عدد الطلاب: ${rows.map((r)=>r.studentId).toSet().length}',font,size:11),
    pw.SizedBox(height:10),pw.Table(border:pw.TableBorder.all(color:PdfColors.grey,width:.5),columnWidths:{0:const pw.FlexColumnWidth(1.2),1:const pw.FlexColumnWidth(1.5),2:const pw.FlexColumnWidth(.8),3:const pw.FlexColumnWidth(2),4:const pw.FlexColumnWidth(2),5:const pw.FlexColumnWidth(1.2)},children:cells),
    pw.SizedBox(height:16),arabicPdfText('اللهم اجعل القرآن ربيع قلوبنا ونور صدورنا وذكرنا في الدنيا والآخرة',font,size:12),
   ]));
   return await doc.save();
  }finally{font.dispose();}
 }
 Future<void> _exportPdf(AppStore s,List<dynamic> rows)async=>Printing.sharePdf(bytes:await _buildPdf(s,rows),filename:'tariq_al_noor_report.pdf');
 Future<void> _exportPng(AppStore s,List<dynamic> rows)async{
  final bytes=await _buildPdf(s,rows);final pages=await Printing.raster(bytes,dpi:160).toList();final files=<XFile>[];
  for(var i=0;i<pages.length;i++){files.add(XFile.fromData(await pages[i].toPng(),name:'tariq_al_noor_report_page_${i+1}.png',mimeType:'image/png'));}
  if(files.isNotEmpty)await Share.shareXFiles(files,text:'${_periodTitle()} - طريق النور');
 }
}
