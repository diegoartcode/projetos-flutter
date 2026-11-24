# Dicionário de dados
Todos os caminhos estão sob `usuarios/{uid}`. IDs não são duplicados nos campos.

| Coleção | Campos e tipos | Restrições |
|---|---|---|
| usuarios | nome:string, email:string, moeda:string, criadoEm:timestamp | UID do Auth, moeda BRL, edição apenas nome |
| movimentacoes | descricao:string, tipo:string, valorCentavos:int, categoriaId:string, categoriaNome:string, formaPagamento:string, data:timestamp, observacao:string, criadoEm:timestamp, atualizadoEm:timestamp | valor positivo, data não futura, categoria correspondente, histórico preservado |
| categorias | nome:string, nomeNormalizado:string, tipo:string, cor:string, icone:string, ativo:bool, criadoEm:timestamp, atualizadoEm:timestamp | tipo imutável, exclusão lógica |
| metas | nome:string, valorObjetivoCentavos:int, valorGuardadoCentavos:int, criadoEm:timestamp, atualizadoEm:timestamp | alvo positivo, reservado não negativo |
| orcamentos | periodo:string, ano:int, mes:int, categoriaId:string, limiteCentavos:int, atualizadoEm:timestamp | ID AAAA_MM_categoriaId, categoria despesa, limite positivo |

Valores monetários sempre inteiros em centavos. Datas de auditoria são serverTimestamp. Indicadores, progresso da meta e gastos do orçamento são derivados, não duplicados no banco.
