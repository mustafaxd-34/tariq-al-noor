import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_store.dart';
import '../models/entities.dart';

class SessionScreen extends StatefulWidget {const SessionScreen({super.key});@override State<SessionScreen> createState()=>_SessionScreenState();}
class _SessionScreenState extends State<SessionScreen>{
 DateTime date=DateTime.now();
 final drafts=<String,Map<String,dynamic>>{};
 final controllers=<String,TextEditingController>{};
 String get dateKey=>date.toIso8601String().substring(0,10);
 String _key(int id,String field)=>'$dateKey:$id:$field';
 TextEditingController _controller(int id,String field,String initial)=>controllers.putIfAbsent(_key(id,field),()=>TextEditingController(text:initial));
 @override void dispose(){for(final c in controllers.values){c.dispose();}super.dispose();}
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();
  return Column(children:[
   Padding(padding:const EdgeInsets.all(14),child:Row(children:[Expanded(child:Text('تسجيل الحلقة: $dateKey',style:const TextStyle(fontWeight:FontWeight.bold))),IconButton(onPressed:()async{final d=await showDatePicker(context:context,initialDate:date,firstDate:DateTime(2020),lastDate:DateTime(2100));if(d!=null)setState(()=>date=d);},icon:const Icon(Icons.calendar_month))])),
   Expanded(child:s.students.isEmpty?const Center(child:Text('أضف الطلاب أولاً من شاشة الطلاب')):ListView(children:s.students.map((st){
    final matches=s.records.where((r)=>r.studentId==st.id&&r.date==dateKey).toList();final old=matches.isEmpty?null:matches.first;
    final data=drafts.putIfAbsent(_key(st.id!,'draft'),()=>{'present':old?.present??true,'new':old?.newMemorization??'','review':old?.review??'','hadith':old?.hadith??'','pages':'${old?.newPages??0}','grade':old?.grade??3,'jaz':old?.jazariyya??'','tuhfa':old?.tuhfa??'','notes':old?.notes??''});
    return Card(margin:const EdgeInsets.symmetric(horizontal:12,vertical:5),child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Row(children:[Expanded(child:Text(st.name,style:const TextStyle(fontWeight:FontWeight.bold))),Switch(value:data['present'] as bool,onChanged:(v)=>setState(()=>data['present']=v)),Text((data['present'] as bool)?'حاضر':'غائب')]),
     if(data['present'] as bool)...[
      _field(st.id!,'new',data,'new','الحفظ الجديد'),_field(st.id!,'review',data,'review','المراجعة'),_field(st.id!,'hadith',data,'hadith','الحديث'),
      if(s.selected?.section=='Men & Boys')...[_field(st.id!,'jaz',data,'jaz','الجزرية'),_field(st.id!,'tuhfa',data,'tuhfa','التحفة')],
      TextField(controller:_controller(st.id!,'pages',data['pages'].toString()),keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'أوجه جديدة'),onChanged:(v)=>data['pages']=v),
      _field(st.id!,'notes',data,'notes','ملاحظات الشيخ'),
      DropdownButtonFormField<int>(value:data['grade'] as int,decoration:const InputDecoration(labelText:'التقدير'),items:const [DropdownMenuItem(value:4,child:Text('ممتاز')),DropdownMenuItem(value:3,child:Text('جيد جداً')),DropdownMenuItem(value:2,child:Text('جيد')),DropdownMenuItem(value:1,child:Text('مقبول'))],onChanged:(v)=>setState(()=>data['grade']=v??3))
     ],
     Align(alignment:AlignmentDirectional.centerEnd,child:TextButton.icon(onPressed:()=>_save(s,st,data),icon:const Icon(Icons.save),label:const Text('حفظ سجل الطالب'))),
    ])));
   }).toList())),
   Padding(padding:const EdgeInsets.all(12),child:FilledButton.icon(onPressed:()async{for(final st in s.students){final data=drafts[_key(st.id!,'draft')];if(data!=null)await _save(s,st,data,notify:false);}await s.refresh();if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ سجلات الحلقة')));},icon:const Icon(Icons.done_all),label:const Text('حفظ الحلقة للجميع'))),
  ]);
 }
 Widget _field(int id,String controllerKey,Map<String,dynamic> data,String field,String label)=>Padding(padding:const EdgeInsets.only(top:8),child:TextField(controller:_controller(id,controllerKey,data[field]??''),decoration:InputDecoration(labelText:label),onChanged:(v)=>data[field]=v));
 Future<void> _save(AppStore s,Student st,Map<String,dynamic> d,{bool notify=true}) async {
  final teacher=await s.setting('sheikh_name');
  await s.saveRecord(DailyRecord(studentId:st.id!,date:dateKey,present:d['present'] as bool,newMemorization:d['new']??'',review:d['review']??'',hadith:d['hadith']??'',jazariyya:d['jaz']??'',tuhfa:d['tuhfa']??'',newPages:double.tryParse(d['pages'].toString())??0,grade:d['grade'] as int,notes:d['notes']??'',teacherName:teacher));
  if(notify&&mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ سجل الطالب')));
 }
}
