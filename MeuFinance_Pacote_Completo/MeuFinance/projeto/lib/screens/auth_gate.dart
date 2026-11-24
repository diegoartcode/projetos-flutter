import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'auth_page.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context)=>StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),builder:(context,s){
      if(s.hasError) return Scaffold(body:Center(child:Text('${s.error}')));
      if(s.connectionState==ConnectionState.waiting) return const Scaffold(body:Center(child:CircularProgressIndicator()));
      final u=s.data;
      if(u==null) return const AuthPage();
      return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(key:ValueKey(u.uid),
        stream:FirebaseFirestore.instance.collection('usuarios').doc(u.uid).snapshots(),builder:(context,p){
          if(p.hasError) return Scaffold(body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text('${p.error}'),TextButton(onPressed:AuthService().sair,child:const Text('Sair'))])));
          if(!p.hasData) return const Scaffold(body:Center(child:CircularProgressIndicator()));
          if(!p.data!.exists) return PerfilIncompleto(user:u);
          return HomePage(key:ValueKey(u.uid),uid:u.uid,nome:p.data!.data()!['nome']);
        });
    });
}
class PerfilIncompleto extends StatefulWidget {
  final User user;
  const PerfilIncompleto({super.key,required this.user});
  @override State<PerfilIncompleto> createState()=>_PerfilIncompletoState();
}
class _PerfilIncompletoState extends State<PerfilIncompleto>{
  late final nome=TextEditingController(text:widget.user.displayName??'');
  bool ocupado=false;
  @override void dispose(){nome.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Completar perfil')),body:Padding(padding:const EdgeInsets.all(24),child:Column(children:[TextField(controller:nome,maxLength:150,decoration:const InputDecoration(labelText:'Nome')),ElevatedButton(onPressed:ocupado?null:() async {
    if(nome.text.trim().isEmpty)return;setState(()=>ocupado=true);
    try{await AuthService().perfil(widget.user,nome.text);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}finally{if(mounted)setState(()=>ocupado=false);}
  },child:const Text('Salvar perfil')),TextButton(onPressed:ocupado?null:AuthService().sair,child:const Text('Sair'))])));
}
