import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class UsuarioService {
 final usuarios=FirebaseFirestore.instance.collection('usuarios');
 Future<void> situacao(String uid,bool ativo)=>usuarios.doc(uid).update({'ativo':ativo,'atualizadoEm':FieldValue.serverTimestamp()});
 Future<void> perfil(String nome,String telefone,String cidade)=>usuarios.doc(FirebaseAuth.instance.currentUser!.uid).update({'nome':nome.trim(),'telefone':telefone.trim(),'cidade':cidade.trim(),'atualizadoEm':FieldValue.serverTimestamp()});
}
