import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/solicitacao.dart';
class SolicitacaoService {
 final db=FirebaseFirestore.instance;
 String get uid=>FirebaseAuth.instance.currentUser!.uid;
 CollectionReference<Map<String,dynamic>> get pedidos=>db.collection('solicitacoes');
 Stream<List<Solicitacao>> listar(String modo){
  Query<Map<String,dynamic>> q=pedidos;
  if(modo=='enviadas')q=q.where('adotanteId',isEqualTo:uid);
  if(modo=='recebidas')q=q.where('doadorId',isEqualTo:uid);
  return q.snapshots().map((s)=>s.docs.map(Solicitacao.fromDoc).toList());
 }
 // ID determinístico: uma solicitação por animal e interessado.
 Future<void> solicitar(String animalId,String mensagem) async {
  final interessado=uid;
  await db.runTransaction((t) async {
   final a=(await t.get(db.collection('animais').doc(animalId))).data();
   final u=(await t.get(db.collection('usuarios').doc(interessado))).data();
   if(a==null||u==null||a['status']!='disponivel'||a['doadorId']==interessado)throw Exception('Animal indisponível');
   final ref=pedidos.doc('${animalId}_$interessado');
   // A regra permite somente criação; sobrescrever um pedido é negado.
   t.set(ref,{'animalId':animalId,'animalNome':a['nome'],'adotanteId':interessado,'adotanteNome':u['nome'],'doadorId':a['doadorId'],'mensagem':mensagem.trim(),'status':'pendente','criadoEm':FieldValue.serverTimestamp(),'atualizadoEm':FieldValue.serverTimestamp()});
  });
 }
 Future<void> simples(String id,String status)=>pedidos.doc(id).update({'status':status,'atualizadoEm':FieldValue.serverTimestamp()});
 // Atualiza animal e pedido na mesma transação.
 Future<void> transicao(String id,String destino) async {
  await db.runTransaction((t) async {
   final ref=pedidos.doc(id); final s=(await t.get(ref)).data()!;
   final ar=db.collection('animais').doc(s['animalId']); final a=(await t.get(ar)).data()!;
   if(s['doadorId']!=uid||a['doadorId']!=uid)throw Exception('Não autorizado');
   final alteracao=<String,dynamic>{'atualizadoEm':FieldValue.serverTimestamp()};
   if(destino=='aceita'){
    if(s['status']!='pendente'||a['status']!='disponivel')throw Exception('Animal indisponível');
    alteracao.addAll({'status':'em_adocao','adotanteId':s['adotanteId'],'solicitacaoAceitaId':id});
   } else {
    if(s['status']!='aceita'||a['status']!='em_adocao'||a['solicitacaoAceitaId']!=id)throw Exception('Processo inválido');
    if(destino=='concluida'){alteracao['status']='adotado';}
    else if(destino=='cancelada'){alteracao.addAll({'status':'disponivel','adotanteId':FieldValue.delete(),'solicitacaoAceitaId':FieldValue.delete()});}
    else {throw Exception('Destino inválido');}
   }
   t.update(ref,{'status':destino,'atualizadoEm':FieldValue.serverTimestamp()}); t.update(ar,alteracao);
  });
 }
}
