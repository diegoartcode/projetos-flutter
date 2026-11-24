import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';
import '../widgets/async_ui.dart';
import 'auth_page.dart';
import 'home_page.dart';
class AuthGate extends StatelessWidget {
 const AuthGate({super.key});
 @override Widget build(BuildContext context)=>StreamBuilder<User?>(stream:FirebaseAuth.instance.authStateChanges(),builder:(context,s){
  if(s.hasError)return Scaffold(body:erro(s.error));
  if(s.connectionState==ConnectionState.waiting)return Scaffold(body:espera());
  if(s.data==null)return const AuthPage();
  final uid=s.data!.uid;
  return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(key:ValueKey(uid),stream:FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),builder:(context,p){
   if(p.connectionState==ConnectionState.waiting)return Scaffold(body:espera());
   final d=p.data?.data();
   if(p.hasError||d==null||d['ativo']==false||!['admin','usuario'].contains(d['tipo'])){
    return Scaffold(body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(p.hasError?'Erro ao carregar perfil':d==null?'Perfil ainda não encontrado':'Acesso bloqueado ou inválido'),TextButton(onPressed:()=>FirebaseAuth.instance.signOut(),child:const Text('Sair'))])));
   }
   // Navigator interno: ao perder acesso, todas as rotas protegidas são descartadas.
   return Navigator(key:ValueKey('$uid-${d['tipo']}'),onGenerateRoute:(_)=>MaterialPageRoute(builder:(_)=>HomePage(usuario:Usuario(uid,d))));
  });
 });
}
