# Mapa de implementação por etapa

A versão consolidada reúne telas relacionadas em um mesmo arquivo, preservando a separação por camada. Não copie os arquivos antigos sobre esta versão.

| Etapa | Arquivos principais | Conceitos |
|---|---|---|
| 1 Configuração | main.dart, preparar_android.ps1, pubspec.yaml | Inicialização, dependências |
| 2 Autenticação | models/usuario.dart, services/auth_service.dart, screens/auth_page.dart, screens/auth_gate.dart | UID, sessões, perfil |
| 3 CRUD | models/animal.dart, services/animal_service.dart, screens/animal_form.dart, screens/animal_page.dart | add, update, delete, snapshots |
| 4 Fotografias | services/imagem_service.dart, widgets/foto_animal.dart | JPEG, Base64, bytes |
| 5 Filtros | screens/animal_page.dart | where, contains, setState |
| 6 Adoções | models/solicitacao.dart, services/solicitacao_service.dart, screens/pedidos_page.dart | transações, estados |
| 7 Administração | services/usuario_service.dart, services/dashboard_service.dart, screens/admin_page.dart | count, Future.wait, bloqueio |
| 8 Finalização | theme/app_theme.dart, screens/home_page.dart, services/mensagem_service.dart, screens/pedidos_page.dart, firestore.rules | tema, navegação, chat, segurança |

## Sequência de leitura
Comece pelo main, siga AuthGate, HomePage e os serviços de cada módulo. O método de consulta retorna Stream e a tela usa StreamBuilder; o dashboard usa FutureBuilder. As regras são a autoridade final para todas as operações.
