import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_store.dart';
import '../data/calculations.dart';
import '../models/entities.dart';
import '../theme/app_theme.dart';

class StudentsScreen extends StatefulWidget {const StudentsScreen({super.key});@override State<StudentsScreen> createState()=>_StudentsScreenState();}
class _StudentsScreenState extends State<StudentsScreen>{
 final search=TextEditingController();
 Future<void> add(BuildContext context) async {
  final name=TextEditingController(),phone=TextEditingController(),pages=TextEditingController(text:'0');
  final store=context.read<AppStore>();
  if(store.selected==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مؤسسة أولاً من الإعدادات')));return;}
  final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('تسجيل طالب'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الطالب')),TextField(controller:phone,decoration:const InputDecoration(labelText:'رقم الهاتف')),TextField(controller:pages,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'صفحات محفوظة سابقاً'))]),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('حفظ'))]));
  if(ok==true && name.text.trim().isNotEmpty){await store.addStudent(Student(institutionId:store.selected!.id!,name:name.text.trim(),phone:phone.text.trim().isEmpty?null:phone.text.trim(),joinDate:DateTime.now().toIso8601String().substring(0,10),pagesBefore:double.tryParse(pages.text)??0));}
 }
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();
  final list=s.students.where((x)=>x.name.contains(search.text)).toList();
  return Column(children:[
   Padding(padding:const EdgeInsets.all(16),child:Row(children:[Expanded(child:TextField(controller:search,onChanged:(_)=>setState((){}),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'ابحث عن طالب'))),const SizedBox(width:8),FilledButton.icon(onPressed:()=>add(context),icon:const Icon(Icons.person_add),label:const Text('إضافة'))])),
   Expanded(child:s.selected==null?const Center(child:Text('ابدأ بإضافة مؤسسة من الإعدادات')):list.isEmpty?const Center(child:Text('لا يوجد طلاب بعد')):ListView.builder(itemCount:list.length,itemBuilder:(c,i){
    final student=list[i], rows=s.forStudent(student.id!);
    final attendance=StudentStats.attendance(rows), memorization=StudentStats.memorization(student,rows), avg=StudentStats.averageGrade(rows);
    return Card(margin:const EdgeInsets.symmetric(horizontal:14,vertical:5),child:ListTile(leading:CircleAvatar(backgroundColor:AppTheme.gold,child:Text('${i+1}',style:const TextStyle(color:AppTheme.deep))),title:Text(student.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:8),Text('الحضور ${attendance.toStringAsFixed(1)}%  •  الحفظ ${memorization.toStringAsFixed(1)}%'),const SizedBox(height:5),LinearProgressIndicator(value:memorization/100,color:AppTheme.gold,backgroundColor:Colors.white24),Text('التقدير: ${StudentStats.gradeLabel(avg)}')]),trailing:IconButton(icon:const Icon(Icons.delete_outline,color:Colors.redAccent),onPressed:()=>showDialog(context:context,builder:(d)=>AlertDialog(title:const Text('حذف الطالب؟'),content:Text('سيتم حذف سجلات ${student.name} أيضاً.'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('إلغاء')),FilledButton(onPressed:()async{Navigator.pop(d);await s.deleteStudent(student.id!);},child:const Text('حذف'))])))));
   })),
  ]);
 }
}
