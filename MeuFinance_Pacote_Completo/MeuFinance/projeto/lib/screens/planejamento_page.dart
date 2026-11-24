import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/categoria.dart';
import '../models/movimentacao.dart';
import '../services/financeiro_service.dart';
import '../utils/formatadores.dart';
import '../utils/calculos_financeiros.dart';
import '../widgets/async_ui.dart';
// Metas são reservas informadas manualmente, não movimentações bancárias.
class MetasPage extends StatefulWidget{
  final FinanceiroService service;const MetasPage({super.key,required this.service});
  @override State<MetasPage> createState()=>_MetasPageState();
}
class _MetasPageState extends State<MetasPage>{
  late final stream=widget.service.col('metas').snapshots();
  Future<void> editar([QueryDocumentSnapshot<Map<String,dynamic>>? doc]) async{
    final d=doc?.data();final nome=TextEditingController(text:d?['nome']??''),alvo=TextEditingController(text:d==null?'':editarValor(d['valorObjetivoCentavos'])),guardado=TextEditingController(text:d==null?'0,00':editarValor(d['valorGuardadoCentavos']));String? erro;
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,set)=>AlertDialog(title:const Text('Meta financeira'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:nome,maxLength:100,decoration:const InputDecoration(labelText:'Objetivo')),TextField(controller:alvo,decoration:const InputDecoration(labelText:'Valor objetivo')),const SizedBox(height:8),TextField(controller:guardado,decoration:const InputDecoration(labelText:'Valor reservado')),if(erro!=null)Text(erro!)])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancelar')),TextButton(onPressed:(){final a=centavos(alvo.text),g=centavos(guardado.text);if(nome.text.trim().isEmpty||a==null||a<=0||g==null){set(()=>erro='Preencha os campos corretamente');return;}Navigator.pop(ctx,true);},child:const Text('Salvar'))])));
    final n=nome.text.trim(),a=centavos(alvo.text),g=centavos(guardado.text);nome.dispose();alvo.dispose();guardado.dispose();if(ok!=true||!mounted)return;
    await executar(context,()async{final dados={'nome':n,'valorObjetivoCentavos':a!,'valorGuardadoCentavos':g!,'atualizadoEm':FieldValue.serverTimestamp()};if(doc==null){await widget.service.col('metas').add({...dados,'criadoEm':FieldValue.serverTimestamp()});}else{await doc.reference.update(dados);}});
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Metas financeiras')),floatingActionButton:FloatingActionButton(onPressed:()=>editar(),child:const Icon(Icons.add)),body:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:stream,builder:(context,s){if(s.hasError)return erro(s.error);if(!s.hasData)return espera;return ListView(padding:const EdgeInsets.fromLTRB(12,12,12,90),children:[const Text('Informe o valor reservado manualmente. Metas não alteram o saldo.'),for(final doc in s.data!.docs)Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(doc['nome'],style:Theme.of(context).textTheme.titleLarge),Text('${brl(doc['valorGuardadoCentavos'])} de ${brl(doc['valorObjetivoCentavos'])}'),LinearProgressIndicator(value:(doc['valorGuardadoCentavos']/doc['valorObjetivoCentavos']).clamp(0.0,1.0).toDouble()),Text(doc['valorGuardadoCentavos']>=doc['valorObjetivoCentavos']?'Concluída':'Em andamento'),Row(mainAxisAlignment:MainAxisAlignment.end,children:[IconButton(onPressed:()=>editar(doc),icon:const Icon(Icons.edit)),IconButton(onPressed:()async{if(await confirmar(context,'Excluir meta?')&&context.mounted)await executar(context,doc.reference.delete);},icon:const Icon(Icons.delete))])])))]); }));
}
class OrcamentosPage extends StatefulWidget{
  final FinanceiroService service;const OrcamentosPage({super.key,required this.service});
  @override State<OrcamentosPage> createState()=>_OrcamentosPageState();
}
class _OrcamentosPageState extends State<OrcamentosPage>{
  late DateTime mes=DateTime(DateTime.now().year,DateTime.now().month);
  late final categorias=widget.service.categorias();
  late Stream<List<Movimentacao>> gastos=widget.service.mes(mes);
  String get chave=>'${mes.year}_${mes.month.toString().padLeft(2,'0')}';
  late Stream<QuerySnapshot<Map<String,dynamic>>> limites=consulta();
  Stream<QuerySnapshot<Map<String,dynamic>>> consulta()=>widget.service.col('orcamentos').where('periodo',isEqualTo:chave).snapshots();
  void mudar(int n){final m=DateTime(mes.year,mes.month+n);if(m.isBefore(DateTime(2000))||m.year>9999)return;setState((){mes=m;gastos=widget.service.mes(mes);limites=consulta();});}
  Future<void> editar(Categoria c,int? atual) async{
    final periodo=chave,ano=mes.year,mesNum=mes.month;final t=TextEditingController(text:atual==null?'':editarValor(atual));String? erro;
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,set)=>AlertDialog(title:Text('Limite: ${c.nome}'),content:TextField(controller:t,decoration:InputDecoration(labelText:'Limite em reais',errorText:erro)),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancelar')),TextButton(onPressed:(){if((centavos(t.text)??0)<=0){set(()=>erro='Valor inválido');return;}Navigator.pop(ctx,true);},child:const Text('Salvar'))])));
    final v=centavos(t.text);t.dispose();if(ok!=true||!mounted)return;
    await executar(context,()=>widget.service.col('orcamentos').doc('${periodo}_${c.id}').set({'periodo':periodo,'ano':ano,'mes':mesNum,'categoriaId':c.id,'limiteCentavos':v,'atualizadoEm':FieldValue.serverTimestamp()}));
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Orçamento mensal')),body:Column(children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[IconButton(onPressed:()=>mudar(-1),icon:const Icon(Icons.chevron_left)),Text(mesBr(mes)),IconButton(onPressed:()=>mudar(1),icon:const Icon(Icons.chevron_right))]),Expanded(child:StreamBuilder<List<Categoria>>(stream:categorias,builder:(context,c){if(c.hasError)return erro(c.error);if(!c.hasData)return espera;return StreamBuilder<List<Movimentacao>>(key:ValueKey('g$chave'),stream:gastos,builder:(context,g){if(g.hasError)return erro(g.error);if(!g.hasData)return espera;final totais=porCategoria(g.data!);return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(key:ValueKey(chave),stream:limites,builder:(context,l){if(l.hasError)return erro(l.error);if(!l.hasData)return espera;final mapa={for(final d in l.data!.docs)d['categoriaId'] as String:d['limiteCentavos'] as int};return ListView(children:[for(final cat in c.data!.where((x)=>x.tipo=='despesa'&&(x.ativo||mapa.containsKey(x.id))))Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(cat.nome,style:Theme.of(context).textTheme.titleLarge),Text('Gasto: ${brl(totais[cat.id]??0)} / ${mapa[cat.id]==null?'Sem limite':brl(mapa[cat.id]!)}'),if(mapa.containsKey(cat.id))... [LinearProgressIndicator(value:((totais[cat.id]??0)/mapa[cat.id]!).clamp(0.0,1.0).toDouble(),color:(totais[cat.id]??0)>mapa[cat.id]!?Colors.red:Colors.green),if((totais[cat.id]??0)>mapa[cat.id]!)const Text('Limite ultrapassado',style:TextStyle(color:Colors.red))],Row(children:[TextButton(onPressed:()=>editar(cat,mapa[cat.id]),child:const Text('Definir limite')),if(mapa.containsKey(cat.id))TextButton(onPressed:()async{final id='${chave}_${cat.id}';if(await confirmar(context,'Remover limite?')&&context.mounted)await executar(context,()=>widget.service.col('orcamentos').doc(id).delete());},child:const Text('Remover'))])])))]);});});}))]));
}
