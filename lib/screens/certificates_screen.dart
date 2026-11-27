import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../data/app_store.dart';
import '../data/pdf_arabic_font.dart';
import '../theme/app_theme.dart';

class CertificatesScreen extends StatefulWidget {const CertificatesScreen({super.key});@override State<CertificatesScreen> createState()=>_CertificatesScreenState();}
class _CertificatesScreenState extends State<CertificatesScreen>{
 final name=TextEditingController();final body=TextEditingController(text:'تتشرف إدارة الدار بمنح هذه الشهادة تقديراً لتميزه واجتهاده في حفظ كتاب الله تعالى.');final title=TextEditingController(text:'شهادة تقدير');
 String kind='شهادة تقدير',riwaya='حفص عن عاصم';int design=0;
 final colors=[0xFF075B49,0xFF102B50,0xFF6B2338,0xFF176B70,0xFF5A4320,0xFF35265D];
 @override void dispose(){name.dispose();body.dispose();title.dispose();super.dispose();}
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();
  return ListView(padding:const EdgeInsets.all(16),children:[
   const Text('استوديو الشهادات',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:12),
   DropdownButtonFormField<String>(value:kind,decoration:const InputDecoration(labelText:'نوع الشهادة'),items:const [DropdownMenuItem(value:'شهادة تقدير',child:Text('شهادة تقدير')),DropdownMenuItem(value:'إجازة حفظ القرآن الكريم',child:Text('إجازة حفظ القرآن الكريم'))],onChanged:(v)=>setState(()=>kind=v??kind)),
   const SizedBox(height:12),TextField(controller:title,onChanged:(_)=>setState((){}),decoration:const InputDecoration(labelText:'عنوان الشهادة')),
   const SizedBox(height:12),TextField(controller:name,onChanged:(_)=>setState((){}),decoration:const InputDecoration(labelText:'اسم الطالب / الطالبة')),
   if(kind.startsWith('إجازة'))DropdownButtonFormField<String>(value:riwaya,decoration:const InputDecoration(labelText:'الرواية'),items:const [DropdownMenuItem(value:'حفص عن عاصم',child:Text('حفص عن عاصم')),DropdownMenuItem(value:'ورش عن نافع',child:Text('ورش عن نافع')),DropdownMenuItem(value:'قالون عن نافع',child:Text('قالون عن نافع'))],onChanged:(v)=>setState(()=>riwaya=v??riwaya)),
   const SizedBox(height:12),TextField(controller:body,maxLines:4,onChanged:(_)=>setState((){}),decoration:const InputDecoration(labelText:'نص الشهادة')),
   const SizedBox(height:16),const Text('اختر التصميم'),
   SizedBox(height:94,child:ListView(scrollDirection:Axis.horizontal,children:List.generate(30,(i)=>GestureDetector(onTap:()=>setState(()=>design=i),child:Container(width:105,margin:const EdgeInsetsDirectional.only(end:8),decoration:BoxDecoration(color:Color(colors[i%colors.length]),borderRadius:BorderRadius.circular(12),border:Border.all(color:design==i?AppTheme.gold:Colors.white24,width:design==i?3:1)),child:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.mosque,color:AppTheme.gold),Text('تصميم ${i+1}',style:const TextStyle(fontSize:12))]))))))),
   const SizedBox(height:16),Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Color(colors[design%colors.length]),border:Border.all(color:AppTheme.gold,width:3),borderRadius:BorderRadius.circular(18)),child:Column(children:[const Icon(Icons.auto_awesome,color:AppTheme.gold,size:32),Text(s.selected?.name??'دار التوحيد',style:const TextStyle(color:AppTheme.gold)),Text(title.text.isEmpty?kind:title.text,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold),textAlign:TextAlign.center),const SizedBox(height:8),Text(name.text.isEmpty?'اسم الطالب':name.text,style:const TextStyle(fontSize:22,color:AppTheme.gold)),Text(body.text,textAlign:TextAlign.center),if(kind.startsWith('إجازة'))Text('الرواية: $riwaya'),const SizedBox(height:15),const Text('الشيخ / الشيخة • التوقيع')])),
   const SizedBox(height:16),FilledButton.icon(onPressed:()=>_exportPdf(s),icon:const Icon(Icons.picture_as_pdf),label:const Text('تصدير الشهادة PDF')),
   const SizedBox(height:8),OutlinedButton.icon(onPressed:()=>_exportPng(s),icon:const Icon(Icons.image_outlined),label:const Text('تصدير الشهادة PNG')),
  ]);
 }
 Future<Uint8List> _buildPdf(AppStore s)async{
  final font=loadArabicPdfFont();final doc=pw.Document();final palette=[PdfColor.fromInt(0xFF075B49),PdfColor.fromInt(0xFF102B50),PdfColor.fromInt(0xFF6B2338),PdfColor.fromInt(0xFF176B70),PdfColor.fromInt(0xFF5A4320),PdfColor.fromInt(0xFF35265D)];
  try{
   doc.addPage(pw.Page(pageFormat:const PdfPageFormat(842,595),margin:const pw.EdgeInsets.all(22),build:(c)=>pw.Container(padding:const pw.EdgeInsets.all(30),decoration:pw.BoxDecoration(color:palette[design%palette.length],border:pw.Border.all(color:const PdfColor(0.89,0.77,0.43),width:6)),child:pw.Container(padding:const pw.EdgeInsets.all(20),decoration:pw.BoxDecoration(border:pw.Border.all(color:const PdfColor(0.89,0.77,0.43),width:1.5)),child:pw.Column(mainAxisAlignment:pw.MainAxisAlignment.center,children:[
    arabicPdfText('۞ طريق النور ۞',font,size:17),pw.SizedBox(height:18),arabicPdfText(s.selected?.name??'طريق النور',font,size:15),pw.SizedBox(height:18),
    arabicPdfText(title.text.isEmpty?kind:title.text,font,size:30),pw.SizedBox(height:22),arabicPdfText(name.text,font,size:27),pw.SizedBox(height:18),arabicPdfText(body.text,font,size:17),
    if(kind.startsWith('إجازة'))... [pw.SizedBox(height:10),arabicPdfText('الرواية: $riwaya',font,size:15)],
    pw.SizedBox(height:25),arabicPdfText('الشيخ / الشيخة • ${DateTime.now().toIso8601String().substring(0,10)}',font,size:12),
   ]))));
   return await doc.save();
  }finally{font.dispose();}
 }
 Future<void> _exportPdf(AppStore s)async=>Printing.sharePdf(bytes:await _buildPdf(s),filename:'tariq_al_noor_certificate.pdf');
 Future<void> _exportPng(AppStore s)async{final bytes=await _buildPdf(s);final page=await Printing.raster(bytes,pages:[0],dpi:200).first;await Share.shareXFiles([XFile.fromData(await page.toPng(),name:'tariq_al_noor_certificate.png',mimeType:'image/png')],text:'شهادة من تطبيق طريق النور');}
}
