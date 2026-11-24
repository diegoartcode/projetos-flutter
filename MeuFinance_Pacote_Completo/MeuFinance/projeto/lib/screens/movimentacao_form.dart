import 'package:flutter/material.dart';
import '../models/movimentacao.dart';
import '../models/categoria.dart';
import '../services/financeiro_service.dart';
import '../utils/formatadores.dart';
import '../widgets/async_ui.dart';
const pagamentos=['Pix','Dinheiro','Cartão de crédito','Cartão de débito','Transferência','Boleto','Outros'];
class MovimentacaoForm extends StatefulWidget {
  final FinanceiroService service;
  final Movimentacao? anterior;
  final String tipo;
  const MovimentacaoForm({super.key,required this.service,this.anterior,this.tipo='despesa'});
  @override State<MovimentacaoForm> createState()=>_MovimentacaoFormState();
}
class _MovimentacaoFormState extends State<MovimentacaoForm>{
  final form=GlobalKey<FormState>();
  late final desc=TextEditingController(text:widget.anterior?.descricao??'');
  late final valor=TextEditingController(text:widget.anterior==null?'':editarValor(widget.anterior!.valorCentavos));
  late final obs=TextEditingController(text:widget.anterior?.observacao??'');
  late String tipo=widget.anterior?.tipo??widget.tipo;
  late String? categoria=widget.anterior?.categoriaId;
  late String pagamento=widget.anterior?.formaPagamento??'Pix';
  late DateTime data=dia(widget.anterior?.data??DateTime.now());
  late final stream=widget.service.categorias();
  bool ocupado=false;
  @override void dispose(){desc.dispose();valor.dispose();obs.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.anterior==null?'Nova movimentação':'Editar movimentação')),body:StreamBuilder<List<Categoria>>(stream:stream,builder:(context,s){
    if(s.hasError)return erro(s.error);if(!s.hasData)return espera;
    final antigas=widget.anterior;
    final opcoes=s.data!.where((c)=>c.tipo==tipo&&c.ativo).toList();
    // Categoria histórica permanece válida quando a associação não muda.
    if(antigas!=null&&antigas.tipo==tipo&&!opcoes.any((c)=>c.id==antigas.categoriaId))opcoes.add(Categoria(antigas.categoriaId,antigas.categoriaNome,tipo,'#475569','category',false));
    final selecionada=opcoes.any((c)=>c.id==categoria)?categoria:null;
    return Form(key:form,child:ListView(padding:const EdgeInsets.all(16),children:[
      SegmentedButton<String>(segments:const [ButtonSegment(value:'receita',label:Text('Receita')),ButtonSegment(value:'despesa',label:Text('Despesa'))],selected:{tipo},onSelectionChanged:ocupado?null:(v)=>setState((){tipo=v.first;categoria=null;})),const SizedBox(height:16),
      TextFormField(controller:desc,maxLength:150,decoration:const InputDecoration(labelText:'Descrição'),validator:(v)=>v==null||v.trim().isEmpty?'Informe a descrição':null),
      TextFormField(controller:valor,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Valor em reais'),validator:(v)=>(centavos(v??'')??0)<=0?'Valor inválido':null),const SizedBox(height:12),
      DropdownButtonFormField<String>(key:ValueKey('$tipo-$selecionada'),initialValue:selecionada,isExpanded:true,items:[for(final c in opcoes)DropdownMenuItem(value:c.id,child:Text('${c.nome}${c.ativo?'':' (arquivada)'}'))],onChanged:ocupado?null:(v)=>setState(()=>categoria=v),validator:(v)=>v==null?'Selecione uma categoria':null,decoration:const InputDecoration(labelText:'Categoria')),const SizedBox(height:12),
      DropdownButtonFormField<String>(initialValue:pagamento,items:[for(final p in pagamentos)DropdownMenuItem(value:p,child:Text(p))],onChanged:ocupado?null:(v)=>setState(()=>pagamento=v!),decoration:const InputDecoration(labelText:'Pagamento')),
      ListTile(title:Text(dataBr(data)),leading:const Icon(Icons.calendar_month),onTap:ocupado?null:()async{final d=await showDatePicker(context:context,initialDate:data,firstDate:DateTime(2000),lastDate:DateTime.now());if(d!=null&&mounted)setState(()=>data=dia(d));}),
      TextFormField(controller:obs,maxLength:500,maxLines:3,decoration:const InputDecoration(labelText:'Observação')),
      ElevatedButton(onPressed:ocupado?null:()async{
        if(!form.currentState!.validate()||selecionada==null)return;
        final c=opcoes.firstWhere((c)=>c.id==selecionada);
        final m=Movimentacao(id:antigas?.id??'',descricao:desc.text.trim(),tipo:tipo,categoriaId:c.id,categoriaNome:antigas!=null&&antigas.categoriaId==c.id&&antigas.tipo==tipo?antigas.categoriaNome:c.nome,formaPagamento:pagamento,valorCentavos:centavos(valor.text)!,data:data,observacao:obs.text.trim());
        setState(()=>ocupado=true);try{await widget.service.salvar(m);if(mounted)Navigator.pop(context,true);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}finally{if(mounted)setState(()=>ocupado=false);}
      },child:Text(ocupado?'Salvando...':'Salvar')),
    ]));
  }));
}
