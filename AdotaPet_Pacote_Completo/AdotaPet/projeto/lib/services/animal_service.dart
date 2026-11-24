import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/animal.dart';
class AnimalService {
 final animais=FirebaseFirestore.instance.collection('animais');
 String get uid=>FirebaseAuth.instance.currentUser!.uid;
 Stream<List<Animal>> listar(String modo){
  Query<Map<String,dynamic>> q=animais;
  if(modo=='meus') q=q.where('doadorId',isEqualTo:uid);
  if(modo=='catalogo') q=q.where('status',isEqualTo:'disponivel');
  return q.snapshots().map((s)=>s.docs.map(Animal.fromDoc).toList());
 }
 Future<void> salvar(Map<String,dynamic> dados,{String? id}) async {
  final d={...dados,'status':'pendente','atualizadoEm':FieldValue.serverTimestamp()};
  if(id==null){await animais.add({...d,'doadorId':uid,'criadoEm':FieldValue.serverTimestamp()});}
  else {await animais.doc(id).update({...d,'fotoUrl':FieldValue.delete()});}
 }
 Future<void> excluir(String id)=>animais.doc(id).delete();
 Future<void> moderar(String id,String status)=>animais.doc(id).update({'status':status,'atualizadoEm':FieldValue.serverTimestamp()});
}
