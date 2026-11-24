class Usuario {
 final String uid,nome,email,telefone,cidade,tipo;
 final bool ativo;
 Usuario(this.uid, Map<String,dynamic> d):nome=d['nome']??'',email=d['email']??'',telefone=d['telefone']??'',cidade=d['cidade']??'',tipo=d['tipo']??'',ativo=d['ativo']??true;
}
