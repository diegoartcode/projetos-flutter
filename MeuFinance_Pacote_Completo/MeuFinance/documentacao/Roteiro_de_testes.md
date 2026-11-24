# Roteiro de homologação

Resultados esperados, não executados neste ambiente. Registre status e evidência. Use duas contas fictícias e o simulador de regras para operações negadas.

| ID | Cenário | Esperado | Status/evidência |
|---|---|---|---|
| T01 | Cadastro válido | Conta e perfil com mesmo UID | Pendente |
| T02 | Senha curta | Bloqueio | Pendente |
| T03 | E-mail duplicado | Erro tratado | Pendente |
| T04 | Login correto | Home | Pendente |
| T05 | Login incorreto | Erro | Pendente |
| T06 | Logout | Login | Pendente |
| T07 | Reabrir app | Sessão mantida | Pendente |
| T08 | Recuperação | Solicitação enviada | Pendente |
| T09 | Perfil ausente | Completar perfil | Pendente |
| T10 | Categoria inicial | 16 documentos | Pendente |
| T11 | Reabrir sessão | Sem duplicar padrão | Pendente |
| T12 | Nome duplicado | Rejeição no serviço | Pendente |
| T13 | Editar categoria | Nome/cor atualizados | Pendente |
| T14 | Arquivar | Não aparece em novo lançamento | Pendente |
| T15 | Reativar | Volta ao cadastro | Pendente |
| T16 | Receita | Documento criado | Pendente |
| T17 | Despesa | Documento criado | Pendente |
| T18 | Valor zero | Bloqueio | Pendente |
| T19 | Valor negativo | Bloqueio | Pendente |
| T20 | 1.250,90 | 125090 centavos | Pendente |
| T21 | Editar movimentação | Saldo recalculado | Pendente |
| T22 | Excluir | Remoção confirmada | Pendente |
| T23 | Categoria arquivada histórica | Edição preserva associação | Pendente |
| T24 | Pesquisa farmacia | Farmácia | Pendente |
| T25 | Filtro combinado | Somente correspondentes | Pendente |
| T26 | Intervalo personalizado | Inclui dia final | Pendente |
| T27 | 31 registros | Paginação e aviso parcial | Pendente |
| T28 | Carregar tudo | Resumo completo | Pendente |
| T29 | Troca rápida de mês | Descarta consulta antiga | Pendente |
| T30 | Mês vazio | Totais zero | Pendente |
| T31 | Sem receitas | Percentual indisponível | Pendente |
| T32 | Gráficos | Valores iguais ao CSV | Pendente |
| T33 | Meta | Progresso sem alterar saldo | Pendente |
| T34 | Orçamento | Alerta ao ultrapassar | Pendente |
| T35 | CSV parcial | Exportação desabilitada | Pendente |
| T36 | CSV completo | Conteúdo copiado | Pendente |
| T37 | Outro UID | Acesso negado | Pendente |
| T38 | Sem autenticação | Acesso negado | Pendente |
| T39 | Valor inválido via SDK | Acesso negado | Pendente |
| T40 | Categoria de tipo incompatível | Acesso negado | Pendente |
| T41 | Excluir categoria via SDK | Acesso negado | Pendente |
| T42 | Alterar criadoEm | Acesso negado | Pendente |
| T43 | Editar perfil | Nome atualizado | Pendente |
| T44 | flutter test | 11 testes aprovados, se executados com sucesso | Pendente |