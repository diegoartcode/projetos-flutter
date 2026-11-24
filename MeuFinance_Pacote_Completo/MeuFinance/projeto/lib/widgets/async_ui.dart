import 'package:flutter/material.dart';
Future<void> executar(BuildContext context,Future<void> Function() acao) async {
  try{await acao();}catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Erro: $e')));}
}
Future<bool> confirmar(BuildContext context,String texto) async => await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Confirmar'),content:Text(texto),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancelar')),TextButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Confirmar'))]))??false;
Widget erro(Object? e)=>Center(child:Text('Erro: $e'));
const espera=Center(child:CircularProgressIndicator());
