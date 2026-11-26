import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_store.dart';
import '../models/entities.dart';
import '../theme/app_theme.dart';

class SessionScreen extends StatefulWidget {const SessionScreen({super.key});@override State<SessionScreen> createState()=>_SessionScreenState();}
class _SessionScreenState extends State<SessionScreen>{
 DateTime date=DateTime.now(); final drafts=<int,Map<String,dynamic>>{};
 String get dateKey=>date.toIso8601String().substring(0,10);
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();
  return Column(children:[
   Padding(padding:const EdgeInsets.all(14),child:Row(children:[Expanded(child:Text('تسجيل الحلقة: $dateKey',style:const TextStyle(fontWeight:FontWeight.bold))),IconButton(onPressed:()async{final d=await showDatePicker(context:context,initialDate:date,firstDate:DateTime(2020),lastDate:DateTime(2100));if(d!=null)setState(()=>date=d);},icon:const Icon(Icons.calendar_month))])),
   Expanded(child:ListView(children:s.students.map((st){
    final matches=s.records.where((r)=>r.studentId==st.id&&r.date==dateKey).toList();
    final old=matches.isEmpty?null:matches.first;
    final data=drafts.putIfAbsent(st.id!,()=>{'present':old?.present??true,'new':'${old?.newMemorization??''}','review':'${old?.review??''}','hadith':'${old?.hadith??''}','pages':'${old?.newPages??0}','grade':old?.grade??3,'jaz':'${old?.jazariyya??''}','tuhfa':'${old?.tuhfa??''}'});
    return Card(margin:const EdgeInsets.symmetric(horizontal:12,vertical:5),child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Row(children:[Expanded(child:Text(st.name,style:const TextStyle(fontWeight:FontWeight.bold))),Switch(value:data['present'] as bool,onChanged:(v)=>setState(()=>data['present']=v)),Text((data['present'] as bool)?'حاضر':'غائب')]),
     if(data['present'] as bool)...[
      _field(data,'new','الحفظ الجديد'),_field(data,'review','المراجعة'),_field(data,'hadith','الحديث'),
      if(s.selected?.section=='Men & Boys')...[_field(data,'jaz','الجزرية'),_field(data,'tuhfa','التحفة')],
      Row(children:[Expanded(child:TextField(controller:TextEditingController(text:data['pages'].toString()),keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'أوجه جديدة'),onChanged:(v)=>data['pages']=v)),const SizedBox(width:10),DropdownButton<int>(value:data['grade'] as int,items:const [DropdownMenuItem(value:4,child:Text('ممتاز')),DropdownMenuItem(value:3,child:Text('جيد جداً')),DropdownMenuItem(value:2,child:Text('جيد')),DropdownMenuItem(value:1,child:Text('مقبول'))],onChanged:(v)=>setState(()=>data['grade']=v??3))])
     ],
     Align(alignment:AlignmentDirectional.centerEnd,child:TextButton.icon(onPressed:()async{await s.saveRecord(DailyRecord(studentId:st.id!,date:dateKey,present:data['present'] as bool,newMemorization:data['new'],review:data['review'],hadith:data['hadith'],jazariyya:data['jaz'],tuhfa:data['tuhfa'],newPages:double.tryParse(data['pages'].toString())??0,grade:data['grade'] as int));if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ سجل الطالب')));},icon:const Icon(Icons.save),label:const Text('حفظ'))),
    ])));
   }).toList())),
   Padding(padding:const EdgeInsets.all(12),child:FilledButton.icon(onPressed:()async{for(final st in s.students){final d=drafts[st.id];if(d==null)continue;await s.saveRecord(DailyRecord(studentId:st.id!,date:dateKey,present:d['present'] as bool,newMemorization:d['new'],review:d['review'],hadith:d['hadith'],jazariyya:d['jaz'],tuhfa:d['tuhfa'],newPages:double.tryParse(d['pages'].toString())??0,grade:d['grade'] as int));}if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم تسجيل الحلقة لجميع الطلاب')));},icon:const Icon(Icons.done_all),label:const Text('حفظ الحلقة للجميع'))),
  ]);
 }
 Widget _field(Map<String,dynamic> d,String key,String label)=>Padding(padding:const EdgeInsets.only(top:8),child:TextField(controller:TextEditingController(text:d[key]),decoration:InputDecoration(labelText:label),onChanged:(v)=>d[key]=v));
}
