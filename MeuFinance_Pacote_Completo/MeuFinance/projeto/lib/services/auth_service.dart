import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AuthService {
  final auth=FirebaseAuth.instance;
  Future<void> entrar(String email,String senha) async {await auth.signInWithEmailAndPassword(email:email.trim(),password:senha);}
  Future<void> cadastrar(String nome,String email,String senha) async {
    final c=await auth.createUserWithEmailAndPassword(email:email.trim(),password:senha);
    await c.user!.updateDisplayName(nome.trim());
    await perfil(c.user!,nome);
  }
  Future<void> perfil(User u,String nome) async {
    final ref=FirebaseFirestore.instance.collection('usuarios').doc(u.uid);
    await FirebaseFirestore.instance.runTransaction((t) async {
      final d=await t.get(ref);
      if(!d.exists) t.set(ref,{'nome':nome.trim(),'email':u.email,'moeda':'BRL','criadoEm':FieldValue.serverTimestamp()});
    });
  }
  Future<void> sair()=>auth.signOut();
  Future<void> recuperar(String email)=>auth.sendPasswordResetEmail(email:email.trim());
}
