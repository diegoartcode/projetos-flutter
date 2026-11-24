import 'package:cloud_firestore/cloud_firestore.dart';
class DashboardService {
 Future<Map<String,int>> carregar() async {
  final db=FirebaseFirestore.instance; final a=db.collection('animais'),u=db.collection('usuarios'),s=db.collection('solicitacoes');
  final consultas=<String,Query<Map<String,dynamic>>>{'Usuários':u,'Bloqueados':u.where('ativo',isEqualTo:false),'Animais':a,'Solicitações':s,for(final st in ['pendente','disponivel','reprovado','em_adocao','adotado']) 'Animais: $st':a.where('status',isEqualTo:st),for(final e in ['Cachorro','Gato','Outro']) e:a.where('especie',isEqualTo:e),for(final st in ['pendente','aceita','recusada','cancelada','concluida']) 'Pedidos: $st':s.where('status',isEqualTo:st)};
  final valores=await Future.wait(consultas.values.map((q) async=>(await q.count().get()).count??0));
  return Map.fromIterables(consultas.keys,valores);
 }
}
