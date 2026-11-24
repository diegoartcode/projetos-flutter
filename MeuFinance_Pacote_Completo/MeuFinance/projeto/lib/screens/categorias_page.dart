import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/financeiro_service.dart';
import '../widgets/async_ui.dart';
const cores=['#123C69','#2563EB','#16803C','#DC2626','#D97706','#7C3AED','#0891B2','#DB2777','#475569','#78716C','#EA580C'];
const icones={'category':Icons.category,'work':Icons.work,'home':Icons.home,'car':Icons.directions_car,'food':Icons.restaurant,'health':Icons.medical_services,'school':Icons.school,'pets':Icons.pets};
Color corHex(String s)=>Color(int.parse('FF${s.substring(1)}',radix:16));
class CategoriasPage extends StatefulWidget{
  final FinanceiroService service;const CategoriasPage({super.key,required this.service});
  @override State<CategoriasPage> createState()=>_CategoriasPageState();
}
class _CategoriasPageState extends State<CategoriasPage>{
  late final stream=widget.service.categorias();
  Future<void> editar([Categoria? c]) async{
    final n=TextEditingController(text:c?.nome??'');var tipo=c?.tipo??'despesa';var cor=cores.contains(c?.cor)?c!.cor:cores.first;var icone=icones.containsKey(c?.icone)?c!.icone:'category';
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,set)=>AlertDialog(title:Text(c==null?'Nova categoria':'Editar categoria'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:n,maxLength:100,decoration:const InputDecoration(labelText:'Nome')),DropdownButton<String>(value:tipo,items:const [DropdownMenuItem(value:'receita',child:Text('Receita')),DropdownMenuItem(value:'despesa',child:Text('Despesa'))],onChanged:c!=null?null:(v)=>set(()=>tipo=v!)),Wrap(children:[for(final k in cores)IconButton(tooltip:k,onPressed:()=>set(()=>cor=k),icon:Icon(cor==k?Icons.check_circle:Icons.circle,color:corHex(k)))]),Wrap(children:[for(final k in icones.keys)ChoiceChip(label:Icon(icones[k]),selected:k==icone,onSelected:(_)=>set(()=>icone=k))])])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancelar')),TextButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Salvar'))])));
    final nome=n.text.trim();n.dispose();if(ok!=true||!mounted)return;
    await executar(context,()=>widget.service.salvarCategoria(id:c?.id,nome:nome,tipo:tipo,cor:cor,icone:icone));
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Categorias')),floatingActionButton:FloatingActionButton(onPressed:()=>editar(),child:const Icon(Icons.add)),body:StreamBuilder<List<Categoria>>(stream:stream,builder:(context,s){if(s.hasError)return erro(s.error);if(!s.hasData)return espera;return ListView(padding:const EdgeInsets.only(bottom:80),children:[for(final tipo in ['receita','despesa'])... [Padding(padding:const EdgeInsets.all(16),child:Text(tipo=='receita'?'Receitas':'Despesas',style:Theme.of(context).textTheme.titleLarge)),for(final c in s.data!.where((c)=>c.tipo==tipo))ListTile(leading:CircleAvatar(backgroundColor:corHex(c.cor),foregroundColor:Colors.white,child:Icon(icones[c.icone]??Icons.category)),title:Text(c.nome),subtitle:Text(c.ativo?'Ativa':'Arquivada'),onTap:()=>editar(c),trailing:IconButton(tooltip:c.ativo?'Arquivar':'Reativar',icon:Icon(c.ativo?Icons.archive:Icons.unarchive),onPressed:()async{if(await confirmar(context,'Alterar situação de ${c.nome}?')&&context.mounted)await executar(context,()=>widget.service.situacao(c));}))]]); }));
}
