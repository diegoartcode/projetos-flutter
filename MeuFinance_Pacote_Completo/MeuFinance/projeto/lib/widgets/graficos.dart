import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/calculos_financeiros.dart';
import '../utils/formatadores.dart';
// Os valores são convertidos para reais apenas para desenhar os gráficos.
class GraficoPizza extends StatelessWidget{
  final Map<String,int> valores;final Map<String,String> nomes;
  const GraficoPizza({super.key,required this.valores,required this.nomes});
  @override Widget build(BuildContext context){final itens=valores.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));if(itens.isEmpty)return const Text('Sem despesas no período.');final total=itens.fold<int>(0,(s,e)=>s+e.value);return Column(children:[SizedBox(height:220,child:PieChart(PieChartData(centerSpaceRadius:45,sections:[for(var i=0;i<itens.length;i++)PieChartSectionData(value:itens[i].value.toDouble(),color:Colors.primaries[i%Colors.primaries.length],title:'${(itens[i].value/total*100).toStringAsFixed(0)}%',radius:60,titleStyle:const TextStyle(fontSize:11,color:Colors.white,fontWeight:FontWeight.bold))]))),for(var i=0;i<itens.length;i++)ListTile(dense:true,leading:Icon(Icons.circle,color:Colors.primaries[i%Colors.primaries.length]),title:Text(nomes[itens[i].key]??itens[i].key),trailing:Text(brl(itens[i].value)))]);}
}
class GraficoEvolucao extends StatelessWidget{
  final List<ResumoFinanceiro> dados;final List<DateTime> meses;
  const GraficoEvolucao({super.key,required this.dados,required this.meses});
  FlTitlesData get titulos=>FlTitlesData(topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:52)),bottomTitles:AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:30,interval:1,getTitlesWidget:(v,m){final i=v.toInt();return i>=0&&i<meses.length&&v==i?Text('${meses[i].month}/${meses[i].year.toString().substring(2)}',style:const TextStyle(fontSize:10)):const SizedBox.shrink();})));
  @override Widget build(BuildContext context)=>Column(children:[const Text('Receitas (verde) e despesas (vermelho) em R\$'),SizedBox(height:230,child:BarChart(BarChartData(minY:0,titlesData:titulos,barGroups:[for(var i=0;i<dados.length;i++)BarChartGroupData(x:i,barRods:[BarChartRodData(toY:dados[i].receitas/100,color:Colors.green,width:9),BarChartRodData(toY:dados[i].despesas/100,color:Colors.red,width:9)])]))),const SizedBox(height:20),const Text('Evolução do saldo mensal em R\$'),SizedBox(height:230,child:LineChart(LineChartData(minX:0,maxX:(dados.length-1).toDouble(),titlesData:titulos,lineBarsData:[LineChartBarData(spots:[for(var i=0;i<dados.length;i++)FlSpot(i.toDouble(),dados[i].saldo/100)],color:Colors.blue,barWidth:3)])))]);
}
