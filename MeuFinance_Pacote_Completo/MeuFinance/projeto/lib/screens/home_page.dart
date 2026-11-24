import 'package:flutter/material.dart';
import '../models/movimentacao.dart';
import '../services/auth_service.dart';
import '../services/financeiro_service.dart';
import '../utils/calculos_financeiros.dart';
import '../utils/formatadores.dart';
import '../widgets/resumo_card.dart';
import '../widgets/async_ui.dart';
import 'movimentacao_form.dart';
import 'historico_page.dart';
import 'categorias_page.dart';
import 'relatorios_page.dart';
import 'planejamento_page.dart';
class HomePage extends StatefulWidget{
  final String uid,nome;const HomePage({super.key,required this.uid,required this.nome});
  @override State<HomePage> createState()=>_HomePageState();
}
class _HomePageState extends State<HomePage>{
  late final service=FinanceiroService(widget.uid);
  late Future<void> inicial=service.inicializar();
  late final mesReferencia=DateTime.now();
  late final stream=service.mes(mesReferencia);
  void abrir(Widget w)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>w));
  Future<void> perfil() async{final t=TextEditingController(text:widget.nome);final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Editar perfil'),content:TextField(controller:t,maxLength:150),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancelar')),TextButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Salvar'))]));final nome=t.text.trim();t.dispose();if(ok==true&&mounted&&nome.isNotEmpty)await executar(context,()=>service.nome(nome));}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('MeuFinance'),actions:[IconButton(tooltip:'Perfil',onPressed:perfil,icon:const Icon(Icons.person)),IconButton(tooltip:'Sair',onPressed:()async{if(await confirmar(context,'Encerrar sessão?')&&context.mounted)await executar(context,AuthService().sair);},icon:const Icon(Icons.logout))]),body:FutureBuilder<void>(future:inicial,builder:(context,s){if(s.connectionState==ConnectionState.waiting)return espera;if(s.hasError)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text('${s.error}'),TextButton(onPressed:()=>setState(()=>inicial=service.inicializar()),child:const Text('Tentar novamente'))]));return ListView(padding:const EdgeInsets.all(16),children:[Text('Olá, ${widget.nome}!',style:Theme.of(context).textTheme.headlineSmall),Text('Mês de referência: ${mesBr(mesReferencia)}'),StreamBuilder<List<Movimentacao>>(stream:stream,builder:(context,s){if(s.hasError)return erro(s.error);if(!s.hasData)return espera;return ResumoCard(resumo:resumir(s.data!),titulo:'Saldo mensal');}),Row(children:[Expanded(child:FilledButton(onPressed:()=>abrir(MovimentacaoForm(service:service,tipo:'receita')),child:const Text('+ Receita'))),const SizedBox(width:8),Expanded(child:FilledButton(onPressed:()=>abrir(MovimentacaoForm(service:service)),child:const Text('+ Despesa')))]),const Divider(),ListTile(leading:const Icon(Icons.history),title:const Text('Histórico financeiro'),onTap:()=>abrir(HistoricoPage(service:service))),ListTile(leading:const Icon(Icons.category),title:const Text('Categorias'),onTap:()=>abrir(CategoriasPage(service:service))),ListTile(leading:const Icon(Icons.bar_chart),title:const Text('Relatórios e gráficos'),onTap:()=>abrir(RelatoriosPage(service:service))),ListTile(leading:const Icon(Icons.savings),title:const Text('Metas financeiras'),onTap:()=>abrir(MetasPage(service:service))),ListTile(leading:const Icon(Icons.pie_chart),title:const Text('Orçamento mensal'),onTap:()=>abrir(OrcamentosPage(service:service))) ]); }));
}
