import 'dart:convert';
import 'package:flutter/material.dart';
class FotoAnimal extends StatelessWidget {
 final String fotoBase64; final double altura;
 const FotoAnimal({super.key,required this.fotoBase64,this.altura=180});
 @override Widget build(BuildContext context){
  Widget vazio()=>SizedBox(height:altura,child:const Center(child:Icon(Icons.pets,size:55)));
  try {return fotoBase64.isEmpty?vazio():Image.memory(base64Decode(fotoBase64),height:altura,width:double.infinity,fit:BoxFit.cover,errorBuilder:(_,__,___)=>vazio());} catch(_){return vazio();}
 }
}
