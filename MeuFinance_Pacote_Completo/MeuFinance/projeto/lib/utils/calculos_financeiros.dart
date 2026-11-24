import '../models/movimentacao.dart';
class ResumoFinanceiro {
  final int receitas,despesas,nReceitas,nDespesas;
  final Movimentacao? maior,menor;
  const ResumoFinanceiro(this.receitas,this.despesas,this.nReceitas,this.nDespesas,this.maior,this.menor);
  int get saldo=>receitas-despesas;
  int? get mediaDespesas=>nDespesas==0?null:(despesas/nDespesas).round();
  double? get comprometido=>receitas==0?null:despesas/receitas*100;
  double? get economia=>receitas==0?null:saldo/receitas*100;
}
ResumoFinanceiro resumir(Iterable<Movimentacao> lista){
  int r=0,d=0,nr=0,nd=0; Movimentacao? maior,menor;
  for(final m in lista){
    if(m.receita){r+=m.valorCentavos;nr++;}
    else if(m.despesa){d+=m.valorCentavos;nd++;
      if(maior==null||m.valorCentavos>maior.valorCentavos) maior=m;
      if(menor==null||m.valorCentavos<menor.valorCentavos) menor=m;}
  }
  return ResumoFinanceiro(r,d,nr,nd,maior,menor);
}
Map<String,int> porCategoria(Iterable<Movimentacao> lista){
  final mapa=<String,int>{};
  for(final m in lista.where((m)=>m.despesa)){
    mapa[m.categoriaId]=(mapa[m.categoriaId]??0)+m.valorCentavos;
  }
  return mapa;
}
double? variacao(int atual,int anterior)=>anterior<=0?null:(atual-anterior)/anterior*100;
