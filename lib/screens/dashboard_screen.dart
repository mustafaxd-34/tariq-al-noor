import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
 const DashboardScreen({super.key});
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();final today=DateFormat('yyyy-MM-dd').format(DateTime.now());
  final ids=s.students.map((x)=>x.id).toSet();
  final todayRows=s.records.where((r)=>ids.contains(r.studentId)&&r.date==today).toList();
  final present=todayRows.where((r)=>r.present).length;final absent=todayRows.length-present;
  return ListView(padding:const EdgeInsets.all(16),children:[
   Text('لوحة متابعة الدار',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),
   const SizedBox(height:6),Text('${s.selected?.name??'اختر داراً أو أضف داراً جديدة'} • $today',style:const TextStyle(color:AppTheme.gold)),
   const SizedBox(height:16),
   GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,childAspectRatio:1.65,crossAxisSpacing:10,mainAxisSpacing:10,children:[
    _tile('إجمالي الطلاب','${s.students.length}',Icons.people),
    _tile('سجلات اليوم','${todayRows.length}',Icons.fact_check),
    _tile('حاضر اليوم','$present',Icons.check_circle_outline),
    _tile('غياب اليوم','$absent',Icons.event_busy),
   ]),
   const SizedBox(height:18),const Text('آخر التسجيلات',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:AppTheme.gold)),
   const SizedBox(height:8),
   ...todayRows.reversed.take(8).map((r){final st=s.students.where((x)=>x.id==r.studentId).firstOrNull;return Card(child:ListTile(leading:Icon(r.present?Icons.check_circle:Icons.cancel,color:r.present?Colors.green:Colors.redAccent),title:Text(st?.name??'طالب غير موجود'),subtitle:Text('الحفظ: ${r.newMemorization.isEmpty?'—':r.newMemorization} • الشيخ: ${r.teacherName.isEmpty?'غير محدد':r.teacherName}'),trailing:Text(r.date)));}),
   if(todayRows.isEmpty) const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('لسه مفيش تسجيلات لليوم. افتح شاشة الحلقة وسجّل الطلاب.'))),
   const SizedBox(height:12),const Text('الدور والمؤسسات',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:AppTheme.gold)),
   ...s.institutions.map((i)=>Card(child:ListTile(leading:const Icon(Icons.mosque),title:Text(i.name),subtitle:Text(i.section=='Women & Girls'?'قسم النساء والفتيات':'قسم الرجال والفتيان'),trailing:Text('${s.students.where((x)=>x.institutionId==i.id).length} طالب')))),
  ]);
 }
 Widget _tile(String label,String value,IconData icon)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[Icon(icon,color:AppTheme.gold,size:28),const SizedBox(width:10),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:12)),Text(value,style:const TextStyle(fontSize:23,fontWeight:FontWeight.bold))]))])));
}
