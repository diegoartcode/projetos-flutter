# MeuFinance

Aplicativo acadêmico de finanças pessoais para Android. Flutter + Firebase Authentication + Cloud Firestore, plano Spark.

## Funcionalidades
Cadastro/login/reset, perfil, CRUD financeiro, categorias com arquivamento, histórico paginado e filtros, indicadores e gráficos, metas, orçamento e CSV via área de transferência.

## Arquitetura
`models` representa documentos; `services` concentra Firebase; `utils` calcula e filtra; `screens` organiza telas; `widgets` contém componentes; `theme` define Material 3.

## Início rápido
```powershell
powershell -ExecutionPolicy Bypass -File .\preparar_android.ps1
firebase login
firebase use --add
flutterfire configure
firebase deploy --only firestore:rules,firestore:indexes
flutter pub get
flutter analyze
flutter test
flutter run
```
Crie antes o projeto Spark, habilite E-mail/senha e Firestore Standard. Selecione o mesmo projeto nas duas CLIs. Não há configuração Firebase de terceiros nem APK incluído.

# MeuFinance — Manual passo a passo

Versão acadêmica consolidada | Flutter + Firebase Spark

## 01 | Preparação do ambiente

### Objetivo

Executar o projeto em Windows com Android, utilizando apenas Flutter, Dart, Firebase Authentication, Firestore e FL Chart. O plano Spark não requer cartão de crédito; respeite as cotas. Não habilite Storage, Functions ou Blaze.

### Instalação

Instale Flutter stable (SDK Dart 3.8 ou superior), Git, VS Code com extensões Flutter/Dart, Android Studio e Android SDK. Crie um emulador no Device Manager ou conecte um aparelho com depuração USB. Instale Node.js LTS para a CLI do Firebase.

### Comandos

```powershell
flutter doctor -v
flutter doctor --android-licenses
flutter devices
node --version
npm --version
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire --version
```

### PATH

Se flutterfire não for reconhecido, adicione %LOCALAPPDATA%\Pub\Cache\bin ao PATH do usuário e reabra o VS Code. Se o PowerShell bloquear npm.ps1, use npm.cmd ou o Prompt de Comando. Corrija as pendências do flutter doctor antes de prosseguir.

## 02 | Criar e conectar o Firebase

### Console

Acesse https://console.firebase.google.com/ e crie um projeto por grupo. Desative Analytics se desejar. Confirme Spark. Em Authentication, habilite E-mail/senha. Em Firestore Database, crie um banco Standard em modo de produção; escolha a região antes de confirmar.

### Preparar o código

Extraia o ZIP, abra MeuFinance/projeto no VS Code e execute o script abaixo. Ele gera a pasta android em um projeto temporário, sem substituir lib. Se a política do laboratório impedir scripts, crie um projeto Flutter separado com flutter create --platforms=android meufinance e copie a pasta android e .metadata para projeto.

### Comandos

```powershell
powershell -ExecutionPolicy Bypass -File .\preparar_android.ps1
firebase login
firebase use --add
flutterfire configure
firebase deploy --only firestore:rules,firestore:indexes
flutter pub get
```

### Conferência

Escolha o mesmo projeto Firebase nas duas CLIs; selecione Android no FlutterFire. O arquivo lib/firebase_options.dart é gerado automaticamente. Nunca copie a configuração de outro grupo. As regras também podem ser publicadas pela aba Regras do console; não use modo de teste aberto.

## 03 | Autenticação e primeira execução

### Comandos

```powershell
dart format lib test
flutter analyze
flutter test
flutter run
```

### Fluxo

main.dart inicializa Firebase. AuthGate observa a sessão e o documento usuarios/{uid}. AuthPage alterna login e cadastro e envia recuperação de senha. O cadastro cria uma conta e um perfil; se o perfil falhar, CompletarPerfil permite recuperação. A senha nunca é gravada no Firestore.

### Prática

Cadastre duas contas de teste, usando nomes fictícios e senhas exclusivas. Verifique Authentication > Users e Firestore > Dados: o UID deve ser o mesmo. Teste login, logout, persistência e recuperação com um e-mail acessível. Não compartilhe credenciais.

### Categorias

Após login, HomePage inicializa 16 categorias com uma transação idempotente. A primeira abertura exige conexão. Se houver falha, tente novamente. O serviço é vinculado ao UID da sessão.

## 04 | CRUD e categorias

### Cadastro

Na HomePage, selecione Receita ou Despesa. Informe descrição, valor (ex.: 1.250,90), categoria, pagamento, data até hoje e observação. A classe Movimentacao converte DateTime para Timestamp. O serviço usa add, update e delete.

### Edição e exclusão

Abra Histórico e toque em uma movimentação para editar; use a lixeira para excluir após confirmação. O saldo mensal é atualizado pela consulta em tempo real. Datas de criação são preservadas; atualizadoEm usa serverTimestamp.

### Categorias

Abra Categorias, toque +, informe nome, tipo, cor e ícone. Toque na categoria para editar; arquive/reative pelo botão lateral. O tipo é imutável. Nomes normalizados são comparados pelo serviço (não é garantia contra concorrência). Categorias arquivadas não entram em novos lançamentos; os antigos preservam ID e nome.

### Exercício

Cadastre a base CSV manualmente, escolhendo as categorias existentes. Não importe dados diretamente sem adaptar timestamps e regras. O arquivo é uma base didática, não um importador automático.

## 05 | Indicadores, histórico e gráficos

### Cálculos

resumir() usa acumuladores inteiros para receitas e despesas; saldo = receitas - despesas. Média é arredondada ao centavo. Percentuais ficam indisponíveis quando receita ou base anterior é zero. porCategoria() agrupa por ID, preservando nomes históricos.

### Histórico

Use setas para navegar entre meses, calendário para intervalo, busca sem acentos, tipo, categoria, pagamento e faixa de valor. Ordene por data ou valor. As páginas retornam 30 documentos. Totais e filtros são parciais até carregar todo o período. Atualize após mudanças em outro dispositivo.

### Relatórios

Abra Relatórios, selecione o mês. A consulta carrega seis meses e gera rosca, barras agrupadas, linha do saldo, ranking e indicadores. Meses vazios aparecem com zero. O saldo acumulado é consultado sob demanda e não equivale a saldo bancário.

### Validação da base

Novembro: 14 registros, receitas R$ 5.900,00, despesas R$ 3.626,40, saldo R$ 2.273,60. Junho a novembro: 37 registros, receitas R$ 27.200,00, despesas R$ 21.426,40, saldo R$ 5.773,60. Estes totais foram recalculados da base CSV.

## 06 | Metas, orçamento e exportação

### Metas

Abra Metas financeiras e crie um objetivo, valor-alvo e valor reservado. Edite os valores e observe a barra de progresso e a situação. O valor reservado é informado manualmente: não altera o saldo e não realiza transferências. Exclua uma meta mediante confirmação.

### Orçamento

Escolha o mês e uma categoria de despesa. Defina o limite; o gasto é calculado das movimentações do mês por ID. O indicador sinaliza estouro do limite. Pode planejar meses futuros. O documento tem ID determinístico por período e categoria; remover o limite não exclui despesas.

### Exportação

No Histórico, carregue todo o período, aplique os filtros e toque no ícone de download. A versão acadêmica copia CSV para a área de transferência. Cole em um editor de texto e salve como .csv em UTF-8. Abra em planilha usando ponto e vírgula como separador. Valores exportados estão em centavos.

### Perfil e interface

O botão de perfil permite editar o nome; o e-mail da conta permanece inalterado. O tema global usa Material 3. A navegação usa menus e rotas, sem necessidade de bibliotecas pagas.

## 07 | Segurança, testes e entrega

### Regras

firestore.rules limita leituras e gravações ao proprietário do UID. Valida campos, valores positivos, timestamps, categoria ativa e tipo correspondente. A associação histórica pode ser preservada. Exclusão física de categorias e perfis é bloqueada. O console de administração não representa as permissões de um cliente comum.

### Testes

Execute flutter test para os testes de cálculo, moeda, filtros e CSV. Use o simulador de regras ou Emulator Suite para testar acessos negados. Para emuladores locais, instale Java compatível, execute firebase emulators:start e configure useAuthEmulator e useFirestoreEmulator antes da primeira consulta; no Android emulado, use 10.0.2.2 e portas 9099/8080. Não misture contas locais e reais.

### Comandos

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

### Entrega

APK em build/app/outputs/flutter-apk/app-debug.apk. Entregue repositório GitHub, README, capturas de telas fictícias, evidências de testes e relatório de dificuldades. Não publique dados financeiros reais, senhas, chaves privadas ou contas de serviço. Cada grupo gera sua configuração.

### Limitação

O código foi produzido e revisado estruturalmente, mas o ambiente de geração não contém Flutter SDK ou um projeto Firebase ativo. Compilação, testes unitários, implantação e integração precisam ser executados pelo grupo. A versão consolidada agrupa algumas telas e serviços e substitui os arquivos das aulas anteriores.

## 08 | Solução de problemas

### flutterfire não encontrado

Verifique PATH e execute dart pub global activate flutterfire_cli; reinicie o terminal.

### firebase_options.dart ausente

Execute flutterfire configure no diretório projeto e selecione Android.

### permission-denied

Confirme projeto, UID, perfil, categoria ativa e regras publicadas. Não abra o banco para todos.

### Dependências incompatíveis

Atualize o Flutter stable e execute flutter pub get; intl deve ser compatível com flutter_localizations. Use flutter pub outdated para investigar. Registre pubspec.lock após a resolução.

### Android/Gradle

Confira flutter doctor -v, JDK/SDK, licenças e dispositivo. Se necessário, flutter clean, flutter pub get e flutter run.

### FAILED_PRECONDITION

Leia o erro do Firestore e crie o índice apenas se solicitado. A consulta por data usa o índice padrão.

### Sem dados ou saldo divergente

Confira mês, filtros, páginas carregadas, centavos e datas. No relatório, clique em atualizar. Na HomePage, reabra a sessão ao virar o mês.

### Referências

https://docs.flutter.dev/
https://firebase.google.com/docs/flutter/setup
https://firebase.google.com/docs/firestore/security/get-started
https://firebase.google.com/pricing
https://pub.dev/packages/fl_chart

