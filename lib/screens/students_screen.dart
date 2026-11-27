import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_store.dart';
import '../data/calculations.dart';
import '../models/entities.dart';
import '../theme/app_theme.dart';

class StudentsScreen extends StatefulWidget {const StudentsScreen({super.key});@override State<StudentsScreen> createState()=>_StudentsScreenState();}
class _StudentsScreenState extends State<StudentsScreen>{
 final search=TextEditingController();
 @override void dispose(){search.dispose();super.dispose();}
 Future<void> add(BuildContext context) async {
  final name=TextEditingController(),phone=TextEditingController(),pages=TextEditingController(text:'0'),guardian=TextEditingController(),guardianPhone=TextEditingController(),address=TextEditingController(),notes=TextEditingController();
  final store=context.read<AppStore>();
  if(store.selected==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف داراً أولاً من الإعدادات')));return;}
  final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('تسجيل طالب جديد'),content:SizedBox(width:420,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
   TextField(controller:name,decoration:const InputDecoration(labelText:'اسم الطالب *')),
   TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'رقم هاتف الطالب')),
   TextField(controller:guardian,decoration:const InputDecoration(labelText:'اسم ولي الأمر')),
   TextField(controller:guardianPhone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'هاتف ولي الأمر للتواصل')),
   TextField(controller:address,decoration:const InputDecoration(labelText:'العنوان / المنطقة')),
   TextField(controller:pages,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'صفحات محفوظة سابقاً')),
   TextField(controller:notes,maxLines:2,decoration:const InputDecoration(labelText:'ملاحظات عن الطالب')),
  ]))),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('حفظ الملف'))]));
  if(ok==true&&name.text.trim().isNotEmpty){await store.addStudent(Student(institutionId:store.selected!.id!,name:name.text.trim(),phone:phone.text.trim().isEmpty?null:phone.text.trim(),joinDate:DateTime.now().toIso8601String().substring(0,10),pagesBefore:double.tryParse(pages.text)??0,guardianName:guardian.text.trim(),guardianPhone:guardianPhone.text.trim(),address:address.text.trim(),notes:notes.text.trim()));}
 }
 void showStudentFile(BuildContext context,Student st){
  final store=context.read<AppStore>();final rows=store.forStudent(st.id!);
  showDialog(context:context,builder:(c)=>AlertDialog(title:Text('ملف الطالب: ${st.name}'),content:SizedBox(width:460,child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
   _line('الدار',store.institutions.where((x)=>x.id==st.institutionId).firstOrNull?.name??'غير محدد'),
   _line('تاريخ التسجيل',st.joinDate),_line('هاتف الطالب',st.phone??'غير مسجل'),_line('ولي الأمر',st.guardianName.isEmpty?'غير مسجل':st.guardianName),_line('هاتف ولي الأمر',st.guardianPhone.isEmpty?'غير مسجل':st.guardianPhone),_line('العنوان',st.address.isEmpty?'غير مسجل':st.address),_line('ملاحظات',st.notes.isEmpty?'لا توجد':st.notes),
   const Divider(),Text('السجل التاريخي • ${rows.length} يوم مسجل',style:const TextStyle(fontWeight:FontWeight.bold,color:AppTheme.gold)),
   ...rows.reversed.take(20).map((r)=>ListTile(dense:true,contentPadding:EdgeInsets.zero,title:Text(r.date),subtitle:Text('الحفظ: ${r.newMemorization.isEmpty?'—':r.newMemorization} • المراجعة: ${r.review.isEmpty?'—':r.review}'),trailing:Text(r.present?'حاضر':'غائب'))),
   if(rows.isEmpty) const Text('لم يتم تسجيل حلقات لهذا الطالب حتى الآن.'),
  ]))),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('إغلاق'))]));
 }
 Widget _line(String k,String v)=>Padding(padding:const EdgeInsets.symmetric(vertical:3),child:Text('$k: $v'));
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();final list=s.students.where((x)=>x.name.contains(search.text)).toList();
  return Column(children:[
   Padding(padding:const EdgeInsets.all(16),child:Row(children:[Expanded(child:TextField(controller:search,onChanged:(_)=>setState((){}),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'ابحث عن طالب'))),const SizedBox(width:8),FilledButton.icon(onPressed:()=>add(context),icon:const Icon(Icons.person_add),label:const Text('إضافة'))])),
   Expanded(child:s.selected==null?const Center(child:Text('ابدأ بإضافة دار من الإعدادات')):list.isEmpty?const Center(child:Text('لا يوجد طلاب بعد')):ListView.builder(itemCount:list.length,itemBuilder:(c,i){
    final student=list[i],rows=s.forStudent(list[i].id!);final attendance=StudentStats.attendance(rows),memorization=StudentStats.memorization(student,rows),avg=StudentStats.averageGrade(rows);
    return Card(margin:const EdgeInsets.symmetric(horizontal:14,vertical:5),child:ListTile(onTap:()=>showStudentFile(context,student),leading:CircleAvatar(backgroundColor:AppTheme.gold,child:Text('${i+1}',style:const TextStyle(color:AppTheme.deep))),title:Text(student.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:8),Text('الحضور ${attendance.toStringAsFixed(1)}% • الحفظ ${memorization.toStringAsFixed(1)}%'),Text('ولي الأمر: ${student.guardianName.isEmpty?'غير مسجل':student.guardianName} • ${student.guardianPhone.isEmpty?'لا يوجد رقم':student.guardianPhone}'),const SizedBox(height:5),LinearProgressIndicator(value:memorization/100,color:AppTheme.gold,backgroundColor:Colors.white24),Text('التقدير: ${StudentStats.gradeLabel(avg)} • اضغط لفتح ملف الطالب')]),trailing:IconButton(icon:const Icon(Icons.delete_outline,color:Colors.redAccent),onPressed:()=>showDialog(context:context,builder:(d)=>AlertDialog(title:const Text('حذف الطالب؟'),content:Text('سيتم حذف سجلات ${student.name} أيضاً.'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('إلغاء')),FilledButton(onPressed:()async{Navigator.pop(d);await s.deleteStudent(student.id!);},child:const Text('حذف'))])))));
   })),
  ]);
 }
}
