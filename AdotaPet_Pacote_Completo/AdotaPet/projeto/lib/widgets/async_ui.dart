import 'package:flutter/material.dart';
// Centraliza mensagens de erro e confirmações.
Future<void> executar(BuildContext context,Future<void> Function() acao) async {try{await acao();if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Operação realizada')));}catch(e){if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Erro: $e')));}}
Future<bool> confirmar(BuildContext context,String texto) async => await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Confirmar'),content:Text(texto),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Voltar')),TextButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Confirmar'))]))??false;
void abrir(BuildContext context,Widget tela)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>tela));
Widget espera()=>const Center(child:CircularProgressIndicator());
Widget erro(Object? e)=>Center(child:Text('Erro: $e'));
