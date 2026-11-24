import 'package:intl/intl.dart';
String brl(int centavos) => NumberFormat.currency(locale:'pt_BR',symbol:r'R$').format(centavos/100);
String dataBr(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
String mesBr(DateTime d) => '${d.month.toString().padLeft(2,'0')}/${d.year}';
DateTime dia(DateTime d) => DateTime(d.year,d.month,d.day);
// Conversão exata, sem multiplicar um double.
int? centavos(String s) {
  s=s.trim();
  if (!RegExp(r'^(\d+|\d{1,3}(\.\d{3})+)(,\d{1,2})?$').hasMatch(s)) return null;
  final p=s.replaceAll('.','').split(',');
  final r=int.tryParse(p[0]);
  if(r==null || r>999999999) return null;
  return r*100+int.parse(p.length==2?p[1].padRight(2,'0'):'00');
}
String editarValor(int v) => '${v~/100},${(v%100).toString().padLeft(2,'0')}';
String normalizar(String s) {
  s=s.toLowerCase().trim();
  const a='áàâãäéèêëíìîïóòôõöúùûüç', b='aaaaaeeeeiiiiooooouuuuc';
  for(var i=0;i<a.length;i++){s=s.replaceAll(a[i],b[i]);}
  return s.replaceAll(RegExp(r'\s+'),' ');
}
