import 'package:cloud_firestore/cloud_firestore.dart';
class Solicitacao {
 final String id;
 final Map<String,dynamic> dados;
 Solicitacao(this.id,this.dados);
 factory Solicitacao.fromDoc(QueryDocumentSnapshot<Map<String,dynamic>> d)=>Solicitacao(d.id,d.data());
 String get status=>dados['status']??'';
 String get animalNome=>dados['animalNome']??'';
}
