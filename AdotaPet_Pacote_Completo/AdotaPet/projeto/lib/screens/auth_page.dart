import 'package:flutter/material.dart';
import '../services/auth_service.dart';
class AuthPage extends StatefulWidget {const AuthPage({super.key});@override State<AuthPage> createState()=>_AuthPageState();}
class _AuthPageState extends State<AuthPage>{
 final service=AuthService(); final form=GlobalKey<FormState>();
 final nome=TextEditingController(),email=TextEditingController(),telefone=TextEditingController(),cidade=TextEditingController(),senha=TextEditingController(),confirmacao=TextEditingController();
 bool cadastro=false,ocupado=false,ocultar=true;
 @override void dispose(){for(final c in [nome,email,telefone,cidade,senha,confirmacao]){c.dispose();}super.dispose();}
 Future<void> executar(bool recuperar) async {
  if(ocupado)return;
  if(recuperar){if(!email.text.contains('@')){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Informe seu e-mail')));return;}}
  else if(!form.currentState!.validate())return;
  setState(()=>ocupado=true);
  try{if(recuperar){await service.recuperar(email.text);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Se a conta existir, verifique seu e-mail.')));}else if(cadastro){await service.cadastro(nome.text,email.text,telefone.text,cidade.text,senha.text);}else{await service.login(email.text,senha.text);}}
  catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Não foi possível concluir: $e')));}
  finally{if(mounted)setState(()=>ocupado=false);}
 }
 Widget campo(String label,TextEditingController c,{int? max,bool secret=false})=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextFormField(controller:c,enabled:!ocupado,maxLength:max,obscureText:secret&&ocultar,decoration:InputDecoration(labelText:label),validator:(v){if(v==null||v.trim().isEmpty)return 'Campo obrigatório';if(c==email&&!v.contains('@'))return 'E-mail inválido';if(c==senha&&cadastro&&v.length<6)return 'Mínimo 6 caracteres';if(c==confirmacao&&v!=senha.text)return 'Senhas diferentes';return null;}));
 @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:Form(key:form,child:Column(children:[const Icon(Icons.pets,size:80,color:Color(0xff276749)),Text('AdotaPet',style:Theme.of(context).textTheme.headlineLarge),const Text('Um novo lar. Uma nova história.'),const SizedBox(height:24),if(cadastro)...[campo('Nome',nome,max:150),campo('Telefone',telefone,max:30),campo('Cidade',cidade,max:150)],campo('E-mail',email),campo('Senha',senha,secret:true),if(cadastro)campo('Confirmar senha',confirmacao,secret:true),TextButton(onPressed:()=>setState(()=>ocultar=!ocultar),child:Text(ocultar?'Mostrar senha':'Ocultar senha')),if(ocupado)const CircularProgressIndicator()else ...[FilledButton(onPressed:()=>executar(false),child:Text(cadastro?'Cadastrar':'Entrar')),TextButton(onPressed:()=>setState(()=>cadastro=!cadastro),child:Text(cadastro?'Já tenho conta':'Criar conta')),if(!cadastro)TextButton(onPressed:()=>executar(true),child:const Text('Esqueci minha senha'))]])))))));
}
