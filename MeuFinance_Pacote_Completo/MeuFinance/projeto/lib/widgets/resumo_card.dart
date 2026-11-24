import 'package:flutter/material.dart';
import '../utils/calculos_financeiros.dart';
import '../utils/formatadores.dart';
class ResumoCard extends StatelessWidget {
  final ResumoFinanceiro resumo;
  final String titulo;
  const ResumoCard({super.key,required this.resumo,this.titulo='Saldo do período'});
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(titulo),Text(brl(resumo.saldo),style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:resumo.saldo<0?Colors.red:Colors.blue.shade800)),
    Text('Receitas: ${brl(resumo.receitas)}',style:const TextStyle(color:Colors.green)),Text('Despesas: ${brl(resumo.despesas)}',style:const TextStyle(color:Colors.red)),
    Text('${resumo.nReceitas+resumo.nDespesas} movimentações'),
  ])));
}
