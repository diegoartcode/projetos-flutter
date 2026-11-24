import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movimentacao.dart';
import '../models/categoria.dart';
import '../utils/formatadores.dart';
// O UID é fixado na sessão: nenhum caminho aponta para outro usuário.
class FinanceiroService {
  final String uid;
  FinanceiroService(this.uid);
  final db=FirebaseFirestore.instance;
  DocumentReference<Map<String,dynamic>> get perfil=>db.collection('usuarios').doc(uid);
  CollectionReference<Map<String,dynamic>> col(String nome)=>perfil.collection(nome);
  static const padrao=[
    ['receita_salario','Salário','receita','#16803C','work'],['receita_freelance','Freelance','receita','#2563EB','work'],['receita_comissoes','Comissões','receita','#D97706','work'],['receita_vendas','Vendas','receita','#7C3AED','work'],['receita_rendimentos','Rendimentos','receita','#0891B2','work'],['receita_outros','Outros','receita','#475569','category'],
    ['despesa_alimentacao','Alimentação','despesa','#D97706','food'],['despesa_moradia','Moradia','despesa','#2563EB','home'],['despesa_transporte','Transporte','despesa','#7C3AED','car'],['despesa_saude','Saúde','despesa','#DC2626','health'],['despesa_educacao','Educação','despesa','#0891B2','school'],['despesa_lazer','Lazer','despesa','#DB2777','category'],['despesa_compras','Compras','despesa','#EA580C','category'],['despesa_servicos','Serviços','despesa','#475569','category'],['despesa_pets','Pets','despesa','#16803C','pets'],['despesa_outros','Outros','despesa','#78716C','category']];
  Future<void> inicializar() async {
    // Transação idempotente: não sobrescreve categorias personalizadas.
    await db.runTransaction((t) async {
      final faltam=<List<String>>[];
      for(final c in padrao){if(!(await t.get(col('categorias').doc(c[0]))).exists) faltam.add(c);}
      for(final c in faltam){t.set(col('categorias').doc(c[0]),{'nome':c[1],'nomeNormalizado':normalizar(c[1]),'tipo':c[2],'cor':c[3],'icone':c[4],'ativo':true,'criadoEm':FieldValue.serverTimestamp(),'atualizadoEm':FieldValue.serverTimestamp()});}
    });
  }
  Stream<List<Categoria>> categorias()=>col('categorias').snapshots().map((q)=>q.docs.map(Categoria.fromDoc).toList()..sort((a,b)=>a.nome.compareTo(b.nome)));
  Future<void> salvarCategoria({String? id,required String nome,required String tipo,required String cor,required String icone}) async {
    final n=normalizar(nome);
    if(n.isEmpty) throw Exception('Nome obrigatório');
    final q=await col('categorias').where('nomeNormalizado',isEqualTo:n).get();
    if(q.docs.any((d)=>d.id!=id&&d.data()['tipo']==tipo)) throw Exception('Categoria duplicada');
    final dados={'nome':nome.trim(),'nomeNormalizado':n,'cor':cor,'icone':icone,'atualizadoEm':FieldValue.serverTimestamp()};
    if(id==null){await col('categorias').add({...dados,'tipo':tipo,'ativo':true,'criadoEm':FieldValue.serverTimestamp()});}
    else {await col('categorias').doc(id).update(dados);}
  }
  Future<void> situacao(Categoria c)=>col('categorias').doc(c.id).update({'ativo':!c.ativo,'atualizadoEm':FieldValue.serverTimestamp()});
  Query<Map<String,dynamic>> intervalo(DateTime inicio,DateTime fim)=>col('movimentacoes').where('data',isGreaterThanOrEqualTo:Timestamp.fromDate(inicio)).where('data',isLessThan:Timestamp.fromDate(fim)).orderBy('data',descending:true);
  Stream<List<Movimentacao>> mes(DateTime m)=>intervalo(DateTime(m.year,m.month),DateTime(m.year,m.month+1)).snapshots().map((q)=>q.docs.map(Movimentacao.fromDoc).toList());
  Future<List<Movimentacao>> consultar(DateTime inicio,DateTime fim) async=>(await intervalo(inicio,fim).get()).docs.map(Movimentacao.fromDoc).toList();
  Future<QuerySnapshot<Map<String,dynamic>>> pagina(DateTime inicio,DateTime fim,DocumentSnapshot<Map<String,dynamic>>? cursor){
    var q=intervalo(inicio,fim).limit(30);
    if(cursor!=null) q=q.startAfterDocument(cursor);
    return q.get(const GetOptions(source:Source.server));
  }
  Future<void> salvar(Movimentacao m) async {
    final dados={...m.toMap(),'atualizadoEm':FieldValue.serverTimestamp()};
    if(m.id.isEmpty){await col('movimentacoes').add({...dados,'criadoEm':FieldValue.serverTimestamp()});}
    else {await col('movimentacoes').doc(m.id).update(dados);}
  }
  Future<void> excluir(String id)=>col('movimentacoes').doc(id).delete();
  Future<void> nome(String nome)=>perfil.update({'nome':nome.trim()});
}
