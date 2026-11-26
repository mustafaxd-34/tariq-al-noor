import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import 'students_screen.dart';
import 'session_screen.dart';
import 'reports_screen.dart';
import 'certificates_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {const HomeScreen({super.key});@override State<HomeScreen> createState()=>_HomeScreenState();}
class _HomeScreenState extends State<HomeScreen>{
 int index=0;
 final pages=const [StudentsScreen(),SessionScreen(),ReportsScreen(),CertificatesScreen(),SettingsScreen()];
 @override Widget build(BuildContext context){
  final store=context.watch<AppStore>();
  return Scaffold(
   appBar:AppBar(title:const Text('طريق النور',style:TextStyle(fontWeight:FontWeight.bold)),actions:[
    if(store.institutions.isNotEmpty) Padding(padding:const EdgeInsetsDirectional.only(end:12),child:DropdownButton<int>(underline:const SizedBox(),value:store.selected?.id,items:store.institutions.map((e)=>DropdownMenuItem(value:e.id,child:Text(e.name))).toList(),onChanged:(v)=>store.select(store.institutions.firstWhere((e)=>e.id==v)))),
   ]),
   body:Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[AppTheme.green,AppTheme.deep])),child:pages[index]),
   bottomNavigationBar:NavigationBar(backgroundColor:AppTheme.deep,indicatorColor:AppTheme.gold.withValues(alpha:.2),selectedIndex:index,onDestinationSelected:(v)=>setState(()=>index=v),destinations:const [
    NavigationDestination(icon:Icon(Icons.people_outline),label:'الطلاب'),
    NavigationDestination(icon:Icon(Icons.edit_calendar),label:'الحلقة'),
    NavigationDestination(icon:Icon(Icons.assessment_outlined),label:'التقارير'),
    NavigationDestination(icon:Icon(Icons.workspace_premium_outlined),label:'الشهادات'),
    NavigationDestination(icon:Icon(Icons.settings_outlined),label:'الإعدادات'),
   ]),
  );
 }
}
