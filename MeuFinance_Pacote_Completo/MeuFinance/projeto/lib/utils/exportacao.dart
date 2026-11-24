import '../models/movimentacao.dart';
import 'formatadores.dart';
// Escapa aspas, delimitadores e fórmulas de planilha em campos textuais.
String campoCsv(String s){if(RegExp(r'^\s*[=+\-@]').hasMatch(s))s="'$s";return '"${s.replaceAll('"','""')}"';}
String gerarCsv(Iterable<Movimentacao> lista)=>[
  'data;descricao;tipo;valor_centavos;categoria;pagamento;observacao',
  for(final m in lista)[dataBr(m.data),campoCsv(m.descricao),m.tipo,m.valorCentavos.toString(),campoCsv(m.categoriaNome),campoCsv(m.formaPagamento),campoCsv(m.observacao)].join(';')
].join('\r\n');
