import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {const SettingsScreen({super.key});@override State<SettingsScreen> createState()=>_SettingsScreenState();}
class _SettingsScreenState extends State<SettingsScreen>{
 final sheikh=TextEditingController(),teacher=TextEditingController(),inst=TextEditingController();String section='Men & Boys';bool showTeacher=false;
 @override Widget build(BuildContext context){
  final s=context.watch<AppStore>();
  return ListView(padding:const EdgeInsets.all(16),children:[
   const Text('الإعدادات وإدارة المؤسسات',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
   Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[
    TextField(controller:sheikh,decoration:const InputDecoration(labelText:'اسم الشيخ / الشيخة'),onChanged:(v)=>s.saveSetting('sheikh_name',v)),
    TextField(controller:teacher,decoration:const InputDecoration(labelText:'اسم المعلم / المعلمة'),onChanged:(v)=>s.saveSetting('teacher_name',v)),
    SwitchListTile(title:const Text('إظهار اسم المعلم في التقارير والشهادات'),value:showTeacher,onChanged:(v){setState(()=>showTeacher=v);s.saveSetting('show_teacher','$v');}),
   ]))),
   const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('إضافة مؤسسة',style:TextStyle(fontWeight:FontWeight.bold,color:AppTheme.gold)),
    TextField(controller:inst,decoration:const InputDecoration(labelText:'اسم المسجد / الدار')),
    DropdownButtonFormField<String>(value:section,decoration:const InputDecoration(labelText:'القسم'),items:const [DropdownMenuItem(value:'Men & Boys',child:Text('رجالي – رجال وفتيان')),DropdownMenuItem(value:'Women & Girls',child:Text('نسائي – نساء وفتيات'))],onChanged:(v)=>setState(()=>section=v??section)),
    const SizedBox(height:8),FilledButton(onPressed:()async{if(inst.text.trim().isNotEmpty){await s.addInstitution(inst.text.trim(),section);inst.clear();}},child:const Text('إضافة المؤسسة')),
   ]))),
   const SizedBox(height:12),const Text('المؤسسات الحالية',style:TextStyle(color:AppTheme.gold,fontWeight:FontWeight.bold)),
   ...s.institutions.map((e)=>Card(child:ListTile(title:Text(e.name),subtitle:Text(e.section=='Women & Girls'?'نسائي':'رجالي'),trailing:IconButton(icon:const Icon(Icons.delete_outline,color:Colors.redAccent),onPressed:()=>showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('حذف المؤسسة؟'),content:const Text('سيتم حذف الطلاب والسجلات التابعة لها نهائياً.'),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('إلغاء')),FilledButton(onPressed:()async{Navigator.pop(c);await s.deleteInstitution(e.id!);},child:const Text('حذف'))])))))),
   const SizedBox(height:12),const Card(child:ListTile(leading:Icon(Icons.schedule,color:AppTheme.gold),title:Text('مواعيد الحلقات الافتراضية'),subtitle:Text('رجالي: السبت والاثنين والأربعاء 2–9 مساءً\\nنسائي: الأحد والثلاثاء والخميس 2–6 مساءً'))),
   const Card(child:ListTile(leading:Icon(Icons.backup,color:AppTheme.gold),title:Text('النسخ الاحتياطي'),subtitle:Text('قاعدة البيانات محفوظة محلياً على الجهاز. استخدم نسخ الجهاز الاحتياطي لحمايتها.'))),
  ]);
 }
}
