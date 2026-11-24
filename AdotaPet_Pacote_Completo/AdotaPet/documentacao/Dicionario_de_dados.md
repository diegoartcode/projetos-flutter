## Banco de dados

| Coleção | Identificador | Campos principais |
|---|---|---|
| usuarios | UID | nome, email, telefone, cidade, tipo, ativo, criadoEm |
| animais | automático | nome, especie, raca, idadeMeses, porte, sexo, descricao, vacinado, castrado, fotoBase64, doadorId, status, criadoEm, atualizadoEm |
| solicitacoes | animalId_UID | animalId, animalNome, adotanteId, adotanteNome, doadorId, mensagem, status, datas |
| solicitacoes/{id}/mensagens | automático | remetenteId, texto, criadoEm |

Ao aceitar um pedido, o animal recebe adotanteId e solicitacaoAceitaId. Ao desfazer, ambos são removidos.

## Fluxo

Animal: pendente → disponivel → em_adocao → adotado. Reprovação: reprovado. Edição volta a pendente. Pedido: pendente → aceita → concluida ou cancelada; pedido pendente pode ser recusado ou cancelado.

