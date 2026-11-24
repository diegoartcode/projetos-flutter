import 'package:flutter/material.dart';
import '../services/auth_service.dart';
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override State<AuthPage> createState()=>_AuthPageState();
}
class _AuthPageState extends State<AuthPage>{
  final nome=TextEditingController(),email=TextEditingController(),senha=TextEditingController(),confirmar=TextEditingController();
  final form=GlobalKey<FormState>();
  final service=AuthService();
  bool cadastro=false,ocupado=false;
  Future<void> enviar({bool reset=false}) async {
    if(ocupado)return;
    if(reset){if(!email.text.contains('@')){mensagem('Informe seu e-mail');return;}}
    else if(!form.currentState!.validate())return;
    setState(()=>ocupado=true);
    try{
      if(reset){await service.recuperar(email.text);mensagem('Se a conta existir, verifique seu e-mail.');}
      else if(cadastro){await service.cadastrar(nome.text,email.text,senha.text);}
      else{await service.entrar(email.text,senha.text);}
    }catch(e){mensagem('Não foi possível concluir: $e');}finally{if(mounted)setState(()=>ocupado=false);}
  }
  void mensagem(String s){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
  @override void dispose(){nome.dispose();email.dispose();senha.dispose();confirmar.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('MeuFinance')),body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:480),child:ListView(shrinkWrap:true,padding:const EdgeInsets.all(24),children:[
    const Icon(Icons.account_balance_wallet,size:80),const SizedBox(height:20),
    Form(key:form,child:Column(children:[
      if(cadastro)TextFormField(controller:nome,maxLength:150,decoration:const InputDecoration(labelText:'Nome'),validator:(v)=>v==null||v.trim().isEmpty?'Informe seu nome':null),
      TextFormField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'E-mail'),validator:(v)=>v==null||!v.contains('@')?'E-mail inválido':null),const SizedBox(height:12),
      TextFormField(controller:senha,obscureText:true,decoration:const InputDecoration(labelText:'Senha'),validator:(v)=>v==null||v.length<6?'Mínimo de 6 caracteres':null),
      if(cadastro)TextFormField(controller:confirmar,obscureText:true,decoration:const InputDecoration(labelText:'Confirmar senha'),validator:(v)=>v!=senha.text?'Senhas diferentes':null),
    ])),const SizedBox(height:20),ElevatedButton(onPressed:ocupado?null:()=>enviar(),child:Text(ocupado?'Aguarde...':cadastro?'Cadastrar':'Entrar')),
    TextButton(onPressed:ocupado?null:()=>setState(()=>cadastro=!cadastro),child:Text(cadastro?'Já tenho conta':'Criar conta')),
    TextButton(onPressed:ocupado?null:()=>enviar(reset:true),child:const Text('Esqueci minha senha')),
  ]))));
}
