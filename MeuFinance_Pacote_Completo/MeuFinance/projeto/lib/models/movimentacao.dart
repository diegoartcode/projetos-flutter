import 'package:cloud_firestore/cloud_firestore.dart';
// Valores são inteiros em centavos; o ID vem do documento.
class Movimentacao {
  final String id, descricao, tipo, categoriaId, categoriaNome, formaPagamento, observacao;
  final int valorCentavos;
  final DateTime data;
  const Movimentacao({required this.id, required this.descricao, required this.tipo,
    required this.categoriaId, required this.categoriaNome, required this.formaPagamento,
    required this.valorCentavos, required this.data, this.observacao = ''});
  bool get receita => tipo == 'receita';
  bool get despesa => tipo == 'despesa';
  factory Movimentacao.fromDoc(DocumentSnapshot<Map<String,dynamic>> doc) {
    final d = doc.data()!;
    return Movimentacao(id: doc.id, descricao: d['descricao'], tipo: d['tipo'],
      categoriaId: d['categoriaId'], categoriaNome: d['categoriaNome'],
      formaPagamento: d['formaPagamento'], observacao: d['observacao'] ?? '',
      valorCentavos: d['valorCentavos'], data: (d['data'] as Timestamp).toDate());
  }
  Map<String,dynamic> toMap() => {'descricao':descricao,'tipo':tipo,
    'categoriaId':categoriaId,'categoriaNome':categoriaNome,'formaPagamento':formaPagamento,
    'observacao':observacao,'valorCentavos':valorCentavos,'data':Timestamp.fromDate(data)};
}
