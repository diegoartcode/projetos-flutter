import 'package:cloud_firestore/cloud_firestore.dart';
class Animal {
 final String id;
 final Map<String,dynamic> dados;
 Animal(this.id,this.dados);
 factory Animal.fromDoc(QueryDocumentSnapshot<Map<String,dynamic>> d)=>Animal(d.id,d.data());
 String get nome=>dados['nome']??'';
 String get especie=>dados['especie']??'';
 String get porte=>dados['porte']??'';
 String get status=>dados['status']??'';
 String get doadorId=>dados['doadorId']??'';
 String get fotoBase64=>dados['fotoBase64']??'';
 int get idadeMeses=>dados['idadeMeses']??0;
}
