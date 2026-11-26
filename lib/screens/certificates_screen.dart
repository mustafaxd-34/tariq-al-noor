import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';

class CertificatesScreen extends StatefulWidget {const CertificatesScreen({super.key});@override State<CertificatesScreen> createState()=>_CertificatesScreenState();}
class _CertificatesScreenState extends State<CertificatesScreen>{
 final name=TextEditingController(),body=TextEditingController(text:'تتشرف إدارة الدار بمنح هذه الشهادة تقديراً لتميزه واجتهاده في حفظ كتاب الله تعالى.');
 final title=TextEditingController(text:'شهادة تقدير');
 String kind='شهادة تقدير',riwaya='حفص عن عاصم';int design=0;
 final colors=[0xFF075B49,0xFF102B50,0xFF6B2338,0xFF176B70,0xFF5A4320,0xFF35265D];
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();
  return ListView(padding:const EdgeInsets.all(16),children:[
   const Text('استوديو الشهادات',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
   const SizedBox(height:12),DropdownButtonFormField<String>(value:kind,decoration:const InputDecoration(labelText:'نوع الشهادة'),items:const [DropdownMenuItem(value:'شهادة تقدير',child:Text('شهادة تقدير')),DropdownMenuItem(value:'إجازة حفظ القرآن الكريم',child:Text('إجازة حفظ القرآن الكريم'))],onChanged:(v)=>setState(()=>kind=v??kind)),
   const SizedBox(height:12),TextField(controller:title,decoration:const InputDecoration(labelText:'عنوان الشهادة')),
   const SizedBox(height:12),TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الطالب / الطالبة')),
   if(kind.startsWith('إجازة'))DropdownButtonFormField<String>(value:riwaya,decoration:const InputDecoration(labelText:'الرواية'),items:const [DropdownMenuItem(value:'حفص عن عاصم',child:Text('حفص عن عاصم')),DropdownMenuItem(value:'ورش عن نافع',child:Text('ورش عن نافع')),DropdownMenuItem(value:'قالون عن نافع',child:Text('قالون عن نافع'))],onChanged:(v)=>setState(()=>riwaya=v??riwaya)),
   const SizedBox(height:12),TextField(controller:body,maxLines:4,decoration:const InputDecoration(labelText:'نص الشهادة')),
   const SizedBox(height:16),const Text('اختر من 30 قالباً زخرفياً'),
   SizedBox(height:94,child:ListView(scrollDirection:Axis.horizontal,children:List.generate(30,(i)=>GestureDetector(onTap:()=>setState(()=>design=i),child:Container(width:105,margin:const EdgeInsetsDirectional.only(end:8),decoration:BoxDecoration(color:Color(colors[i%colors.length]),borderRadius:BorderRadius.circular(12),border:Border.all(color:design==i?AppTheme.gold:Colors.white24,width:design==i?3:1)),child:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.mosque,color:AppTheme.gold),Text('تصميم ${i+1}',style:const TextStyle(fontSize:12))])))))),
   const SizedBox(height:16),Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Color(colors[design%colors.length]),border:Border.all(color:AppTheme.gold,width:3),borderRadius:BorderRadius.circular(18)),child:Column(children:[const Icon(Icons.auto_awesome,color:AppTheme.gold,size:32),Text(s.selected?.name??'دار التوحيد',style:const TextStyle(color:AppTheme.gold)),Text(title.text.isEmpty?kind:title.text,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold),textAlign:TextAlign.center),const SizedBox(height:8),Text(name.text.isEmpty?'اسم الطالب':name.text,style:const TextStyle(fontSize:22,color:AppTheme.gold)),Text(body.text,textAlign:TextAlign.center),if(kind.startsWith('إجازة'))Text('الرواية: $riwaya'),const SizedBox(height:15),const Text('الشيخ / الشيخة • التوقيع') ])),
   const SizedBox(height:16),FilledButton.icon(onPressed:()=>_export(s),icon:const Icon(Icons.picture_as_pdf),label:const Text('تصدير الشهادة PDF')),
  ]);
 }
 Future<void> _export(AppStore s)async{
  final doc=pw.Document();doc.addPage(pw.Page(pageFormat:const pw.PdfPageFormat(842,595),build:(c)=>pw.Container(padding:const pw.EdgeInsets.all(35),decoration:pw.BoxDecoration(border:pw.Border.all(color:const PdfColor(0.76,0.62,0.28),width:5)),child:pw.Center(child:pw.Column(mainAxisAlignment:pw.MainAxisAlignment.center,children:[pw.Text(s.selected?.name??'طريق النور'),pw.SizedBox(height:25),pw.Text(title.text.isEmpty?kind:title.text,style:pw.TextStyle(fontSize:30,fontWeight:pw.FontWeight.bold)),pw.SizedBox(height:25),pw.Text(name.text,style:const pw.TextStyle(fontSize:25)),pw.SizedBox(height:20),pw.Text(body.text,textAlign:pw.TextAlign.center,style:const pw.TextStyle(fontSize:18)),if(kind.startsWith('إجازة'))pw.Text('الرواية: $riwaya'),pw.SizedBox(height:35),pw.Text('الشيخ / الشيخة • ${DateTime.now().toIso8601String().substring(0,10)}')]))));
  await Printing.sharePdf(bytes:await doc.save(),filename:'tariq_al_noor_certificate.pdf');
 }
}
