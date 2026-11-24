import '../models/movimentacao.dart';
import 'formatadores.dart';
List<Movimentacao> filtrar(Iterable<Movimentacao> lista,{String busca='',String tipo='todos',String categoria='',String pagamento='',int? minimo,int? maximo,String ordem='recentes'}){
  final r=lista.where((m)=>normalizar('${m.descricao} ${m.categoriaNome} ${m.observacao}').contains(normalizar(busca)) &&
    (tipo=='todos'||m.tipo==tipo)&&(categoria.isEmpty||m.categoriaId==categoria)&&
    (pagamento.isEmpty||m.formaPagamento==pagamento)&&(minimo==null||m.valorCentavos>=minimo)&&
    (maximo==null||m.valorCentavos<=maximo)).toList();
  r.sort((a,b){final c=switch(ordem){'maior'=>b.valorCentavos.compareTo(a.valorCentavos),'menor'=>a.valorCentavos.compareTo(b.valorCentavos),'antigas'=>a.data.compareTo(b.data),_=>b.data.compareTo(a.data)};return c==0?a.id.compareTo(b.id):c;});
  return r;
}
