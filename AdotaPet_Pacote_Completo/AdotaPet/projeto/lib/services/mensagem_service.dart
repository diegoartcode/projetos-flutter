import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MensagemService {
 final db=FirebaseFirestore.instance;
 String get uid=>FirebaseAuth.instance.currentUser!.uid;
 CollectionReference<Map<String,dynamic>> ref(String id)=>db.collection('solicitacoes').doc(id).collection('mensagens');
 Stream<QuerySnapshot<Map<String,dynamic>>> listar(String id)=>ref(id).orderBy('criadoEm',descending:true).limit(50).snapshots();
 Future<void> enviar(String id,String texto) async {await ref(id).add({'remetenteId':uid,'texto':texto.trim(),'criadoEm':FieldValue.serverTimestamp()});}
}
