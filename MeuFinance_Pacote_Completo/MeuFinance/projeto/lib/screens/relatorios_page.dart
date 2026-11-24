import 'package:flutter/material.dart';
import '../models/movimentacao.dart';
import '../services/financeiro_service.dart';
import '../utils/calculos_financeiros.dart';
import '../utils/formatadores.dart';
import '../widgets/resumo_card.dart';
import '../widgets/graficos.dart';
import '../widgets/async_ui.dart';
class RelatoriosPage extends StatefulWidget{
  final FinanceiroService service;const RelatoriosPage({super.key,required this.service});
  @override State<RelatoriosPage> createState()=>_RelatoriosPageState();
}
class _RelatoriosPageState extends State<RelatoriosPage>{
  late DateTime mes=DateTime(DateTime.now().year,DateTime.now().month);
  late Future<List<Movimentacao>> dados=consultar();
  Future<List<Movimentacao>> consultar()=>widget.service.consultar(DateTime(mes.year,mes.month-5),DateTime(mes.year,mes.month+1));
  void mudar(int n){final d=DateTime(mes.year,mes.month+n),a=DateTime.now();if(d.isAfter(DateTime(a.year,a.month))||d.isBefore(DateTime(2000)))return;setState((){mes=d;dados=consultar();});}
  String pct(double? v)=>v==null?'—':'${v.toStringAsFixed(2)}%';
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Relatórios'),actions:[IconButton(onPressed:()=>setState(()=>dados=consultar()),icon:const Icon(Icons.refresh))]),body:Column(children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[IconButton(onPressed:()=>mudar(-1),icon:const Icon(Icons.chevron_left)),Text(mesBr(mes)),IconButton(onPressed:()=>mudar(1),icon:const Icon(Icons.chevron_right))]),Expanded(child:FutureBuilder<List<Movimentacao>>(future:dados,builder:(context,s){if(s.connectionState==ConnectionState.waiting)return espera;if(s.hasError)return erro(s.error);final l=s.data??[];final meses=[for(var i=5;i>=0;i--)DateTime(mes.year,mes.month-i)];final res=[for(final m in meses)resumir(l.where((x)=>x.data.year==m.year&&x.data.month==m.month))];final atual=l.where((x)=>x.data.year==mes.year&&x.data.month==mes.month).toList();final r=res.last;final nomes={for(final m in atual)m.categoriaId:m.categoriaNome};return ListView(padding:const EdgeInsets.all(16),children:[ResumoCard(resumo:r),Text('Renda comprometida: ${pct(r.comprometido)}'),Text('Economia: ${pct(r.economia)}'),Text('Média das despesas: ${r.mediaDespesas==null?'—':brl(r.mediaDespesas!)}'),Text('Maior despesa: ${r.maior?.descricao??'—'} ${r.maior==null?'':brl(r.maior!.valorCentavos)}'),Text('Menor despesa: ${r.menor==null?'—':brl(r.menor!.valorCentavos)}'),Text('Variação das receitas: ${pct(variacao(r.receitas,res[4].receitas))}'),Text('Variação das despesas: ${pct(variacao(r.despesas,res[4].despesas))}'),OutlinedButton(onPressed:()async{final ref=mes;await executar(context,()async{final l=await widget.service.consultar(DateTime(2000),DateTime(ref.year,ref.month+1));if(context.mounted)await showDialog<void>(context:context,builder:(c)=>AlertDialog(title:Text('Acumulado até ${mesBr(ref)}'),content:Text(brl(resumir(l).saldo)),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Fechar'))]));});},child:const Text('Consultar saldo acumulado')),const Divider(),const Text('Despesas por categoria (ranking e distribuição)'),GraficoPizza(valores:porCategoria(atual),nomes:nomes),const Divider(),GraficoEvolucao(dados:res,meses:meses)]);} ))]));
}
