import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AuthService {
 final auth=FirebaseAuth.instance;
 final db=FirebaseFirestore.instance;
 Future<void> login(String email,String senha) async {await auth.signInWithEmailAndPassword(email:email.trim(),password:senha);}
 Future<void> cadastro(String nome,String email,String telefone,String cidade,String senha) async {
  final c=await auth.createUserWithEmailAndPassword(email:email.trim(),password:senha);
  final u=c.user!;
  try {await db.collection('usuarios').doc(u.uid).set({'nome':nome.trim(),'email':u.email,'telefone':telefone.trim(),'cidade':cidade.trim(),'tipo':'usuario','ativo':true,'criadoEm':FieldValue.serverTimestamp()});}
  catch (_) {try {await u.delete();} finally {await auth.signOut();} rethrow;}
 }
 Future<void> logout()=>auth.signOut();
 Future<void> recuperar(String email)=>auth.sendPasswordResetEmail(email:email.trim());
}
