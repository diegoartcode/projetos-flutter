import 'package:cloud_firestore/cloud_firestore.dart';
class Categoria {
  final String id,nome,tipo,cor,icone;
  final bool ativo;
  const Categoria(this.id,this.nome,this.tipo,this.cor,this.icone,this.ativo);
  factory Categoria.fromDoc(DocumentSnapshot<Map<String,dynamic>> d) {
    final m=d.data()!;
    return Categoria(d.id,m['nome'],m['tipo'],m['cor'],m['icone'],m['ativo']);
  }
}
