import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/movimentacao.dart';
import '../models/categoria.dart';
import '../services/financeiro_service.dart';
import '../utils/formatadores.dart';
import '../utils/filtro_financeiro.dart';
import '../utils/calculos_financeiros.dart';
import '../utils/exportacao.dart';
import '../widgets/resumo_card.dart';
import '../widgets/async_ui.dart';
import 'movimentacao_form.dart';
class HistoricoPage extends StatefulWidget{
  final FinanceiroService service;const HistoricoPage({super.key,required this.service});
  @override State<HistoricoPage> createState()=>_HistoricoPageState();
}
class _HistoricoPageState extends State<HistoricoPage>{
  late DateTime mes=DateTime(DateTime.now().year,DateTime.now().month);
  DateTimeRange? periodo;
  DateTime get inicio=>periodo?.start??mes;
  DateTime get fim=>periodo==null?DateTime(mes.year,mes.month+1):DateTime(periodo!.end.year,periodo!.end.month,periodo!.end.day+1);
  final lista=<Movimentacao>[];DocumentSnapshot<Map<String,dynamic>>? cursor;
  bool mais=true,ocupado=false,todas=false;int versao=0;String? falha;
  String busca='',tipo='todos',categoria='',pagamento='',ordem='recentes';int? minimo,maximo;
  final pesquisa=TextEditingController();
  late final cats=widget.service.categorias();
  @override void initState(){super.initState();carregar();}
  @override void dispose(){versao++;pesquisa.dispose();super.dispose();}
  Future<void> reiniciar() async{setState((){versao++;lista.clear();cursor=null;mais=true;ocupado=false;todas=false;falha=null;});await carregar();}
  Future<void> carregar() async{
    if(ocupado||!mais)return;final v=versao;setState((){ocupado=true;falha=null;});
    try{final q=await widget.service.pagina(inicio,fim,cursor);if(!mounted||v!=versao)return;setState((){final ids=lista.map((m)=>m.id).toSet();for(final d in q.docs){if(ids.add(d.id))lista.add(Movimentacao.fromDoc(d));}if(q.docs.isNotEmpty)cursor=q.docs.last;mais=q.docs.length==30;});}
    catch(e){if(mounted&&v==versao)setState(()=>falha='$e');}finally{if(mounted&&v==versao)setState(()=>ocupado=false);}
  }
  Future<void> carregarTudo() async{if(ocupado||todas)return;final v=versao;setState(()=>todas=true);while(mounted&&v==versao&&todas&&mais){await carregar();if(falha!=null)break;}if(mounted&&v==versao)setState(()=>todas=false);}
  Future<void> abrir([Movimentacao? m]) async{final ok=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>MovimentacaoForm(service:widget.service,anterior:m)));if(mounted&&ok==true)await reiniciar();}
  void mudarMes(int n){final novo=DateTime(mes.year,mes.month+n);final a=DateTime.now();if(novo.isBefore(DateTime(2000))||novo.isAfter(DateTime(a.year,a.month)))return;setState((){mes=novo;periodo=null;});reiniciar();}
  Future<void> avancados() async{
    final min=TextEditingController(text:minimo==null?'':editarValor(minimo!)),max=TextEditingController(text:maximo==null?'':editarValor(maximo!));
    var p=pagamento,o=ordem;String? e;
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,set)=>AlertDialog(title:const Text('Filtros avançados'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      DropdownButton<String>(value:p,isExpanded:true,items:[const DropdownMenuItem(value:'',child:Text('Todos os pagamentos')),for(final x in pagamentos)DropdownMenuItem(value:x,child:Text(x))],onChanged:(v)=>set(()=>p=v!)),
      DropdownButton<String>(value:o,isExpanded:true,items:const [DropdownMenuItem(value:'recentes',child:Text('Recentes')),DropdownMenuItem(value:'antigas',child:Text('Antigas')),DropdownMenuItem(value:'maior',child:Text('Maior valor')),DropdownMenuItem(value:'menor',child:Text('Menor valor'))],onChanged:(v)=>set(()=>o=v!)),
      TextField(controller:min,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Valor mínimo')),const SizedBox(height:8),TextField(controller:max,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Valor máximo')),if(e!=null)Text(e!,style:const TextStyle(color:Colors.red))])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancelar')),TextButton(onPressed:(){final a=centavos(min.text),b=centavos(max.text);if((min.text.trim().isNotEmpty&&a==null)||(max.text.trim().isNotEmpty&&b==null)||(a!=null&&b!=null&&a>b)){set(()=>e='Intervalo inválido');return;}Navigator.pop(ctx,true);},child:const Text('Aplicar'))])));
    final a=centavos(min.text),b=centavos(max.text);min.dispose();max.dispose();if(ok==true&&mounted)setState((){pagamento=p;ordem=o;minimo=a;maximo=b;});
  }
  @override Widget build(BuildContext context){
    final filtradas=filtrar(lista,busca:busca,tipo:tipo,categoria:categoria,pagamento:pagamento,minimo:minimo,maximo:maximo,ordem:ordem);
    return Scaffold(appBar:AppBar(title:const Text('Histórico'),actions:[IconButton(onPressed:reiniciar,icon:const Icon(Icons.refresh)),IconButton(tooltip:'Exportar CSV filtrado',onPressed:mais||ocupado?null:()async{await Clipboard.setData(ClipboardData(text:gerarCsv(filtradas)));if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('CSV copiado. Cole em um arquivo .csv.')));},icon:const Icon(Icons.download))]),floatingActionButton:FloatingActionButton(onPressed:ocupado||todas?null:()=>abrir(),child:const Icon(Icons.add)),body:ListView(padding:const EdgeInsets.fromLTRB(12,12,12,90),children:[
      Row(children:[IconButton(onPressed:()=>mudarMes(-1),icon:const Icon(Icons.chevron_left)),Expanded(child:Text(periodo==null?mesBr(mes):'${dataBr(periodo!.start)} a ${dataBr(periodo!.end)}',textAlign:TextAlign.center)),IconButton(onPressed:()=>mudarMes(1),icon:const Icon(Icons.chevron_right)),IconButton(icon:const Icon(Icons.date_range),onPressed:()async{final r=await showDateRangePicker(context:context,firstDate:DateTime(2000),lastDate:DateTime.now());if(r!=null&&mounted){setState(()=>periodo=r);reiniciar();}})]),
      if(periodo!=null)TextButton(onPressed:(){setState(()=>periodo=null);reiniciar();},child:const Text('Voltar ao mês')),
      TextField(controller:pesquisa,onChanged:(v)=>setState(()=>busca=v),decoration:const InputDecoration(labelText:'Pesquisar',prefixIcon:Icon(Icons.search))),const SizedBox(height:10),
      SegmentedButton<String>(segments:const [ButtonSegment(value:'todos',label:Text('Todas')),ButtonSegment(value:'receita',label:Text('Receitas')),ButtonSegment(value:'despesa',label:Text('Despesas'))],selected:{tipo},onSelectionChanged:(v)=>setState((){tipo=v.first;categoria='';})),
      StreamBuilder<List<Categoria>>(stream:cats,builder:(context,s){final op=(s.data??[]).where((c)=>tipo=='todos'||c.tipo==tipo).toList();return DropdownButton<String>(isExpanded:true,value:op.any((c)=>c.id==categoria)?categoria:'',items:[const DropdownMenuItem(value:'',child:Text('Todas as categorias')),for(final c in op)DropdownMenuItem(value:c.id,child:Text(c.nome))],onChanged:(v)=>setState(()=>categoria=v!));}),
      OutlinedButton(onPressed:avancados,child:const Text('Filtros avançados')),TextButton(onPressed:()=>setState((){busca='';pesquisa.clear();tipo='todos';categoria='';pagamento='';ordem='recentes';minimo=null;maximo=null;}),child:const Text('Limpar filtros')),
      ResumoCard(resumo:resumir(filtradas),titulo:mais?'Resumo parcial':'Resumo dos resultados'),Text('${filtradas.length} resultados / ${lista.length} carregados'),if(mais)const Text('Os filtros e totais são parciais até carregar todo o período.'),
      if(falha!=null)Text('Erro: $falha'),if(filtradas.isEmpty&&!ocupado)const Text('Nenhum resultado nos registros carregados.'),
      for(var i=0;i<filtradas.length;i++)...[
        if((ordem=='recentes'||ordem=='antigas')&&(i==0||dia(filtradas[i].data)!=dia(filtradas[i-1].data)))Padding(padding:const EdgeInsets.only(top:12),child:Text(dataBr(filtradas[i].data),style:Theme.of(context).textTheme.titleMedium)),
        Card(child:ListTile(title:Text(filtradas[i].descricao),subtitle:Text('${filtradas[i].categoriaNome} • ${dataBr(filtradas[i].data)} • ${filtradas[i].formaPagamento}\n${filtradas[i].receita?'+':'-'} ${brl(filtradas[i].valorCentavos)}'),onTap:ocupado||todas?null:()=>abrir(filtradas[i]),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:ocupado||todas?null:()async{final id=filtradas[i].id;if(await confirmar(context,'Excluir movimentação?')&&context.mounted){await executar(context,()async{await widget.service.excluir(id);if(mounted)await reiniciar();});}})))],
      if(ocupado)espera,if(mais&&!ocupado&&!todas)ElevatedButton(onPressed:carregar,child:const Text('Carregar mais')),if(mais&&!todas&&!ocupado)OutlinedButton(onPressed:carregarTudo,child:const Text('Carregar todo o período')),if(todas)TextButton(onPressed:()=>setState(()=>todas=false),child:const Text('Interromper')),
    ]));
  }
}
