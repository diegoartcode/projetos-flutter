import 'package:flutter_test/flutter_test.dart';
import 'package:meufinance/models/movimentacao.dart';
import 'package:meufinance/utils/calculos_financeiros.dart';
import 'package:meufinance/utils/formatadores.dart';
import 'package:meufinance/utils/filtro_financeiro.dart';
import 'package:meufinance/utils/exportacao.dart';
Movimentacao m(String id,String tipo,int v,String nome)=>Movimentacao(id:id,descricao:nome,tipo:tipo,valorCentavos:v,categoriaId:'a',categoriaNome:'Teste',formaPagamento:'Pix',data:DateTime(2026,11,1));
void main(){
 final lista=[m('1','receita',590000,'Salário'),m('2','despesa',65090,'Supermercado'),m('3','despesa',12000,'Restaurante')];
 test('saldo e quantidades',(){final r=resumir(lista);expect(r.saldo,512910);expect(r.nDespesas,2);});
 test('lista vazia',(){expect(resumir([]).economia,isNull);expect(resumir([]).saldo,0);});
 test('saldo negativo',(){expect(resumir([lista[1]]).saldo,-65090);});
 test('média e extremos',(){final r=resumir(lista);expect(r.mediaDespesas,38545);expect(r.maior?.id,'2');expect(r.menor?.id,'3');});
 test('grupo por ID',(){expect(porCategoria(lista),{'a':77090});});
 test('variação',(){expect(variacao(120,100),20);expect(variacao(100,0),isNull);});
 test('conversão exata',(){expect(centavos('1.250,90'),125090);expect(centavos('0,1'),10);expect(centavos('1,999'),isNull);expect(centavos('-1'),isNull);});
 test('pesquisa sem acento',(){expect(filtrar(lista,busca:'SALARIO').single.id,'1');});
 test('filtros combinados',(){expect(filtrar(lista,tipo:'despesa',minimo:12000,maximo:12000).single.id,'3');});
 test('ordenação',(){expect(filtrar(lista,ordem:'maior').first.id,'1');});
 test('CSV protege fórmulas',(){expect(campoCsv('=1+1'), "\"'=1+1\"");});
}
